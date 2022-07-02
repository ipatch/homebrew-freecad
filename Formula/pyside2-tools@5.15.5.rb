class Pyside2ToolsAT5155 < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.15.5-src/pyside-setup-opensource-src-5.15.5.zip"
  sha256 "d1c61308c53636823c1d0662f410966e4a57c2681b551003e458b2cc65902c41"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  head "http://code.qt.io/cgit/pyside/pyside-setup.git", branch: "v5.15.5"

  depends_on "cmake" => :build
  depends_on "./python@3.10.2" => :build
  depends_on "./pyside2@5.15.5"

  def install
    mkdir "macbuild3.10" do
      args = std_cmake_args
      args << "-DUSE_PYTHON_VERSION=3.10"
      args << "../sources/pyside2-tools"

      system "cmake", *args
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end
end
