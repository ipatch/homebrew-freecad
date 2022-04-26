class Shiboken2AT5153 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://code.qt.io/cgit/pyside/pyside-setup.git/tree/README.shiboken2-generator.md?h=5.15.2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.3-src/pyside-setup-opensource-src-5.15.3.zip"
  sha256 "ae8517173eb831301791dd864ba73e8c51b9fab67eeb8d2ed76ddfe20377ab03"

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
  depends_on "./qt5153"
  depends_on "./llvm@13.0.0"

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

__END__
diff --git a/sources/shiboken2/libshiboken/pep384impl.cpp b/sources/shiboken2/libshiboken/pep384impl.cpp
index cb80425..c4e7301 100644
--- a/sources/shiboken2/libshiboken/pep384impl.cpp
+++ b/sources/shiboken2/libshiboken/pep384impl.cpp
@@ -707,6 +707,76 @@ * Extra support for name mangling
 *
 */
 
+#if PY_VERSION_HEX >= 0x03000000
+PyObject *
+_Py_Mangle(PyObject *privateobj, PyObject *ident)
+{
+    /* Name mangling: __private becomes _classname__private.
+       This is independent from how the name is used. */
+    PyObject *result;
+    size_t nlen, plen, ipriv;
+    Py_UCS4 maxchar;
+    if (privateobj == NULL || !PyUnicode_Check(privateobj) ||
+        PyUnicode_READ_CHAR(ident, 0) != '_' ||
+        PyUnicode_READ_CHAR(ident, 1) != '_') {
+        Py_INCREF(ident);
+        return ident;
+    }
+    nlen = PyUnicode_GET_LENGTH(ident);
+    plen = PyUnicode_GET_LENGTH(privateobj);
+    /* Don't mangle __id__ or names with dots.
+
+       The only time a name with a dot can occur is when
+       we are compiling an import statement that has a
+       package name.
+
+       TODO(jhylton): Decide whether we want to support
+       mangling of the module name, e.g. __M.X.
+    */
+    if ((PyUnicode_READ_CHAR(ident, nlen-1) == '_' &&
+         PyUnicode_READ_CHAR(ident, nlen-2) == '_') ||
+        PyUnicode_FindChar(ident, '.', 0, nlen, 1) != -1) {
+        Py_INCREF(ident);
+        return ident; /* Don't mangle __whatever__ */
+    }
+    /* Strip leading underscores from class name */
+    ipriv = 0;
+    while (PyUnicode_READ_CHAR(privateobj, ipriv) == '_')
+        ipriv++;
+    if (ipriv == plen) {
+        Py_INCREF(ident);
+        return ident; /* Don't mangle if class is just underscores */
+    }
+    plen -= ipriv;
+
+    if (plen + nlen >= PY_SSIZE_T_MAX - 1) {
+        PyErr_SetString(PyExc_OverflowError,
+                        "private identifier too large to be mangled");
+        return NULL;
+    }
+
+    maxchar = PyUnicode_MAX_CHAR_VALUE(ident);
+    if (PyUnicode_MAX_CHAR_VALUE(privateobj) > maxchar)
+        maxchar = PyUnicode_MAX_CHAR_VALUE(privateobj);
+
+    result = PyUnicode_New(1 + nlen + plen, maxchar);
+    if (!result)
+        return 0;
+    /* ident = "_" + priv[ipriv:] + ident # i.e. 1+plen+nlen bytes */
+    PyUnicode_WRITE(PyUnicode_KIND(result), PyUnicode_DATA(result), 0, '_');
+    if (PyUnicode_CopyCharacters(result, 1, privateobj, ipriv, plen) < 0) {
+        Py_DECREF(result);
+        return NULL;
+    }
+    if (PyUnicode_CopyCharacters(result, plen+1, ident, 0, nlen) < 0) {
+        Py_DECREF(result);
+        return NULL;
+    }
+    assert(_PyUnicode_CheckConsistency(result, 1));
+    return result;
+}
+#endif
+
 #ifdef Py_LIMITED_API
 // We keep these definitions local, because they don't work in Python 2.
 # define PyUnicode_GET_LENGTH(op)    PyUnicode_GetLength((PyObject *)(op))