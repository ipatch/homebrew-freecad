class FcBundlePy312 < Formula
  desc "Meta formula for bundling needed python modules"
  homepage "https://www.freecadweb.org"
  # Dummy URL since no source is being downloaded
  url "file:///dev/null"
  # this version works with the freecad v1rc2 release thus the 0.9.2 versioning
  version "0.9.2"

  # sha of file:///dev/null
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  revision 2

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "342fa84721a1d1df7018ae8a2a5310e72a165275a70897748c119938ad3e072d"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "0a35bff793f2fe170861a0401e129ec23a74dc6d916db9c3eec9c94fdf9a8384"
    sha256 cellar: :any_skip_relocation, ventura:       "48024227b645af0bff6a3f616866eb5897127767e976c5d6e0e8c915f769fb97"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "fa916c83def42476422e0e917e3b031e3da16c5bc5177f22d80572ea13eb3a03"
  end

  depends_on "freecad/freecad/coin3d@4.0.3_py312"
  depends_on "freecad/freecad/med-file@4.1.1_py312"
  depends_on "freecad/freecad/numpy@2.1.1_py312"
  depends_on "freecad/freecad/pybind11_py312"
  depends_on "freecad/freecad/pyside2@5.15.15_py312" # pyside includes the shiboken2 module as well

  resource "six" do
    url "https://files.pythonhosted.org/packages/71/39/171f1c67cd00715f190ba0b100d606d440a28c93c7714febeca8b79af85e/six-1.16.0.tar.gz"
    sha256 "1e61c37477a1626458e36f7b1d82aa5c9b094fa4802892072e49de9c60c4c926"
  end

  def install
    # explicitly set python version
    pyver = "3.12"

    venv_dir = libexec/"vendor"

    # Create a virtual environment
    system "python3.12", "-m", "venv", venv_dir
    venv_pip = venv_dir/"bin/pip"

    # Install the six module using pip in the virtual environment
    # certain freecad workbenches require the python six module
    resource("six").stage do
      system venv_pip, "install", "."
    end

    # Example: Read the contents of the .pth file into a variable
    # shiboken2_pth_contents = \
    # File.read("#{Formula["shiboken2@5.15.11"].opt_prefix}/lib/python#{pyver}/site-packages/shiboken2.pth").strip

    coin3d_pivy_pth_contents =
      File.read("#{Formula["coin3d@4.0.3_py312"].opt_prefix}/lib/python#{pyver}/coin3d_py312-pivy.pth").strip
    medfile_pth_contents =
      File.read("#{Formula["med-file@4.1.1_py312"].opt_prefix}/lib/python#{pyver}/medfile.pth").strip
    numpy_pth_contents =
      File.read("#{Formula["numpy@2.1.1_py312"].opt_prefix}/lib/python#{pyver}/numpy.pth").strip
    pybind11_pth_contents = File.read(
      "#{Formula["pybind11_py312"].opt_prefix}/lib/python#{pyver}/site-packages/homebrew-pybind11.pth",
    ).strip
    pyside2_pth_contents =
      File.read("#{Formula["pyside2@5.15.15_py312"].opt_prefix}/lib/python#{pyver}/pyside2.pth").strip

    site_packages = Language::Python.site_packages("python3.12")
    # {shiboken2_pth_contents}
    pth_contents = <<~EOS
      #{coin3d_pivy_pth_contents}
      #{medfile_pth_contents}
      #{numpy_pth_contents}
      #{pybind11_pth_contents}
      #{pyside2_pth_contents}
      #{venv_dir}/lib/python#{pyver}/site-packages
    EOS
    (prefix/site_packages/"freecad-py-modules.pth").write pth_contents
  end

  def caveats
    <<-EOS
    this formula is required to get necessary python runtime deps
    working with freecad
    EOS
  end

  test do
    # TODO: i think a more sane test is importing the python modules
    # Check if the expected site-packages file exists
    site_packages_file = prefix/"lib/python3.12/site-packages/freecad-py-modules.pth"
    if site_packages_file.exist?
      puts "Test: OK - freecad-py-modules.pth file exists"
    else
      onoe "Test: Error - freecad-py-modules.pth file not found"
    end
  end
end