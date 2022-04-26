class SipAT661 < Formula
  include Language::Python::Virtualenv
  
  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://www.riverbankcomputing.com/software/sip/intro"
  url "https://files.pythonhosted.org/packages/c6/08/34642c4db19e9d41f43640547c5a997cb9b12b512f8c61d0d476e8b9e883/sip-6.6.1.tar.gz"
  sha256 "696c575c72144122701171f2cc767fe6cc87050ea755a04909152a8508ae10c3"
  license any_of: ["GPL-2.0-only", "GPL-3.0-only"]
  revision 1
  head "https://www.riverbankcomputing.com/hg/sip", using: :hg

  livecheck do
    url "https://riverbankcomputing.com/software/sip/download"
    regex(/href=.*?sip[._-]v?(\d+(\.\d+)+)\.t/i)
  end

  #bottle do
  #  root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
  #  sha256 cellar: :any_skip_relocation, big_sur:   "a3e1a54c30560552e7c4dc4bd0da95925be88c7eef2a9349b72e11b24f827616"
  #  sha256 cellar: :any_skip_relocation, catalina:  "c3b3dafcf16f0e65bea4ba6daf62d8e15394ee7201073008a7c7aa22c9864e81"
  #  sha256 cellar: :any_skip_relocation, mojave:    "b40db60f080738c764b35d9ebffac8455455ceda258da914b7b2cbbc89939e9e"
  #end

  keg_only :versioned_formula

  depends_on "./python@3.10.2"
  # keg_only "provided by homebrew core"

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/df/9e/d1a7217f69310c1db8fdf8ab396229f55a699ce34a203691794c5d1cad0c/packaging-21.3.tar.gz"
    sha256 "dd47c42927d89ab911e606518907cc2d3a1f38bbd026385970643f9c5b8ecfeb"
  end

  resource "ply" do
    url "https://files.pythonhosted.org/packages/e5/69/882ee5c9d017149285cab114ebeab373308ef0f874fcdac9beb90e0ac4da/ply-3.11.tar.gz"
    sha256 "00c7c1aaa88358b9c765b6d3000c6eec0ba42abca5351b095321aef446081da3"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/31/df/789bd0556e65cf931a5b87b603fcf02f79ff04d5379f3063588faaf9c1e4/pyparsing-3.0.8.tar.gz"
    sha256 "7bf433498c016c4314268d95df76c81b842a4cb2b276fa3312cfb1e1d85f6954"
  end

  resource "toml" do
    url "https://files.pythonhosted.org/packages/be/ba/1f744cdc819428fc6b5084ec34d9b30660f6f9daaf70eead706e3203ec3c/toml-0.10.2.tar.gz"
    sha256 "b3bda1d108d5dd99f4a20d24d9c348e91c4db7ab1b749200bded2f839ccbe68f"
  end

  # def install
  #   python = Formula["python@3.9.6"]
  #   venv = virtualenv_create(libexec, "/usr/local/bin/python3")
  #   resources.each do |r|
  #     venv.pip_install r
  #   end

  #   system "/usr/local/bin/python3", *Language::Python.setup_install_args(prefix)

  #   site_packages = Language::Python.site_packages(python)
  #   pth_contents = "import site; site.addsitedir('#{libexec/site_packages}')\n"
  #   (prefix/site_packages/"homebrew-sip.pth").write pth_contents
  # end

  def install
    python = Formula["./python@3.10.2"].opt_bin/"python3"
    py = libexec/Language::Python.site_packages(python)
    venv = virtualenv_create(libexec, python)
    resources.each do |r|
      venv.pip_install r
    end

    system python, *Language::Python.setup_install_args(prefix), "--install-lib=#{py}"

    pth_contents = "import site; site.addsitedir('#{libexec/py}')\n"
    (prefix/site_packages/"homebrew-sip.pth").write pth_contents
  end

  def post_install
    (HOMEBREW_PREFIX/"share/sip").mkpath
  end

  test do
    (testpath/"test.h").write <<~EOS
      #pragma once
      class Test {
      public:
        Test();
        void test();
      };
    EOS
    (testpath/"test.cpp").write <<~EOS
      #include "test.h"
      #include <iostream>
      Test::Test() {}
      void Test::test()
      {
        std::cout << "Hello World!" << std::endl;
      }
    EOS
    (testpath/"test.sip").write <<~EOS
      %Module test
      class Test {
      %TypeHeaderCode
      #include "test.h"
      %End
      public:
        Test();
        void test();
      };
    EOS

    system ENV.cxx, "-shared", "-Wl,-install_name,#{testpath}/libtest.dylib",
                    "-o", "libtest.dylib", "test.cpp"
    system bin/"sip", "-b", "test.build", "-c", ".", "test.sip"
  end
end
