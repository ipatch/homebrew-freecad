class Pyside2 < Formula
  desc "Python bindings for Qt5 and greater"
  homepage "https://wiki.qt.io/PySide2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.2-src/pyside-setup-opensource-src-5.15.2.tar.xz"
  sha256 "b306504b0b8037079a8eab772ee774b9e877a2d84bab2dbefbe4fa6f83941418"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  head "http://code.qt.io/cgit/pyside/pyside-setup.git", branch: "v5.15.2"

  option "without-docs", "Skip building documentation"

  depends_on "cmake" => :build
  depends_on "./python@3.10.2" => :build
  # depends_on "./sphinx-doc@3.9.7" => :build if build.with? "docs"
  depends_on "./qt5152"
  depends_on "./shiboken2@5.15.2"

  conflicts_with "pyside@2", because: "non app bundle of freecad could use wrong version"
  
  patch do
    url "https://src.fedoraproject.org/rpms/python-pyside2/raw/1f7e56d4f8320d98e59d9291ddab0451a436c7bf/f/python3.10.patch"
    sha256 "dd18a7ed1d4196b48ddfd7cf1dcbebe4c600dcedb45baba4c852131e221cf4bc"
  end

  def install
    ENV.cxx11

    # This is a workaround for current problems with Shiboken2
    ENV["HOMEBREW_INCLUDE_PATHS"] = ENV["HOMEBREW_INCLUDE_PATHS"].sub(Formula["./qt5152"].include, "")

    rm buildpath/"sources/pyside2/doc/CMakeLists.txt" if build.without? "docs"
    # qt = Formula["#{@tap}/qt5152"]

    # Add out of tree build because one of its deps, shiboken, itself needs an
    # out of tree build in shiboken.rb.
    pyhome = `#{Formula["./python@3.10.2"].opt_bin}/python3.10-config --prefix`.chomp
    py_library = "#{pyhome}/lib/libpython3.10.dylib"
    py_include = "#{pyhome}/include/python3.10"

    mkdir "macbuild3.8" do
      ENV["LLVM_INSTALL_DIR"] = Formula["./llvm@13.0.0"].opt_prefix
      ENV["CMAKE_PREFIX_PATH"] = Formula["./shiboken2@5.15.2"].opt_prefix + "/lib/cmake"
      args = std_cmake_args + %W[
        -DPYTHON_EXECUTABLE=#{pyhome}/bin/python3.10
        -DPYTHON_LIBRARY=#{py_library}
        -DPYTHON_INCLUDE_DIR=#{py_include}
        -DCMAKE_BUILD_TYPE=Release
      ]
      args << "../sources/pyside2"
      system "cmake", *args
      system "make", "-j#{ENV.make_jobs}"
      system "make", "install"
    end
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "from PySide2 import QtCore"
    end
  end
end
