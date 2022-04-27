class Bundle < Formula
  desc "Bundle python libs"
  homepage "https://www.freecadweb.org"
  version "0.20"

  stable do
    url "file:///dev/null"
    sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  end

  depends_on "./shiboken2@5.15.3"
  depends_on "./numpy@1.22.3"  


  def install
    version = "3.10"
    bundle_path = Formula["./shiboken2@5.15.3"].lib/"python#{version}/site-packages"
    #(lib/"python3.10/site-packages/homebrew-shiboken2-bundle.pth").write "#{bundle_path}\n"
    bundle_path = Formula["./numpy@1.22.3"].libexec/"lib/python#{version}/site-packages"
    (lib/"python3.10/site-packages/homebrew-numpy-bundle.pth").write "#{bundle_path}\n"
  end
  

end
