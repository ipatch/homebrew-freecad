class Pybind11Py310 < Formula
  desc "Seamless operability between C++11 and Python"
  homepage "https://github.com/pybind/pybind11"
  url "https://github.com/pybind/pybind11/archive/refs/tags/v2.11.1.tar.gz"
  sha256 "d475978da0cdc2d43b73f30910786759d593a9d8ee05b1b6846d1eb16c6d2e0c"
  license "BSD-3-Clause"
  head "https://github.com/pybind/pybind11.git", branch: "master", shallow: false

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://ghcr.io/v2/freecad/freecad"
    rebuild 2
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "88d023d8d8645b54d327622956afb1d4461d1033ade5f7285a3bb1704603c470"
    sha256 cellar: :any_skip_relocation, ventura:      "ddbcb69a15c1ed30ef6ebc79e3c2d38c5c10bfd1be55be9d25dddc72611e417d"
    sha256 cellar: :any_skip_relocation, monterey:     "b4c992e746837e56c8f78aa6029ab916e8a81b3032491b3b61e3864c0888c98f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9140d216672dc3c42aacbd33e77f5edf045323c3722de5bcef439e0595664079"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "python@3.10" => [:build, :test]

  on_mojave :or_older do
    depends_on "gettext"
  end

  def python3
    "python3.10"
  end

  def install
    # Install /include and /share/cmake to the global location
    system "cmake", "-S", ".", "-B", "build", "-DPYBIND11_TEST=OFF", "-DPYBIND11_NOPYTHON=ON", *std_cmake_args
    system "cmake", "--install", "build"

    # Install Python package too
    python_exe = Formula["python@3.10"].opt_bin/python3
    system python_exe, "-m", "pip", "install", *std_pip_args(prefix: libexec), "."

    site_packages = Language::Python.site_packages(python_exe)
    pth_contents = "import site; site.addsitedir('#{libexec/site_packages}')\n"
    (prefix/site_packages/"homebrew-pybind11.pth").write pth_contents

    pyversion = Language::Python.major_minor_version(python_exe)
    bin.install libexec/"bin/pybind11-config" => "pybind11-config-#{pyversion}"

    # The newest one is used as the default
    bin.install_symlink "pybind11-config-#{pyversion}" => "pybind11-config"
  end

  def caveats
    <<-EOS
    this is a versioned formula designed to work with the homebrew-freecad tap
    out of the box, the `pybind11` python module will not be accessible
    due to the formula being keg-only
    EOS
  end

  test do
    # NOTE: required env vars due to formula being keg-only
    ENV.append_path "PATH", Formula["pybind11_py310"].opt_bin
    ENV.append_path "PYTHONPATH", "#{Formula["pybind11_py310"].opt_libexec}/lib/python3.10/site-packages"
    ENV.append_path "LD_LIBRARY_PATH", Formula["pybind11_py310"].opt_lib

    (testpath/"example.cpp").write <<~EOS
      #include <pybind11/pybind11.h>

      int add(int i, int j) {
        return i + j;
      }
      namespace py = pybind11;
      PYBIND11_MODULE(example, m) {
        m.doc() = "pybind11 example plugin";
        m.def("add", &add, "A function which adds two numbers");
      }
    EOS

    (testpath/"example.py").write <<~EOS
      import example
      example.add(1,2)
    EOS

    python_exe = "#{Formula["python@3.10"].opt_bin}/python3.10"
    python_config = "#{Formula["python@3.10"].opt_bin}/python3.10-config"
    pyversion = Language::Python.major_minor_version(python_exe)

    # NOTE: ci will fail with trailing `pybind11` in below but not locally
    pybind11_include = Formula["pybind11_py310"].opt_include
    gettext_lib = Formula["gettext"].opt_lib
    python_flags = Utils.safe_popen_read(
      python_config,
      "--cflags",
      "--ldflags",
      "--embed",
    ).split
    system ENV.cxx, "-shared", "-fPIC", "-O3", "-std=c++11", "example.cpp", "-o", "example.so",
      "-I#{pybind11_include}", *python_flags, "-L#{gettext_lib}"
    system python_exe, "example.py"

    test_module = shell_output("#{python_exe} -m pybind11 --includes")
    # Use assert_match method correctly to check if the output includes the expected string
    expected_module_path = "#{Formula["pybind11_py310"].opt_libexec}/lib/python3.10/site-packages/pybind11/include"
    assert_match expected_module_path, test_module

    test_script = shell_output("#{bin}/pybind11-config-#{pyversion} --includes")
    assert_match test_module, test_script

    test_module = shell_output("#{python_exe} -m pybind11 --includes")
    test_script = shell_output("#{bin}/pybind11-config --includes")
    assert_match test_module, test_script
  end
end
