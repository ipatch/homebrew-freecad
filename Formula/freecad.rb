class Freecad < Formula
  desc "Parametric 3D modeler"
  homepage "https://www.freecadweb.org"
  version "0.19"
  license "GPL-2.0-only"
  head "https://github.com/freecad/FreeCAD.git", branch: "master", shallow: false

  stable do
    url "https://github.com/FreeCAD/FreeCAD/archive/refs/tags/0.19.1.tar.gz"
    sha256 "5ec0003c18df204f7b449d4ac0a82f945b41613a0264127de3ef16f6b2efa60f"
  end

  #bottle do
  #  root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
  #  sha256 big_sur: "ea3f380ce4998d4fcb82d2dd7139957c4865b35dfbbab18d8d0479676e91aa14"
    # sha256 catalina: "8ef75eb7cea8ca34dc4037207fb213332b9ed27976106fd83c31de1433c2dd29"
  #end

  option "with-debug", "Enable debug build"
  option "with-macos-app", "Build MacOS App bundle"
  option "with-packaging-utils", "Optionally install packaging dependencies"
  option "with-cloud", "Build with CLOUD module"
  option "with-unsecured-cloud", "Build with self signed certificate support CLOUD module"
  option "with-skip-web", "Disable web"
  option "with-vtk9", "Use the vtk9 toolkit."
  
  @@vtk = build.with?('vtk9') ? "./vtk@9.1.0" : "./vtk@8.2.0" 

  depends_on "./swig@4.0.2" => :build
  depends_on "ccache" => :build
  depends_on "cmake" => :build
  depends_on "./boost-python3@1.78.0"
  depends_on "./boost@1.78.0"
  depends_on "./coin@4.0.0"
  depends_on "./matplotlib"
  depends_on "./med-file@4.1.0"
  depends_on "./nglib@6.2.2105"
  depends_on "./opencamlib"
  depends_on "./opencascade@7.5.2"
  depends_on "./pivy"
  depends_on "./pyside2"
  depends_on "./pyside2-tools"
  depends_on "./qt5153"
  depends_on "./shiboken2@5.15.3"
  depends_on @@vtk
  depends_on "./python@3.10.2"
  depends_on "freetype"
  depends_on macos: :high_sierra # no access to sierra test box
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "orocos-kdl"
  depends_on "pkg-config"
  depends_on "webp"
  depends_on "xerces-c"
  depends_on "openssl@1.1"

  def install
    # system "pip3", "install", "six" unless File.exist?("/usr/local/lib/python3.9/site-packages/six.py")
    # we install six with python 
    py = Formula["./python@3.10.2"]
    puts 'Six not found' unless File.exist?("#{py.site_packages}/six.py")
    
    # NOTE: brew clang compilers req, Xcode nowork on macOS 10.13 or 10.14
    if MacOS.version <= :mojave
      ENV["CC"] = Formula["llvm"].opt_bin/"clang"
      ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"
    end
    

    # NOTE: bundle fixes, should integrated in freecad source code
    if build.with? 'macos-app'
      mkdir 'src/MacAppBundle/FreeCAD.app/Contents/ssl'
      File.write('src/MacAppBundle/FreeCAD.app/Contents/ssl/cert.pem', (Formula['openssl@1.1'].openssldir/'cert.pem').read)
      cmakelist = 'src/MacAppBundle/CMakeLists.txt'
      gccfra    = Formula['gcc']
      gcctxt    = gccfra.lib.to_s + '/gcc/' + gccfra.version.to_s.split('.')[0]
      inreplace cmakelist do |ln|
        ln.gsub! 'python2.7', 'python3'
        ln.gsub! '/usr/local', '${HOMEBREW_PREFIX}'  # similar HOMEBREW_PREFIX.to_s 
        ln.gsub! 'Cellar/icu4c', 'Cellar/icu4c@70.1' # formula is renamed with version 
        ln.gsub! 'Cellar/nglib', 'Cellar/nglib@6.2.2105'  # add version to lib 
        ln.gsub! '${CONFIG_NGLIB}', ('${CONFIG_NGLIB} ' + Formula['./nglib@6.2.2105'].opt_prefix/'Contents/MacOS/')
        ln.gsub! '${WEBKIT_FRAMEWORK_DIR}', '' if Hardware::CPU.arm? # do not need for apple silicon, see below
        ln.gsub! 'pkg_check_modules(ICU icu-uc)', "pkg_check_modules(ICU icu-uc)\n\nfind_package(OpenCasCade)\nfind_package(llvm)\n" # from other PR stolen
        ln.gsub! '${MACPORTS_PREFIX}/lib', '/lib ${LLVM_LIBRARY_DIR} ${OCC_LIBRARY_DIR} ' + gcctxt # from other PR + gcc lib path
      end
    end

    python_exe = Formula["./python@3.10.2"].opt_prefix/"bin/python3"
    python_headers = Formula["./python@3.10.2"].opt_prefix/"Frameworks/Python.framework/Headers"

    prefix_paths = ""
    prefix_paths << (Formula["./qt5153"].lib/"cmake;")
    prefix_paths << (Formula["./nglib@6.2.2105"].opt_prefix/"Contents/Resources;")
    prefix_paths << (Formula[@@vtk].lib/"cmake;")
    prefix_paths << (Formula["./opencascade@7.5.2"].lib/"cmake;")
    prefix_paths << (Formula["./med-file@4.1.0"].share/"cmake/;")
    prefix_paths << (Formula["./shiboken2@5.15.3"].lib/"cmake;")
    prefix_paths << (Formula["./pyside2"].lib/"cmake;")
    prefix_paths << (Formula["./coin@4.0.0"].lib/"cmake;")
#    prefix_paths << (Formula["./boost@1.76.0"].lib/"cmake;")
#    prefix_paths << (Formula["./boost-python3@1.76.0"].lib/"cmake;")

    # Disable function which are not available for Apple Silicon
    act = Hardware::CPU.arm? ? "OFF" : "ON"
    web = build.with?("skip-web") ? "OFF" : act

    args = std_cmake_args + %W[
      -DBUILD_QT5=ON
      -DUSE_PYTHON3=1
      -DBUILD_ENABLE_CXX_STD=C++17
      -DBUILD_FEM_NETGEN=1
      -DBUILD_FEM=1
      -DBUILD_FEM_NETGEN:BOOL=ON
      -DBUILD_WEB=#{web}
      -DFREECAD_USE_EXTERNAL_KDL=ON
      -DCMAKE_BUILD_TYPE=#{build.with?("debug") ? "Debug" : "Release"}
      -DPYTHON_EXECUTABLE=#{python_exe}
      -DPYTHON_INCLUDE_DIR=#{python_headers}
      -DCMAKE_PREFIX_PATH=#{prefix_paths}
    ]

    args << "-DFREECAD_CREATE_MAC_APP=1" if build.with? "macos-app"
    args << "-DBUILD_CLOUD=1" if build.with? "cloud"
    args << "-DALLOW_SELF_SIGNED_CERTIFICATE=1" if build.with? "unsecured-cloud"

    system "node", "install", "-g", "app_dmg" if build.with? "packaging-utils"
    
    pth = "#{head? ? latest_head_prefix : prefix}/FreeCAD.app/Contents" if build.with? "macos-app"

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
    
    if build.with? "macos-app"
        File.rename "#{pth}/MacOS/FreeCAD", "#{pth}/MacOS/_freecad"
        File.write "#{pth}/MacOS/FreeCAD", startup_script
        system "chmod +x #{pth}/MacOS/FreeCAD"
        # libexec should be integrated in site-packages and not needed
        system "rm -r #{pth}/libexec" if File.directory?("#{pth}/libexec")
    end 
    
    bin.install_symlink "../MacOS/FreeCAD" => "FreeCAD"
    bin.install_symlink "../MacOS/FreeCADCmd" => "FreeCADCmd"
    (lib/"python3.10/site-packages/homebrew-freecad-bundle.pth").write "#{prefix}/MacOS/\n"
  end
  
  def startup_script
    #very ugly, should be a resource
    return '#!/usr/bin/env bash' + "\n" +
           'export PREFIX=$(dirname "$(dirname "$0")")' + "\n" +
           'export LANG="UTF-8"  # https://forum.freecadweb.org/viewtopic.php?f=22&t=42644' + "\n" +
           'export SSL_CERT_FILE=${PREFIX}/ssl/cert.pem # https://forum.freecadweb.org/viewtopic.php?f=3&t=42825' + "\n" +
           'export GIT_SSL_CAINFO=${PREFIX}/ssl/cert.pem' + "\n" +
           '' + "\n" +
           '"${PREFIX}/MacOS/_freecad" $@'  
  end

  def post_install
    # system "pip3", "install", "six" unless File.exist?("/usr/local/lib/python3.9/site-packages/six.py")
    # we install six with python 
    py = Formula["./python@3.9.7"]
    puts 'Six not found' unless File.exist?("#{py.site_packages}/six.py")
    
    bin.install_symlink "../MacOS/FreeCAD" => "FreeCAD"
    bin.install_symlink "../MacOS/FreeCADCmd" => "FreeCADCmd"
    unless File.exist?("/usr/local/Cellar/freecad/0.19/lib/python3.9/site-packages/homebrew-freecad-bundle.pth")
      (lib/"python3.9/site-packages/homebrew-freecad-bundle.pth").write "#{prefix}/MacOS/\n"
    end
  end

  def caveats
    <<-EOS
    After installing FreeCAD you may want to do the following:

    1. Amend your PYTHONPATH environmental variable to point to
       the FreeCAD directory
         export PYTHONPATH=#{bin}:$PYTHONPATH
    EOS
  end
end
