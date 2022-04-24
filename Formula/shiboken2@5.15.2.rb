class Shiboken2AT5152 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.shiboken2-generator.md?h=5.15.2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.2-src/pyside-setup-opensource-src-5.15.2.tar.xz"
  sha256 "b306504b0b8037079a8eab772ee774b9e877a2d84bab2dbefbe4fa6f83941418"

  #bottle do
  #  root_url "https://github.com/FreeCAD/homebrew-freecad/releases/download/shiboken2@5.15.2-5.15.2"
  #  sha256 cellar: :any, big_sur:  "b8d2ad961130d7e8f6a838bc95b55c12d529befe6a0cd03aebef7792abd060e6"
  #  sha256 cellar: :any, catalina: "43d87877ce4168d1d6c5574cf4dc26683845ed8fa74d5ca23aa9174dc167db8d"
  #  sha256 cellar: :any, mojave:   "3ee35e362c5b373328c53f9a85927b1282e32ccf542343de359c3d96405ceef3"
  #end

  keg_only :versioned_formula # NOTE: will conflict with other shiboken2 installs

  depends_on "cmake" => :build
  depends_on "./python@3.10.2" => :build
  depends_on "./numpy@1.22.3"
  depends_on "./qt5152"
  depends_on "./llvm@13.0.0"
  
  patch do
    url "https://src.fedoraproject.org/fork/vstinner/rpms/python-pyside2/raw/ce03f8cb03186129f9f36b5469933267b0fc10d8/f/python310.patch"
    sha256 "9d7600f0fff8ed5d3cd2be1313c987a3d31fecdfe2fe14b917fd137c5e5ecf8f"
  end
  
  patch :DATA

  def install
    ENV["LLVM_INSTALL_DIR"] = Formula["./llvm@13.0.0"].opt_prefix

    mkdir "macbuild#{version}" do
      pyhome = `#{Formula["./python@3.10.2"].opt_bin}/python3.10-config --prefix`.chomp
      py_library = "#{pyhome}/lib/libpython3.10.dylib"
      py_include = "#{pyhome}/include/python3.10"
      args = std_cmake_args
      # Building the tests, is effectively a test of Shiboken
      args << "-DBUILD_TYPE=Release"
      args << "-DBUILD_TESTS:BOOL=OFF"
      args << "-DPYTHON_EXECUTABLE=#{pyhome}/bin/python3.10"
      args << "-DPYTHON_LIBRARY=#{py_library}"
      args << "-DPYTHON_INCLUDE_DIR=#{py_include}"
      args << "../sources/shiboken2"

      system "cmake", *args
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  def caveats
    <<-EOS
    this formula is keg-only due to freecad/freecad/shiboken2
    EOS
  end

  test do
    # NOTE: use `#{bin}` able to test formula installed in custom prefix
    system "#{bin}/shiboken2", "--version"
  end
end

#https://code.qt.io/cgit/pyside/pyside-setup.git/commit/sources/shiboken2/libshiboken/pep384impl.cpp?h=v5.15.2.1&id=298cfb2d4a9674ed00b3769fa396a292c075c51c
__END__
diff --git a/sources/shiboken2/libshiboken/pep384impl.cpp b/sources/shiboken2/libshiboken/pep384impl.cpp
index cb8042561..66df0fd94 100644
--- a/sources/shiboken2/libshiboken/pep384impl.cpp
+++ b/sources/shiboken2/libshiboken/pep384impl.cpp
@@ -754,11 +754,13 @@ _Pep_PrivateMangle(PyObject *self, PyObject *name)
 #ifndef Py_LIMITED_API
     return _Py_Mangle(privateobj, name);
 #else
-    // For some reason, _Py_Mangle is not in the Limited API. Why?
-    size_t plen = PyUnicode_GET_LENGTH(privateobj);
+    // PYSIDE-1436: _Py_Mangle is no longer exposed; implement it always.
+    // The rest of this function is our own implementation of _Py_Mangle.
+    // Please compare the original function in compile.c .
+    size_t plen = PyUnicode_GET_LENGTH(privateobj.object());
     /* Strip leading underscores from class name */
     size_t ipriv = 0;
-    while (PyUnicode_READ_CHAR(privateobj, ipriv) == '_')
+    while (PyUnicode_READ_CHAR(privateobj.object(), ipriv) == '_')
         ipriv++;
     if (ipriv == plen) {
         Py_INCREF(name);