class Pyqtbuilder < Formula
  include Language::Python::Virtualenv

  desc "Tool to build PyQt"
  homepage "https://www.riverbankcomputing.com/software/pyqt-builder/intro"
  url "https://files.pythonhosted.org/packages/8b/5f/1bd49787262ddce37b826ef49dcccf5a9970facf0ed363dee5ee233e681d/PyQt-builder-1.12.2.tar.gz"
  sha256 "f62bb688d70e0afd88c413a8d994bda824e6cebd12b612902d1945c5a67edcd7"
  license any_of: ["GPL-2.0-only", "GPL-3.0-only"]
  head "https://www.riverbankcomputing.com/hg/PyQt-builder", using: :hg

  depends_on "./python@3.10.2"
  depends_on "./sip@6.6.1"

  def install
    python = Formula["./python@3.10.2"].opt_bin/"python3"
    py = libexec/Language::Python.site_packages(python)
    system python, *Language::Python.setup_install_args(prefix), "--install-lib=#{py}"
  end

  test do
    system bin/"pyqt-bundle", "-V"
    system Formula["./python@3.10.2"].opt_bin/"python3", "-c", "import pyqtbuild"
  end
end