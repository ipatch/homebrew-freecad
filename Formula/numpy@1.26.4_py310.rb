class NumpyAT1264Py310 < Formula
  include Language::Python::Virtualenv
  desc "Package for scientific computing with Python"
  homepage "https://www.numpy.org/"
  license "BSD-3-Clause"
  head "https://github.com/numpy/numpy.git", branch: "main"

  stable do
    url "https://files.pythonhosted.org/packages/65/6e/09db70a523a96d25e115e71cc56a6f9031e7b8cd166c1ac8438307c14058/numpy-1.26.4.tar.gz"
    sha256 "2a02aba9ed12e4ac4eb3ea9421c420301a0c6460d9830d74a9df87efa4912010"

    depends_on "python-setuptools" => :build
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "7652e8524ea71df1ffad802afe0d8e63d389d85fa0a620e1baf7588a58ca6987"
    sha256 cellar: :any_skip_relocation, ventura:      "3120905c304ae136cb5338d4071b32f756435a1bde77ea39df0bb980b7e3c406"
    sha256 cellar: :any_skip_relocation, monterey:     "c9d07f8c2ca41933c8e1a24c2365c607d03ec71f82733059cf7e31ca60ac52b6"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f0ec1746a4b68baf95ced50fd4e85ff566763e07414329ce093b34f36a276e0f"
  end

  keg_only :versioned_formula

  depends_on "cython" => :build
  depends_on "gcc" => :build # for gfortran
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "python@3.10" => [:build, :test]
  depends_on "openblas" if OS.linux?

  fails_with gcc: "5"

  # NOTE: `brew update-python-resources` check for outdated py resources
  resource "meson-python" do
    url "https://files.pythonhosted.org/packages/a2/3b/276b596824a0820987fdcc7721618453b4f9a8305fe20b611a00ac3f948e/meson_python-0.15.0.tar.gz"
    sha256 "fddb73eecd49e89c1c41c87937cd89c2d0b65a1c63ba28238681d4bd9484d26f"
  end

  resource "tomli" do
    url "https://files.pythonhosted.org/packages/c0/3f/d7af728f075fb08564c5949a9c95e44352e23dee646869fa104a3b2060a3/tomli-2.0.1.tar.gz"
    sha256 "de526c12914f0c550d15924c62d72abc48d6fe7364aa87328337a31007fe8a4f"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/ee/b5/b43a27ac7472e1818c4bafd44430e69605baefe1f34440593e0332ec8b4d/packaging-24.0.tar.gz"
    sha256 "eb82c5e3e56209074766e6885bb04b8c38a0c015d0a30036ebe7ece34c9989e9"
  end

  resource "pyproject-metadata" do
    url "https://files.pythonhosted.org/packages/38/af/b0e6a9eba989870fd26e10889446d1bec2e6d5be0a1bae2dc4dcda9ce199/pyproject-metadata-0.7.1.tar.gz"
    sha256 "0a94f18b108b9b21f3a26a3d541f056c34edcb17dc872a144a15618fed7aef67"
  end

  resource "cython" do
    url "https://files.pythonhosted.org/packages/0e/17/c5b026cea7a634ee3b8950a7be16aaa49deeb3b9824ba5e81c13ac26f3c4/Cython-3.0.9.tar.gz"
    sha256 "a2d354f059d1f055d34cfaa62c5b68bc78ac2ceab6407148d47fb508cf3ba4f3"
  end

  def python3
    "python3.10"
  end

  def install
    virtualenv_install_with_resources using: "python@3.10"

    # Prepend the installation path of mesonpy to PYTHONPATH
    ENV.prepend_path "PYTHONPATH", libexec/"lib/python3.10/site-packages"
    ENV.prepend_path "PATH", Formula["cython"].opt_libexec/"bin"

    # NOTE: https://stackoverflow.com/a/69869531/708807
    if OS.mac?
      config = <<~EOS
        [accelerate]
        libraries = Accelerate, vecLib
      EOS

      Pathname("site.cfg").write config
    end

    site_packages = Language::Python.site_packages(python3)
    ENV.prepend_path "PYTHONPATH", Formula["cython"].opt_libexec/site_packages

    if OS.mac?
      ENV["NPY_LAPACK_ORDER"] = "accelerate"
      system python3, "setup.py", "build"
      # system python3, "setup.py", "--help-commands"
      # system python3, "setup.py", "install", "--help"
      system python3, "setup.py", "install",
        "--prefix=#{prefix}", \
        "--install-lib=#{lib}/python3.10/site-packages", \
        "--install-scripts=#{prefix}"
    else
      system python3, "-m", "pip", "install", *std_pip_args, ".",
        "-Csetup-args=-Dblas=openblas",
        "-Csetup-args=-Dlapack=openblas"
    end
  end

  def post_install
    # explicitly set python version
    python_version = "3.10"

    # Unlink the existing .pth file to avoid reinstall issues
    pth_file = lib/"python#{python_version}/numpy.pth"
    pth_file.unlink if pth_file.exist?

    ohai "Creating .pth file for numpy@1.26.4_py310 module"
    # write the .pth file to the parent dir of site-packages
    (lib/"python#{python_version}/numpy.pth").write <<~EOS
      import site; site.addsitedir('#{lib}/python#{python_version}/site-packages/')
    EOS
  end

  def caveats
    <<~EOS
      1. this is a versioned formula specifically setup  to work with
         the homebrew-freecad tap.

      2. to use the numpy python module the fc_bundle needs to be installed

      3. on macos this python module is built against the apple accelerate.framework
    EOS
  end

  test do
    ENV.append_path "PYTHONPATH", Formula["numpy@1.26.4_py310"].opt_prefix/Language::Python.site_packages(python3)

    system Formula["python@3.10"].opt_bin/"python3.10", "-c", <<~EOS
      import numpy as np
      t = np.ones((3,3), int)
      assert t.sum() == 9
      assert np.dot(t, t).sum() == 27
    EOS
  end
end
