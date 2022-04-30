class Pivy < Formula
  desc "Python bindings to coin3d"
  homepage "https://github.com/coin3d/pivy"
  url "https://github.com/coin3d/pivy.git",
    tag:      "0.6.6",
    revision: "55e659de7ea346d3caf176d7fe254224d36e4791"
  license "ISC"
  head "https://github.com/coin3d/pivy.git"

  #bottle do
  #  root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
  #  sha256 cellar: :any, big_sur:   "4d40838f8825a183c30ae69f2aee8dc345377190d7e35d13e00a9b1bb6cae2a0"
  #  sha256 cellar: :any, catalina:  "90cb40af64f8827838af9312fd5481c6d52a88bf61c04bdf2b7f6593baad6609"
  #  sha256 cellar: :any, mojave:    "5671c1a87fd30a08c510b88a51bb1e210a65860f17f499f176ba04f63fae00b1"
  #end

  depends_on "./swig@4.0.2" => :build
  depends_on "cmake" => :build
  depends_on "./python@3.10.2" => :build
  depends_on "./coin@4.0.0"

  def install
    python = Formula["./python@3.10.2"].opt_bin/"python3"
    py = libexec/Language::Python.site_packages(python)
    ENV.prepend_create_path "PYTHONPATH", py
    system python, "setup.py", "build"
    system python, "setup.py", "install", "--prefix=#{prefix}", "--install-lib=#{py}"
  end
end
