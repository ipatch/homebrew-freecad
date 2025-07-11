class FreecadAT0212Py310 < Formula
  desc "Parametric 3D modeler"
  homepage "https://freecad.org/"
  license "GPL-2.0-only"

  # NOTE: ipatch, ie. local patch `url "file:///#{HOMEBREW_PREFIX}/Library/Taps/freecad/homebrew-freecad/patches/`
  #---
  stable do
    url "https://github.com/FreeCAD/FreeCAD/archive/refs/tags/0.21.2.tar.gz"
    sha256 "ceaf77cd12e8ad533d1535cc27ae4ca2a6e80778502dc9cdec906415d674b674"

    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/844db5e2847b262d95cc0bece1628c0adf913905/patches/freecad%400.21.2_py310-backport-xercesc-tests-updates.patch"
      sha256 "fce55c5179756c3a89d1a3e9b6c01e81a82bee21f876c1485044b7fe1b7c822a"
    end

    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/95e5aa838ae8b5e7d4fd6ddd710bc53c8caedddc/patches/freecad-0.20.2-vtk-9.3.patch"
      sha256 "67794ebfcd70a160d379eeca7d2ef78d510057960d0eaa4e2e345acb7ae244aa"
    end

    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/92c1e993680710248fc29af05fcadfedcce0f8ad/patches/freecad-0.20.2-drivergmfcpp.patch"
      sha256 "f27576bf167d6989536307dc9ac330a582a0bc3eb69b97c6b2563ea84e93f406"
    end

    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/ff35908c7512702264758bc570826b0a09b410fc/patches/freecad%400.21.2_py310-boost-185-PreferencePackManager-cpp.patch"
      sha256 "91efb51ab77ecf91244c69b0a858b16ec6238bb647cc0f767cbc6fa1791efbfa"
    end

    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/13cff0680069fd9c564b17e7ea8d4f012d887c8a/patches/freecad%400.21.2_py310-backport-occ-v7.8.patch"
      sha256 "27d8dfb780a55696ba3b989481bf6d0fc736af9c95de03c80c638e9404f62dbf"
    end

    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/b510bf8a0feba8b3d75e121a2fe32fa697a6fef5/patches/freecad%400.21.2_py310-boost-dep-errors.patch"
      sha256 "535316c559a1fb1bd6fab0287c12fcc6ccd6c5b065bbe339207c2bb98fa600b6"
    end

    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/e78eeda91a16658ce4954114b5fdb85b7e72e774/patches/freecad%400.21.2_py310-hdf5-fix-cmake-reruns.patch"
      sha256 "b1becbdc867e96aa1bfe8d8fd1c1b01053b2ce5d1d9483cd0ed19b2d2c6f387f"
    end
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 7
    sha256 cellar: :any, arm64_sonoma: "7727cad45c0c96138c51efed52bf6f88233583ae93ee3d5385da0b132eef23d4"
    sha256 cellar: :any, ventura:      "d55a9b3c93cfddbc19c9a702189992c83dc89c1cf17a0c0add662afa9769582a"
  end

  # NOTE: ipatch, pull in git submodules
  # https://github.com/orgs/Homebrew/discussions/2100#discussioncomment-1288233
  head do
    url "https://github.com/freecad/FreeCAD.git", branch: "main", shallow: false

    depends_on "opencascade"
    depends_on "yaml-cpp"

    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/e78eeda91a16658ce4954114b5fdb85b7e72e774/patches/freecad%400.21.2_py310-hdf5-fix-cmake-reruns.patch"
      sha256 "b1becbdc867e96aa1bfe8d8fd1c1b01053b2ce5d1d9483cd0ed19b2d2c6f387f"
    end

    patch do
      url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/6ed12911b87a1d89727c172131bed35be22c4137/patches/freecad%400.21.2_py310-HEAD-toposhape.h-fix.patch"
      sha256 "47f78a3838790b8fe7c41801cbecbc3f85cdc81ace48476dc79b319d5097e195"
    end
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "freecad/freecad/swig@4.1.1" => :build
  depends_on "gcc" => :build
  # epends_on "hdf5-mpi" => :build # requires fortran compiler
  depends_on "hdf5" => :build # requires fortran compiler
  depends_on "llvm" => :build if OS.linux?
  depends_on "mesa" => :build if OS.linux?
  depends_on "ninja" => :build if OS.linux?
  depends_on "pkg-config" => :build
  depends_on "python@3.10" => :build
  depends_on "tbb" => :build
  depends_on "boost"
  depends_on "cython"
  depends_on "doxygen"
  depends_on "freecad/freecad/coin3d_py310"
  depends_on "freecad/freecad/fc_bundle"
  depends_on "freecad/freecad/med-file"
  depends_on "freecad/freecad/numpy@1.26.4_py310"
  depends_on "freecad/freecad/opencascade@7.7.2"
  depends_on "freecad/freecad/pybind11_py310"
  depends_on "freecad/freecad/pyside2@5.15.11_py310"
  depends_on "freetype"
  depends_on "glew"
  depends_on "googletest"
  depends_on "icu4c"
  depends_on macos: :high_sierra # no access to sierra test box
  depends_on "mesa-glu" if OS.linux?
  depends_on "openblas"
  depends_on "orocos-kdl"
  # epends_on "freecad/freecad/nglib@6.2.2105"
  depends_on "qt@5"
  depends_on "vtk"
  depends_on "webp"
  depends_on "xerces-c"
  depends_on "zlib"

  # NOTE: https://docs.brew.sh/Formula-Cookbook#handling-different-system-configurations
  # patch for mojave with 10.15 SDK
  # patch :p1 do
  #   url "https://raw.githubusercontent.com/FreeCAD/homebrew-freecad/a4b71def99b5fe907550729038752aaf6fa1b9bf/patches/freecad-0.20.1-macos-10.15-sdk.patch"
  #   sha256 "ce9f4b2afb2c621274e74208a563616eeeee54369f295b6c5f6f4f3112923135"
  # end

  def install
    hbp = HOMEBREW_PREFIX

    # NOTE: `which` cmd is not installed by default on every OS
    # ENV["PYTHON"] = which("python3.10")
    ENV["PYTHON"] = Formula["python@3.10"].opt_bin/"python3.10"

    # NOTE: ipatch, taken from the pyside@2 test block
    # pyincludes = shell_output("#{python}-config --includes").chomp.split
    # pylib = shell_output("#{python}-config --ldflags --embed").chomp.split

    # Get the Python includes directory without duplicates
    py_inc_output = `python3.10-config --includes`
    py_inc_dirs = py_inc_output.scan(/-I([^\s]+)/).flatten.uniq
    py_inc_dir = py_inc_dirs.join(" ")

    py_lib_path = if OS.mac?
      `python3.10-config --configdir`.strip + "/libpython3.10.dylib"
    else
      `python3.10-config --configdir`.strip + "/libpython3.10.a"
    end

    puts "----------------------------------------------------"
    puts "PYTHON=#{ENV["PYTHON"]}"
    puts "PYTHON_INCLUDE_DIR=#{py_inc_dir}"
    puts "PYTHON_LIBRARY=#{py_lib_path}"

    # NOTE: apple's clang & clang++ don not provide batteries for open-mpi
    # NOTE: when setting the compilers to brews' llvm, set the cmake_ar linker as well
    # ENV["CC"] = Formula["llvm"].opt_bin/"clang"
    # ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"

    # NOTE: ipatch, attempt to nuke default cmake_prefix_path to prevent qt6 from sneaking in
    ENV.delete("CMAKE_PREFIX_PATH") # Clear existing paths
    puts "----------------------------------------------------"
    puts "CMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]}"
    puts "CMAKE_PREFIX_PATH Datatype: #{ENV["CMAKE_PREFIX_PATH"].class}"
    puts "----------------------------------------------------"
    puts "homebrew prefix: #{hbp}"
    puts "prefix: #{prefix}"
    puts "rpath: #{rpath}"

    ENV.remove "PATH", Formula["qt"].opt_prefix/"bin"
    ENV.remove "PATH", Formula["pyqt"].opt_prefix/"bin"
    # TODO: put each path entry on a separate line
    puts "PATH=#{ENV["PATH"]}"

    cmake_prefix_paths = []
    # cmake_prefix_paths << Formula["open-mpi"].prefix
    # cmake_prefix_paths << Formula["llvm"].prefix
    cmake_prefix_paths << Formula["boost"].prefix
    cmake_prefix_paths << Formula["coin3d_py310"].prefix
    cmake_prefix_paths << Formula["double-conversion"].prefix
    cmake_prefix_paths << Formula["doxygen"].prefix
    cmake_prefix_paths << Formula["eigen"].prefix
    cmake_prefix_paths << Formula["expat"].prefix
    cmake_prefix_paths << Formula["freetype"].prefix
    cmake_prefix_paths << Formula["glew"].prefix
    cmake_prefix_paths << Formula["googletest"].prefix
    cmake_prefix_paths << Formula["hdf5"].prefix
    cmake_prefix_paths << Formula["icu4c"].prefix
    cmake_prefix_paths << Formula["libjpeg-turbo"].prefix
    cmake_prefix_paths << Formula["libpng"].prefix
    cmake_prefix_paths << Formula["libtiff"].prefix
    cmake_prefix_paths << Formula["lz4"].prefix
    cmake_prefix_paths << Formula["medfile"].prefix
    cmake_prefix_paths << Formula["opencascade@7.7.2"].prefix
    cmake_prefix_paths << Formula["pkg-config"].prefix
    cmake_prefix_paths << Formula["pugixml"].prefix
    cmake_prefix_paths << Formula["pybind11_py310"].prefix
    cmake_prefix_paths << Formula["pyside2@5.15.11_py310"].prefix
    cmake_prefix_paths << Formula["qt@5"].prefix
    cmake_prefix_paths << Formula["swig@4.1.1"].prefix
    cmake_prefix_paths << Formula["tbb"].prefix
    cmake_prefix_paths << Formula["utf8cpp"].prefix
    cmake_prefix_paths << Formula["vtk"].prefix
    cmake_prefix_paths << Formula["xerces-c"].prefix
    cmake_prefix_paths << Formula["xz"].prefix
    cmake_prefix_paths << Formula["zlib"].prefix

    if OS.linux?
      cmake_prefix_paths << Formula["mesa-glu"].prefix
      cmake_prefix_paths << Formula["mesa"].prefix
      cmake_prefix_paths << Formula["libx11"].prefix
      cmake_prefix_paths << Formula["libxcb"].prefix
    end

    cmake_prefix_paths << Formula["yaml-cpp"].prefix if build.head?
    cmake_prefix_paths << Formula["opencascade"].prefix if build.head?

    cmake_prefix_path_string = cmake_prefix_paths.join(";")

    # Check if Xcode.app exists
    if File.directory?("/Applications/Xcode.app")
      apl_sdk = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
      apl_frmwks ="#{apl_sdk}/System/Library/Frameworks"
      cmake_ar = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ar"
      cmake_ld = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld"

    else
      apl_sdk = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
      apl_frmwks = "#{apl_sdk}/System/Library/Frameworks"
      cmake_ar = "/Library/Developer/CommandLineTools/usr/bin/ar"
      cmake_ld = "/Library/Developer/CommandLineTools/usr/bin/ld"
    end

    # TODO: stub out the below cmake vars
    # -DCMAKE_OSX_SYSROOT=#{cmake_osx_sysroot}
    # -DCMAKE_CXX_FLAGS="-fuse-ld=lld"
    # -DBUILD_ENABLE_CXX_STD=C++17
    # -DCMAKE_INSTALL_RPATH=#{prefix}/lib
    # -DCMAKE_INSTALL_RPATH=#{rpath}
    # -DBUILD_DRAWING=1
    # -DBUILD_SMESH=1
    # -DFREECAD_USE_EXTERNAL_KDL=1
    # -DBUILD_FEM_NETGEN=0
    # -DFREECAD_USE_QTWEBMODULE=#{qtwebmodule}
    # HDF5_LIBRARIES HDF5_HL_LIBRARIES
    # -DCMAKE_EXE_LINKER_FLAGS="-v"

    if OS.mac?
      arch = Hardware::CPU.arch.to_s
      fver = OS::Mac.full_version.to_s

      args_macos_only = %W[
        -DCMAKE_OSX_ARCHITECTURES=#{arch}
        -DCMAKE_OSX_DEPLOYMENT_TARGET=#{fver}
        -DCMAKE_AR=#{cmake_ar}
        -DCMAKE_LINKER=#{cmake_ld}
        -DCMAKE_INSTALL_NAME_TOOL:FILEPATH=/usr/bin/install_name_tool
        -DOPENGL_INCLUDE_DIR=#{apl_frmwks}/OpenGL.framework
        -DOPENGL_gl_LIBRARY=#{apl_frmwks}/OpenGL.framework
        -DOPENGL_GLU_INCLUDE_DIR=#{apl_frmwks}/OpenGL.framework
        -DOPENGL_glu_LIBRARY=#{apl_frmwks}/OpenGL.framework
        -D_Qt5UiTools_RELEASE_AppKit_PATH=#{apl_frmwks}/AppKit.framework
        -D_Qt5UiTools_RELEASE_Metal_PATH=#{apl_frmwks}/Metal.framework
        -D_Qt5UiTools_RELEASE_DiskArbitration_PATH=#{apl_frmwks}/DiskArbitration.framework
        -D_Qt5UiTools_RELEASE_IOKit_PATH=#{apl_frmwks}/IOKit.framework
        -D_Qt5UiTools_RELEASE_OpenGL_PATH=#{apl_frmwks}/OpenGL.framework
        -D_Qt5UiTools_RELEASE_AGL_PATH=#{apl_frmwks}/AGL.framework
      ]
    end

    if OS.linux?
      ninja_bin = Formula["ninja"].opt_bin/"ninja"
      clang_cc = Formula["llvm"].opt_bin/"clang"
      clang_cxx = Formula["llvm"].opt_bin/"clang++"
      clang_ld = Formula["llvm"].opt_bin/"lld"
      clang_ar = Formula["llvm"].opt_bin/"llvm-ar"
      openglu_inc_dir = Formula["mesa"].opt_include

      puts "----------------------------------------------------"
      puts openglu_inc_dir
      puts "----------------------------------------------------"

      args_linux_only = %W[
        -GNinja
        -DCMAKE_MAKE_PROGRAM=#{ninja_bin}
        -DX11_X11_INCLUDE_PATH=#{hbp}/opt/libx11/include/X11
        -DCMAKE_C_COMPILER=#{clang_cc}
        -DCMAKE_CXX_COMPILER=#{clang_cxx}
        -DCMAKE_LINKER=#{clang_ld}
        -DCMAKE_AR=#{clang_ar}
        -DOPENGL_GLU_INCLUDE_DIR=#{openglu_inc_dir}
      ]
    end

    args = %W[
      -DHOMEBREW_PREFIX=#{hbp}
      -DCMAKE_PREFIX_PATH=#{cmake_prefix_path_string}
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_VERBOSE_MAKEFILE=1
      -DPython3_EXECUTABLE=#{hbp}/opt/python@3.10/bin/python3.10
      -DPython3_INCLUDE_DIRS=#{py_inc_dir}
      -DPython3_LIBRARIES=#{py_lib_path}
      -DFREECAD_USE_PYBIND11=1
      -DCMAKE_BUILD_TYPE=RelWithDebInfo

      -DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=FALSE
      -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=FALSE

      -DCMAKE_IGNORE_PATH=#{hbp}/lib;#{hbp}/include/QtCore;#{hbp}/Cellar/qt;
      -L
    ]

    args << "-DINSTALL_TO_SITEPACKAGES=0" if build.head?

    # NOTE: useful cmake debugging args
    # --trace
    # -L

    ENV.remove "PATH", Formula["pyside@2"].opt_prefix/"bin"
    ENV.remove "PATH", Formula["qt"].opt_prefix/"bin"
    ENV.remove "PATH", Formula["pyqt"].opt_prefix/"bin"

    ENV.remove "PKG_CONFIG_PATH", Formula["pyside@2"].opt_prefix/"lib/pkgconfig"
    ENV.remove "PKG_CONFIG_PATH", Formula["qt"].opt_prefix/"lib/pkgconfig"

    ENV.remove "CMAKE_FRAMEWORK_PATH", Formula["qt"].opt_prefix/"Frameworks"

    # NOTE: ipatch, do not make build dir a sub dir of the src dir
    puts "current working directory: #{Dir.pwd}"
    src_dir = Dir.pwd.to_s
    parent_dir = File.expand_path("..", src_dir)
    build_dir = "#{parent_dir}/build"
    # Create the build directory if it doesn't exist
    mkdir_p(build_dir)
    # Change the working directory to the build directory
    # false positive: `warning: conflicting chdir during another chdir block`
    Dir.chdir(build_dir)
    puts "----------------------------------------------------"
    puts Dir.pwd
    puts "----------------------------------------------------"

    args.concat(args_macos_only) if OS.mac?
    args.concat(args_linux_only) if OS.linux?

    system "cmake", *args, src_dir.to_s
    system "cmake", "--build", build_dir.to_s
    system "cmake", "--install", build_dir.to_s
  end

  def post_install
    if OS.mac?
      ohai "the value of prefix = #{prefix}"
      freecad_path = Pathname.new("#{prefix}/MacOS/FreeCAD")
      freecadcmd_path = Pathname.new("#{prefix}/MacOS/FreeCADCmd")

      ln_s freecad_path.relative_path_from(Pathname.new("#{HOMEBREW_PREFIX}/bin")), "#{HOMEBREW_PREFIX}/bin/freecad",
force: true
      ln_s freecadcmd_path.relative_path_from(Pathname.new("#{HOMEBREW_PREFIX}/bin")),
"#{HOMEBREW_PREFIX}/bin/freecadcmd", force: true
    elsif OS.linux?
      ohai "the value of prefix = #{prefix}"
      freecad_path = Pathname.new("#{bin}/FreeCAD")
      freecadcmd_path = Pathname.new("#{bin}/FreeCADCmd")

      ln_s freecad_path.relative_path_from(Pathname.new("#{HOMEBREW_PREFIX}/bin")), "#{HOMEBREW_PREFIX}/bin/freecad",
force: true
      ln_s freecadcmd_path.relative_path_from(Pathname.new("#{HOMEBREW_PREFIX}/bin")),
"#{HOMEBREW_PREFIX}/bin/freecadcmd", force: true
    end
  end

  def caveats
    <<-EOS
    After installing FreeCAD you may want to do the following:

    1. Due to recent code signing updates with Catalina and newer
       building a FreeCAD.app bundle using the existing python
       script no longer works due to updating the rpaths of the
       copied executables and libraries into a FreeCAD.app
       bundle. Until a fix or work around is made freecad
       is built for CLI by default now.

    2. if freecad launches with runtime errors a common fix
       i use is to force link pyside2@5.15.X so workbenches
       such Draft and Arch have the necessary runtime deps,
       see brew documenation about force linking the above packages

    3. use the absolute path to launch freecad ie.
       #{HOMEBREW_PREFIX}/bin/freecad
       using the above to launch freecad may resolve runtime
       issues related to proxy PySide python module
    EOS
  end

  test do
    # NOTE: make test more robust and accurate
    system "true"
  end
end
