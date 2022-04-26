# Patches for Qt must be at the very least submitted to Qt's Gerrit codereview
# rather than their bug-report Jira. The latter is rarely reviewed by Qt.
class Qt5153 < Formula
  desc "Cross-platform application and UI framework"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/5.15/5.15.3/single/qt-everywhere-opensource-src-5.15.3.tar.xz"
  mirror "https://mirrors.dotsrc.org/qtproject/archive/qt/5.15/5.15.3/single/qt-everywhere-opensource-src-5.15.3.tar.xz"
  mirror "https://mirrors.ocf.berkeley.edu/qt/archive/qt/5.15/5.15.3/single/qt-everywhere-opensource-src-5.15.3.tar.xz"
  sha256 "b7412734698a87f4a0ae20751bab32b1b07fdc351476ad8e35328dbe10efdedb"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]

  head "https://code.qt.io/qt/qt5.git", branch: "dev", shallow: false

  
  fails_with gcc: "5"
  
  livecheck do
    url :head
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  keg_only "qt 5 has CMake issues when linked"

  depends_on "pkg-config" => :build
  depends_on xcode: :build
  depends_on macos: :sierra

  uses_from_macos "gperf" => :build
  uses_from_macos "bison"
  uses_from_macos "flex"
  uses_from_macos "sqlite"

  resource "qtwebengine" do
    url "https://code.qt.io/qt/qtwebengine.git",
        tag:      "v5.15.8-lts",
        revision: "96e932d73057c3e705b849249fb02e1837b7576d"
  end
  
  # Backport https://code.qt.io/cgit/qt/qtbase.git/commit/src/plugins/platforms/cocoa?id=dece6f5840463ae2ddf927d65eb1b3680e34a547
  # to fix the build with Xcode 13.
  # The original commit is for Qt 6 and cannot be applied cleanly to Qt 5.
  patch :DATA

  # Fix build for GCC 11
   patch do
     url "https://invent.kde.org/qt/qt/qtdeclarative/commit/3c42d4d3dce95b67d65541c5612384eab0c3e27b.patch"
     sha256 "e8943934af0cea22814b526ca75abf98cacac2d0f86e2b2c9588c694a859f9d2"
     directory "qtdeclarative"
   end

   # Fix build for GCC 11
   patch do
     url "https://invent.kde.org/qt/qt/qtdeclarative/commit/0eb5ff2e97713e12318c00bab9f3605abb8592c2.patch"
     sha256 "496241b7810f8073c82b781c7c4addb38a4ec3fbe3e7cafff56b0d0e340e2d5f"
     directory "qtdeclarative"
   end

   # Patch for qmake on ARM
   # https://codereview.qt-project.org/c/qt/qtbase/+/327649
   if Hardware::CPU.arm?
     patch do
       url "https://raw.githubusercontent.com/Homebrew/formula-patches/9dc732/qt/qt-split-arch.patch"
       sha256 "36915fde68093af9a147d76f88a4e205b789eec38c0c6f422c21ae1e576d45c0"
       directory "qtbase"
     end
   end

  def install
    rm_r "qtwebengine"
    
    resource("qtwebengine").stage(buildpath/"qtwebengine") if OS.mac?
    
    args = %W[
      -verbose
      -prefix #{prefix}
      -release
      -opensource -confirm-license
      -system-zlib
      -qt-libpng
      -qt-libjpeg
      -qt-freetype
      -qt-pcre
      -nomake examples
      -nomake tests
      -no-rpath
      -pkg-config
      -dbus-runtime
    ]

    if Hardware::CPU.arm?
      # Temporarily fixes for Apple Silicon
      args << "-skip" << "qtwebengine" << "-no-assimp"
    else
      # Should be reenabled unconditionnaly once it is fixed on Apple Silicon
      args << "-proprietary-codecs"
    end

    system "./configure", *args

    # Remove reference to shims directory
    inreplace "qtbase/mkspecs/qmodule.pri",
              /^PKG_CONFIG_EXECUTABLE = .*$/,
              "PKG_CONFIG_EXECUTABLE = #{Formula["pkg-config"].opt_bin/"pkg-config"}"
    system "make"
    ENV.deparallelize
    system "make", "install"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink Dir["#{lib}/*.framework"]

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob("#{lib}/*.framework/Headers") do |path|
      include.install_symlink path => path.parent.basename(".framework")
    end

    # Move `*.app` bundles into `libexec` to expose them to `brew linkapps` and
    # because we don't like having them in `bin`.
    # (Note: This move breaks invocation of Assistant via the Help menu
    # of both Designer and Linguist as that relies on Assistant being in `bin`.)
    libexec.mkpath
    Pathname.glob("#{bin}/*.app") { |app| mv app, libexec }
    
    if OS.mac? && !Hardware::CPU.arm?
      # Fix find_package call using QtWebEngine version to find other Qt5 modules.
      inreplace Dir[lib/"cmake/Qt5WebEngine*/*Config.cmake"],
                " #{resource("qtwebengine").version} ", " #{version} "
    end
  end

  def caveats
    s = <<~EOS
      We agreed to the Qt open source license for you.
      If this is unacceptable you should uninstall.
    EOS

    if Hardware::CPU.arm?
      s += <<~EOS
        This version of Qt on Apple Silicon does not include QtWebEngine
      EOS
    end

    s
  end

  test do
    (testpath/"hello.pro").write <<~EOS
      QT       += core
      QT       -= gui
      TARGET = hello
      CONFIG   += console
      CONFIG   -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    EOS

    (testpath/"main.cpp").write <<~EOS
      #include <QCoreApplication>
      #include <QDebug>

      int main(int argc, char *argv[])
      {
        QCoreApplication a(argc, argv);
        qDebug() << "Hello World!";
        return 0;
      }
    EOS

    system bin/"qmake", testpath/"hello.pro"
    system "make"
    assert_predicate testpath/"hello", :exist?
    assert_predicate testpath/"main.o", :exist?
    system "./hello"
  end
end

__END__
--- a/qtbase/src/plugins/platforms/cocoa/qiosurfacegraphicsbuffer.h
+++ b/qtbase/src/plugins/platforms/cocoa/qiosurfacegraphicsbuffer.h
@@ -43,4 +43,6 @@
 #include <qpa/qplatformgraphicsbuffer.h>
 #include <private/qcore_mac_p.h>
+ 
+#include <CoreGraphics/CGColorSpace.h>

 QT_BEGIN_NAMESPACE