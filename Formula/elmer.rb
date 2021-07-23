class Elmer < Formula
  desc "CFD"
  homepage "https://www.csc.fi/web/elmer"
  version "9.0"
  license "GPL-2.0-only"
  head "https://github.com/ElmerCSC/elmerfem.git", branch: "devel", shallow: false

  stable do
    url "https://github.com/ElmerCSC/elmerfem.git",
      revision: "9352634829dfde24439000571d64438d8c683264"
    version "release-9.0"
  end

  depends_on "cmake" => :build
  depends_on "gcc@10"
  depends_on macos: :high_sierra # no access to sierra test box

  def install
    # `brew style` will fail with lines longer than 118 chars
    args = std_cmake_args + %w[
      -DWITH_ELMERGUI:BOOL=FALSE
      -DWITH_QT5:BOOL=OFF
      -DWITH_MPI:BOOL=FALSE
      -DWITH_LUA:BOOL=FALSE
      -DWITH_Mumps:BOOL=FALSE
    ]

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "install"
    end
  end

  def post_install; end

  def caveats
    <<-EOS
    EOS
  end
end
