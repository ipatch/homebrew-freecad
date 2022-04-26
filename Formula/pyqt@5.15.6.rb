class PyqtAT5152 < Formula
  desc "Python bindings for v5 of Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/download5"
  url "https://files.pythonhosted.org/packages/3b/27/fd81188a35f37be9b3b4c2db1654d9439d1418823916fe702ac3658c9c41/PyQt5-5.15.6.tar.gz"
  sha256 "80343bcab95ffba619f2ed2467fd828ffeb0a251ad7225be5fc06dcc333af452"
  license "GPL-3.0-only"

  livecheck do
    url :stable
  end

  #bottle do
  #  root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
  #  sha256 cellar: :any, big_sur:   "7bb680628800decb3c84adc40081fa44f8151c5241ede9c5534af16fe41612e0"
  #  sha256 cellar: :any, catalina:  "25424bdc32b5a43929e637f2e6c0f1bc3b20bf03c13756ea7ba80bec819a9d43"
  #  sha256 cellar: :any, mojave:    "6b0a2fa3f3531cd22d41ca6d16b9a0383f7a8cfcf269ba3fbf96b01442754ea4"
  #end

  keg_only "also provided by core"

  depends_on "./python@3.10.2"
  depends_on "./qt5153"
  depends_on "./sip@6.6.1"

  # extra components
   resource "PyQt5-sip" do
     url "https://files.pythonhosted.org/packages/b1/40/dd8f081f04a12912b65417979bf2097def0af0f20c89083ada3670562ac5/PyQt5_sip-12.9.0.tar.gz"
     sha256 "d3e4489d7c2b0ece9d203ae66e573939f7f60d4d29e089c9f11daa17cfeaae32"
   end

   resource "3d" do
     url "https://files.pythonhosted.org/packages/44/af/58684ce08013c0e16839662844b29cd73259a909982c4d6517ce5ffda05f/PyQt3D-5.15.5.tar.gz"
     sha256 "c025e8a2de12a27e3bd34671d01cac39f78305128cc6cea3f0ba99e4ca3ec41b"
   end

   resource "chart" do
     url "https://files.pythonhosted.org/packages/b3/14/a9fdca9b002f5bf01cf66f9854c65fd6b7ea12523e9e6ef063b0aba0e9e1/PyQtChart-5.15.5.tar.gz"
     sha256 "e2cd55a8a72cef99bc0126f3b1daa914eb5f21e20a70127b6985299f1dc50107"
   end

   resource "datavis" do
     url "https://files.pythonhosted.org/packages/9c/ff/6ba767b4e1dbc32c7ffb93cd5d657048f6a4edf318c5b8810c8931a1733b/PyQtDataVisualization-5.15.5.tar.gz"
     sha256 "8927f8f7aa70857ef00c51e3dfbf6f83dd9f3855f416e0d531592761cbb9dc7f"
   end

   resource "networkauth" do
     url "https://files.pythonhosted.org/packages/85/b6/6b8f30ebd7c15ded3d91ed8d6082dee8aebaf79c4e8d5af77b1172c805c2/PyQtNetworkAuth-5.15.5.tar.gz"
     sha256 "2230b6f56f4c9ad2e88bf5ac648e2f3bee9cd757550de0fb98fe0bcb31217b16"
   end

   resource "webengine" do
     url "https://files.pythonhosted.org/packages/60/66/56e118abb4cddd8e4bea6f89bdec834069b52479fb991748f1b21950811e/PyQtWebEngine-5.15.5.tar.gz"
     sha256 "ab47608dccf2b5e4b950d5a3cc704b17711af035024d07a9b71ad29fc103b941"
   end

   resource "purchasing" do
     url "https://files.pythonhosted.org/packages/41/2a/354f0ae3fa02708719e2ed6a8c310da4283bf9a589e2a7fcf7dadb9638af/PyQtPurchasing-5.15.5.tar.gz"
     sha256 "8bb1df553ba6a615f8ec3d9b9c5270db3e15e831a6161773dabfdc1a7afe4834"
   end

  def install
    version = Language::Python.major_minor_version Formula["./python@3.10.2"].opt_bin/"python3"
    args = ["--confirm-license",
            "--bindir=#{bin}",
            "--destdir=#{lib}/python#{version}/site-packages",
            "--stubsdir=#{lib}/python#{version}/site-packages/PyQt5",
            "--sipdir=#{share}/sip/Qt5",
            # sip.h could not be found automatically
            "--sip-incdir=#{Formula["./sip@6.6.1"].opt_include}",
            "--qmake=#{Formula["./qt5153"].bin}/qmake",
            # Force deployment target to avoid libc++ issues
            "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
            "--designer-plugindir=#{pkgshare}/plugins",
            "--qml-plugindir=#{pkgshare}/plugins",
            "--pyuic5-interpreter=#{Formula["./python@3.10.2"].opt_bin}/python3",
            "--verbose"]

    system Formula["#{@tap}/python@3.10.2"].opt_bin/"python3", "configure.py", *args
    system "make"
    ENV.deparallelize { system "make", "install" }
  end

  test do
    system "#{bin}/pyuic5", "--version"
    system "#{bin}/pylupdate5", "-version"

    system Formula["./python@3.10.2"].opt_bin/"python3", "-c", "import PyQt5"
    %w[
      Gui
      Location
      Multimedia
      Network
      Quick
      Svg
      Widgets
      Xml
    ].each { |mod| system Formula["./python@3.9.7"].opt_bin/"python3", "-c", "import PyQt5.Qt#{mod}" }
  end
end