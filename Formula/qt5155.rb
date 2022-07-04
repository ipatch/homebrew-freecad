# Patches for Qt must be at the very least submitted to Qt's Gerrit codereview
# rather than their bug-report Jira. The latter is rarely reviewed by Qt.
class Qt5155 < Formula
  desc "Cross-platform application and UI framework"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/5.15/5.15.5/single/qt-everywhere-opensource-src-5.15.5.tar.xz"
  mirror "https://mirrors.dotsrc.org/qtproject/archive/qt/5.15/5.15.5/single/qt-everywhere-opensource-src-5.15.5.tar.xz"
  mirror "https://mirrors.ocf.berkeley.edu/qt/archive/qt/5.15/5.15.5/single/qt-everywhere-opensource-src-5.15.5.tar.xz"
  sha256 "5a97827bdf9fd515f43bc7651defaf64fecb7a55e051c79b8f80510d0e990f06"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]

  head "https://code.qt.io/qt/qt5.git", branch: "dev", shallow: false

  
  fails_with gcc: "5"
  
  livecheck do
    url :head
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  keg_only :versioned_formula

  depends_on "node"       => :build
  depends_on "pkg-config" => :build
  depends_on xcode: :build
  depends_on macos: :sierra
  depends_on "./python@3.10.2" => :build
  depends_on "freetype"
  depends_on "glib"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "pcre2"
  depends_on "webp"


  resource "qtwebengine" do
     url "https://code.qt.io/qt/qtwebengine.git",
         tag:      "v5.15.10-lts",
         revision: "c7e716ef1ffd63a8ab1f4dbf879230849eb3b505"

     # Add Python 3 support to qt-webengine-chromium.
     # Submitted upstream here: https://codereview.qt-project.org/c/qt/qtwebengine-chromium/+/416534
     patch do
       url "https://raw.githubusercontent.com/Homebrew/formula-patches/7ae178a617d1e0eceb742557e63721af949bd28a/qt5/qt5-webengine-chromium-python3.patch?full_index=1"
       sha256 "a93aa8ef83f0cf54f820daf5668574cc24cf818fb9589af2100b363356eb6b49"
       directory "src/3rdparty"
     end

     # Add Python 3 support to qt-webengine.
     # Submitted upstream here: https://codereview.qt-project.org/c/qt/qtwebengine/+/416535
     patch do
       url "https://raw.githubusercontent.com/Homebrew/formula-patches/a6f16c6daea3b5a1f7bc9f175d1645922c131563/qt5/qt5-webengine-python3.patch?full_index=1"
       sha256 "398c996cb5b606695ac93645143df39e23fa67e768b09e0da6dbd37342a43f32"
     end

     # Fix build of qt-webengine-chromium with newer GCC.
     # Submitted upstream here: https://codereview.qt-project.org/c/qt/qtwebengine-chromium/+/416598
     patch do
       url "https://raw.githubusercontent.com/Homebrew/formula-patches/a6f16c6daea3b5a1f7bc9f175d1645922c131563/qt5/qt5-webengine-gcc12.patch?full_index=1"
       sha256 "cf9be3ffcc3b3cd9450b1ff13535ff7d76284f73173412d097a6ab487463a379"
       directory "src/3rdparty"
     end
   end

   # Update catapult to a revision that supports Python 3.
   resource "catapult" do
     url "https://chromium.googlesource.com/catapult.git",
     revision: "5eedfe23148a234211ba477f76fc2ea2e8529189"
   end

   # Backport of https://code.qt.io/cgit/qt/qtbase.git/commit/src/plugins/platforms/cocoa?id=dece6f5840463ae2ddf927d65eb1b3680e34a547
   # to fix the build with Xcode 13.
   # The original commit is for Qt 6 and cannot be applied cleanly to Qt 5.
   patch :DATA

   # Fix build for GCC 11
   patch do
     url "https://invent.kde.org/qt/qt/qtbase/commit/ccc0f5cd016eb17e4ff0db03ffed76ad32c8894d.patch"
     sha256 "ad97b5dbb13875f95a6d9ffc1ecf89956f8249771a4e485bd5ddcbe0c8ba54e8"
     directory "qtbase"
   end

   # Fix build for GCC 11
   patch do
     url "https://invent.kde.org/qt/qt/qtdeclarative/commit/8da88589929a1d82103c8bbfa80210f3c1af3714.patch"
     sha256 "9faedb41c80f23d4776f0be64f796415abd00ef722a318b3f7c1311a8f82e66d"
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

    resource("qtwebengine").stage(buildpath/"qtwebengine")

    rm_r "qtwebengine/src/3rdparty/chromium/third_party/catapult"

    resource("catapult").stage(buildpath/"qtwebengine/src/3rdparty/chromium/third_party/catapult")

    # FIXME: GN requires clang in clangBasePath/bin
    inreplace "qtwebengine/src/3rdparty/chromium/build/toolchain/mac/BUILD.gn",
        'rebase_path("$clang_base_path/bin/", root_build_dir)', '""'

    # Fix version conflict
    inreplace "qtwebengine/.qmake.conf", "5.15.10", "5.15.5"

    args = %W[
      -verbose
      -prefix #{prefix}
      -release
      -opensource -confirm-license
      -nomake examples
      -nomake tests
      -pkg-config
      -dbus-runtime
      -proprietary-codecs
      -system-freetype
      -system-libjpeg
      -system-libpng
      -system-pcre
      -system-zlib
      -no-rpath
    ]

    args << "-no-assimp" if Hardware::CPU.arm?

    ENV.prepend_path "PATH", Formula["./python@3.10.2"].libexec/"bin"
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