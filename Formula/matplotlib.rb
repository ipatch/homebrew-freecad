class DvipngRequirement < Requirement
  fatal false
  cask "mactex"

  satisfy { which("dvipng") }

  def message
    s = <<-EOS
      `dvipng` not found. This is optional for Matplotlib.
    EOS
    s += super
    s
  end
end

class NoExternalPyCXXPackage < Requirement
  fatal false

  satisfy do
    !quiet_system "python", "-c", "import CXX"
  end

  def message
    <<-EOS
    *** Warning, PyCXX detected! ***
    On your system, there is already a PyCXX version installed, that will
    probably make the build of Matplotlib fail. In python you can test if that
    package is available with `import CXX`. To get a hint where that package
    is installed, you can:
        python -c "import os; import CXX; print(os.path.dirname(CXX.__file__))"
    See also: https://github.com/Homebrew/homebrew-python/issues/56
    EOS
  end
end

class Matplotlib < Formula
  desc "Python 2D plotting library"
  homepage "https://matplotlib.org"
  url "https://files.pythonhosted.org/packages/21/37/197e68df384ff694f78d687a49ad39f96c67b8d75718bc61503e1676b617/matplotlib-3.4.3.tar.gz"
  sha256 "fc4f526dfdb31c9bd6b8ca06bf9fab663ca12f3ec9cdf4496fb44bc680140318"
  head "https://github.com/matplotlib/matplotlib.git"

  #bottle do
    # root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
    # sha256 cellar: :any, big_sur:   "150759a0b8ea4e159e0a4ed1229340775e90ab6b47ab397fe1ec040250ceef94"
    #sha256 cellar: :any, catalina:  "7f3d19de027ab6dd81e6b6021315682bcfe54f410bb29a1fb1cea0ba0a8515eb"
    # sha256 cellar: :any, mojave:    "5331f0dca64b5d8a583944c6d597937833943ebc02ab3da54762baccd6d38620"
  # end

  option "with-cairo", "Build with cairo backend support"
  option "with-tex", "Build with tex support"

  deprecated_option "with-gtk3" => "with-gtk+3"

  depends_on NoExternalPyCXXPackage => :build
  depends_on "pkg-config" => :build
  depends_on DvipngRequirement if build.with? "tex"
  depends_on "freecad/freecad/numpy@1.21.2"
  depends_on "freecad/freecad/python@3.9.7"
  depends_on "freetype"
  depends_on "ghostscript"
  depends_on "gtk+3"
  depends_on "libpng"
  depends_on "py3cairo" if build.with?("cairo") && (build.with? "python3")

  requires_py3 = []
  requires_py3 << "with-python3"
  depends_on "pygobject3" => requires_py3 if build.with? "gtk+3"
  depends_on "tcl-tk"

  cxxstdlib_check :skip

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/1e/5c/3d7b3d91a86d71faf5038c5d259ed36b5d05b7804648e2c43251d574a6e6/setuptools-58.2.0.tar.gz"
    sha256 "2c55bdb85d5bb460bd2e3b12052b677879cffcf46c0c688f2e5bf51d36001145"
  end

  resource "Cycler" do
    url "https://files.pythonhosted.org/packages/c2/4b/137dea450d6e1e3d474e1d873cd1d4f7d3beed7e0dc973b06e8e10d32488/cycler-0.10.0.tar.gz"
    sha256 "cd7b2d1018258d7247a71425e9f26463dfb444d411c39569972f4ce586b0c9d8"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/c1/47/dfc9c342c9842bbe0036c7f763d2d6686bcf5eb1808ba3e170afdb282210/pyparsing-2.4.7.tar.gz"
    sha256 "c203ec8783bf771a155b207279b9bccb8dea02d8f0c9e5f8ead507bc3246ecc1"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/4c/c4/13b4776ea2d76c115c1d1b84579f3764ee6d57204f6be27119f13a61d0a9/python-dateutil-2.8.2.tar.gz"
    sha256 "0123cacc1627ae19ddf3c27a5de5bd67ee4586fbdd6440d9748f8abb483d3e86"
  end

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/e3/8e/1cde9d002f48a940b9d9d38820aaf444b229450c0854bdf15305ce4a3d1a/pytz-2021.3.tar.gz"
    sha256 "acad2d8b20a1af07d4e4c9d2e9285c5ed9104354062f275f3fcd88dcef4f1326"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/71/39/171f1c67cd00715f190ba0b100d606d440a28c93c7714febeca8b79af85e/six-1.16.0.tar.gz"
    sha256 "1e61c37477a1626458e36f7b1d82aa5c9b094fa4802892072e49de9c60c4c926"
  end

  def install
    # NOTE: freecad python no pip3 bin in opt dir use Cellar
    # NOTE: pytz is already inculded by the resources.
    #system "#{HOMEBREW_PREFIX}/Cellar/python@3.9.7/3.9.7_1/bin/pip3", "install", "pytz"
    system Formula["./python@3.9.7"].opt_bin.to_s+"/python3", "-mpip", "install", "--prefix=#{prefix}", "."
    version = "3.9"
    bundle_path = libexec/"lib/python#{version}/site-packages"
    bundle_path.mkpath
    ENV.prepend_path "PYTHONPATH", bundle_path
    res = if version.to_s.start_with? "2"
      resources.map(&:name).to_set
    else
      resources.map(&:name).to_set - ["backports.functools_lru_cache", "subprocess32"]
    end
    p(*Language::Python.setup_install_args(libexec))
    res.each do |r|
      resource(r).stage do
        system Formula["./python@3.9.7"].opt_bin.to_s+"/python3", *Language::Python.setup_install_args(libexec)
      end
    end
    (lib/"python#{version}/site-packages/homebrew-matplotlib-bundle.pth").write "#{bundle_path}\n"

    system Formula["./python@3.9.7"].opt_bin.to_s+"/python3", *Language::Python.setup_install_args(prefix)
  end

  def caveats
    s = <<-EOS
      If you want to use the `wxagg` backend, do `brew install wxpython`.
      This can be done even after the matplotlib install.
    EOS
    if build.with?("python") && !Formula["python"].installed?
      homebrew_site_packages = Language::Python.homebrew_site_packages
      user_site_packages = Language::Python.user_site_packages "python"
      s += <<-EOS
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you may need to
        ensure that the brewed packages come earlier in Python's sys.path with:
          mkdir -p #{user_site_packages}
          echo 'import sys; sys.path.insert(1, "#{homebrew_site_packages}")' >> #{user_site_packages}/homebrew.pth
      EOS
    end
    s
  end

  test do
    ENV["PYTHONDONTWRITEBYTECODE"] = "1"
    ENV.prepend_path "PATH", Formula["python"].opt_libexec/"bin"

    Language::Python.each_python(build) do |python, _|
      system python, "-c", "import matplotlib"
    end
  end
end
