class PythonoccCore < Formula
  desc "Pythonocc provides 3D modeling and dataexchange features. It is intended to CAD/PDM/PLM and BIM related development."
  homepage "https://www.pythonocc.org"
  url "https://github.com/tpaviot/pythonocc-core.git", :using => :git
  version "7.5.0"

  depends_on "./opencascade@7.5.1" => :required
  depends_on "cmake" => :build
  depends_on "./python@3.9.7"

  def install
    mkdir "Build" do
     system "cmake", '-DOCE_LIB_PATH=' + Formula["./opencascade@7.5.1"].lib, '-DOCE_INCLUDE_PATH=' + Formula["#@tap/opencascade@7.5.1"].include + '/opencascade', *std_cmake_args , ".."
     system "make", "-j#{ENV.make_jobs}"
     system "make", "install"
    end
  end
  
  
end