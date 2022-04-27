class VtkAT910 < Formula
   desc "Toolkit for 3D computer graphics, image processing, and visualization"
   homepage "https://www.vtk.org/"
   url "https://www.vtk.org/files/release/9.1/VTK-9.1.0.tar.gz"
   sha256 "8fed42f4f8f1eb8083107b68eaa9ad71da07110161a3116ad807f43e5ca5ce96"
   license "BSD-3-Clause"
   head "https://github.com/Kitware/VTK.git"

   depends_on "cmake" => [:build, :test]
   depends_on "./boost@1.78.0"
   depends_on "double-conversion"
   depends_on "eigen"
   depends_on "fontconfig"
   depends_on "gl2ps"
   depends_on "glew"
   depends_on "hdf5"
   depends_on "jsoncpp"
   depends_on "libogg"
   depends_on "jpeg"
   depends_on "libpng"
   depends_on "libtiff"
   depends_on "lz4"
   depends_on "netcdf"
   depends_on "pugixml"
   depends_on "./pyqt@5.15.6"
   depends_on "./python@3.10.2"
   depends_on "./qt5153"
   depends_on "sqlite"
   depends_on "theora"
   depends_on "utf8cpp"
   depends_on "xz"
   uses_from_macos "expat"
   uses_from_macos "libxml2"
   uses_from_macos "zlib"
   
   fails_with :clang if DevelopmentTools.clang_build_version == 1316 && Hardware::CPU.arm?

   def install
     if DevelopmentTools.clang_build_version == 1316 && Hardware::CPU.arm?
       ENV.remove "HOMEBREW_LIBRARY_PATHS", Formula["llvm"].opt_lib # ToDo: use own llvm
       ENV.llvm_clang
     end

     pyver = Language::Python.major_minor_version "python3"
     args = std_cmake_args + %W[
       -DBUILD_SHARED_LIBS:BOOL=ON
       -DBUILD_TESTING:BOOL=OFF
       -DCMAKE_INSTALL_NAME_DIR:STRING=#{opt_lib}
       -DCMAKE_INSTALL_RPATH:STRING=#{rpath}
       -DCMAKE_DISABLE_FIND_PACKAGE_ICU:BOOL=ON
       -DVTK_WRAP_PYTHON:BOOL=ON
       -DVTK_PYTHON_VERSION:STRING=3
       -DVTK_USE_COCOA:BOOL=ON
       -DVTK_LEGACY_REMOVE:BOOL=ON
       -DVTK_MODULE_ENABLE_VTK_InfovisBoost:STRING=YES
       -DVTK_MODULE_ENABLE_VTK_InfovisBoostGraphAlgorithms:STRING=YES
       -DVTK_MODULE_ENABLE_VTK_RenderingFreeTypeFontConfig:STRING=YES
       -DVTK_MODULE_USE_EXTERNAL_VTK_doubleconversion:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_eigen:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_expat:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_gl2ps:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_glew:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_hdf5:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_jpeg:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_jsoncpp:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_libxml2:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_lz4:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_lzma:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_netcdf:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_ogg:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_png:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_pugixml:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_sqlite:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_theora:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_tiff:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_utf8:BOOL=ON
       -DVTK_MODULE_USE_EXTERNAL_VTK_zlib:BOOL=ON
       -DPython3_EXECUTABLE:FILEPATH=#{Formula["./python@3.10.2"].opt_bin}/python3
       -DVTK_GROUP_ENABLE_Qt:STRING=YES
       -DVTK_INSTALL_PYTHON_MODULE_DIR=#{lib}/python#{pyver}/site-packages
       -DVTK_QT_VERSION:STRING=5
       -DVTK_WRAP_PYTHON_SIP=ON
       -DSIP_PYQT_DIR='#{Formula["./pyqt@5.15.6"].opt_share}/sip'
     ]

     system "cmake", "-S", ".", "-B", "build", *std_cmake_args, *args
     system "cmake", "--build", "build"
     system "cmake", "--install", "build"
   end

   test do
     (testpath/"CMakeLists.txt").write <<~EOS
       cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
       project(Distance2BetweenPoints LANGUAGES CXX)
       find_package(VTK REQUIRED COMPONENTS vtkCommonCore CONFIG)
       add_executable(Distance2BetweenPoints Distance2BetweenPoints.cxx)
       target_link_libraries(Distance2BetweenPoints PRIVATE ${VTK_LIBRARIES})
     EOS

     (testpath/"Distance2BetweenPoints.cxx").write <<~EOS
       #include <cassert>
       #include <vtkMath.h>
       int main() {
         double p0[3] = {0.0, 0.0, 0.0};
         double p1[3] = {1.0, 1.0, 1.0};
         assert(vtkMath::Distance2BetweenPoints(p0, p1) == 3.0);
         return 0;
       }
     EOS

     vtk_dir = Dir[opt_lib/"cmake/vtk-*"].first
     system "cmake", "-DCMAKE_BUILD_TYPE=Debug", "-DCMAKE_VERBOSE_MAKEFILE=ON",
       "-DVTK_DIR=#{vtk_dir}", "."
     system "make"
     system "./Distance2BetweenPoints"

     (testpath/"Distance2BetweenPoints.py").write <<~EOS
       import vtk
       p0 = (0, 0, 0)
       p1 = (1, 1, 1)
       assert vtk.vtkMath.Distance2BetweenPoints(p0, p1) == 3
     EOS

     system bin/"vtkpython", "Distance2BetweenPoints.py"
   end
 end 