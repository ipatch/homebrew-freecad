class Elmer < Formula
  desc "CFD"
  homepage "https://www.csc.fi/web/elmer"
  version "9.0"
  license "GPL-2.0-only"
  head "https://github.com/ElmerCSC/elmerfem.git", branch: "devel", shallow: false

  stable do
    url "https://github.com/ElmerCSC/elmerfem.git",
      revision: "9352634829dfde24439000571d64438d8c683264"
    version "release-9.0"
  end

  depends_on "cmake" => :build
  # depends_on "./opencascade@7.5.0"
  # depends_on "./python3.9"
  # depends_on "./qt5152"
  # depends_on "./qwtelmer" # if builds gui version of app
  # depends_on "./vtk@8.2.0"
  depends_on "gcc@10"
  # depends_on macos: :high_sierra # no access to sierra test box
  # depends_on "open-mpi"
  # depends_on "openblas"
  # depends_on "webp"
  # depends_on "xerces-c"

  def install
    # `brew style` will fail with lines longer than 118 chars
    #args = std_cmake_args + %W[
    #  -DWITH_MPI:BOOLEAN=TRUE
    #  -DWITH_OpenMP:BOOL=TRUE
    #  -DWITH_ELMERGUI:BOOL=TRUE
    #  -DWITH_QT5:BOOL=TRUE
    #  -DQWT_INCLUDE_DIR=
    #    #{Formula["freecad/freecad/qwtelmer"].opt_lib}/qwt.framework/Headers
    #  -DCMAKE_PREFIX_PATH=
    #    #{Formula["freecad/freecad/qt5152"].opt_prefix}/lib/cmake
    #    #{Formula["freecad/freecad/vtk@8.2.0"].opt_prefix}/lib/cmake
    #    #{Formula["freecad/freecad/opencascade@7.5.0"].opt_prefix}/lib/cmake
    #]
      # FC=gfortran-#{Formula["gcc"].any_installed_version.major}
    # F77=gfortran-#{Formula["gcc"].any_installed_version.major}

    # Flag for compatibility with GCC 10
    # https://lists.mpich.org/pipermail/discuss/2020-January/005863.html
    # args << "FFLAGS=-fallow-argument-mismatch"
    # args << "CXXFLAGS=-Wno-deprecated"
    # args << "CFLAGS=-fgnu89-inline -Wno-deprecated"


    # exten = (OS.mac?) ? "dylib" : "so"
    # cmake_args << "-DBLAS_LIBRARIES:STRING=#{Formula["openblas"].opt_lib}/libopenblas.#{exten};-lpthread"
    # cmake_args << "-DLAPACK_LIBRARIES:STRING=#{Formula["openblas"].opt_lib}/libopenblas.#{exten};-lpthread"

    # ENV['CC'] = '/usr/local/bin/gcc-10'

    # tmp
    # args << "--preset=intel"

    # args << "-DCMAKE_C_FLAGS="-F+Formula["freecad/freecad/qwtelmer"].opt_prefix+"/lib/"+"-framework qwt"

    args = ""

    # args << "-DWITH_ELMERGUI:BOOL=TRUE "
    args << "-DWITH_ELMERGUI:BOOL=FALSE "
    # args << "-DWITH_QT5:BOOL=ON "
    args << "-DWITH_QT5:BOOL=OFF "

    # args << "-DWITH_MPI:BOOL=TRUE "
    args << "-DWITH_MPI:BOOL=FALSE "

    args << "-DWITH_LUA:BOOL=TRUE "
    args << "-DWITH_LUA:BOOL=FALSE "

    args << "-DWITH_Mumps:BOOL=FALSE "

    # args << "-DQWT_INCLUDE_DIR=/usr/local/opt/qwtelmer/lib/qwt.framework/Headers"
    
    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "install"
    end
  end

  def post_install; end

  def caveats
    <<-EOS
    EOS
  end
end
