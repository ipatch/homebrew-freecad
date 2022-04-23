class PythonoccCore < Formula
  desc "Pythonocc provides 3D modeling and dataexchange features. It is intended to CAD/PDM/PLM and BIM related development."
  homepage "https://www.pythonocc.org"
  url "https://github.com/tpaviot/pythonocc-core.git", :using => :git, :revision => '86c5f52647e779b1d0a5209d9d06eb6d3efd6d5b'
  version "7.5.2"

  depends_on "./opencascade@7.5.3" => :required
  depends_on "cmake" => :build
  depends_on "./python@3.10.2"

  def install
    py = Formula["./python@3.10.2"]
    ENV.prepend_create_path "PYTHONPATH", py.site_packages 
    version = "3.10"
    bundle_path = libexec/"lib/python#{version}/site-packages"
    bundle_path.mkpath
    
    inreplace 'CMakeLists.txt' do |ln|
        ln.gsub! 'execute_process(COMMAND ${Python3_EXECUTABLE} -c "from distutils.sysconfig import get_python_lib; import os;print(get_python_lib())" OUTPUT_VARIABLE python_lib OUTPUT_STRIP_TRAILING_WHITESPACE)', ''
        ln.gsub! '${python_lib}', bundle_path
    end    
    
    mkdir "Build" do
     system "cmake", '-DOCE_LIB_PATH=' + Formula["./opencascade@7.5.3"].lib, '-DOCE_INCLUDE_PATH=' + Formula["./opencascade@7.5.3"].include + '/opencascade', *std_cmake_args , ".."
     system "make", "-j#{ENV.make_jobs}"
     system "make", "install"
    end
    
  (lib/"python#{version}/site-packages/homebrew-pythonocc-core--bundle.pth").write "#{bundle_path}\n"
  # system Formula["./python@3.9.7"].opt_bin.to_s+"/python3", *Language::Python.setup_install_args(prefix)    
  end
  
  
end