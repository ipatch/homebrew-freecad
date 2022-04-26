class CythonAT02928 < Formula
  homepage "https://cython.org/"
  url "https://files.pythonhosted.org/packages/cb/da/54a5d7a7d9afc90036d21f4b58229058270cc14b4c81a86d9b2c77fd072e/Cython-0.29.28.tar.gz"
  sha256 "d6fac2342802c30e51426828fe084ff4deb1b3387367cf98976bb2e64b6f8e45"
  license "Apache-2.0"

  keg_only <<~EOS
    this formula is mainly used internally by other formulae.
    Users are advised to use `pip` to install cython
  EOS

  depends_on "./python@3.10.2"
  
  patch do
    url "https://github.com/python/cpython/commit/56f031ec5281723b7c617edfa5748f2ae6a4c347.patch"
    sha256 "88f68af784f03aa1a8eda1475fceb965652a18ea9e32fbb51f4992a2a6d5da1c"
  end

  def install
    python = Formula["./python@3.10.2"].opt_bin/"python3"
    py = libexec/Language::Python.site_packages(python)
    ENV.prepend_create_path "PYTHONPATH", py
    system python, *Language::Python.setup_install_args(libexec),
    "--install-lib=#{py}"

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", PYTHONPATH: ENV["PYTHONPATH"])
  end

  test do
    xy = Language::Python.major_minor_version Formula["./python@3.10.2"].opt_bin/"python3"
    ENV.prepend_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"

    phrase = "You are using Homebrew"
    (testpath/"package_manager.pyx").write "print '#{phrase}'"
    (testpath/"setup.py").write <<~EOS
      from distutils.core import setup
      from Cython.Build import cythonize

      setup(
        ext_modules = cythonize("package_manager.pyx")
      )
    EOS
    system Formula["./python@3.9.7"].opt_bin/"python3", "setup.py", "build_ext", "--inplace"
    assert_match phrase, shell_output("#{Formula["./python@3.10.2"].opt_bin}/python3 -c 'import package_manager'")
  end
end