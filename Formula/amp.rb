class Amp < Formula
  desc "Text editor for your terminal"
  homepage "https://amp.rs"
  url "https://github.com/jmacdonald/amp/archive/0.6.2.tar.gz"
  sha256 "9279efcecdb743b8987fbedf281f569d84eaf42a0eee556c3447f3dc9c9dfe3b"
  license "GPL-3.0-or-later"
  revision 1
  head "https://github.com/jmacdonald/amp.git"

  bottle do
    sha256 cellar: :any_skip_relocation, big_sur:     "01ab2e28990824907fdeed4ac093f2f42a9719c21cbc0ebe655406b77a24b44e"
    sha256 cellar: :any_skip_relocation, catalina:    "6d91e4902ead60e50e7dd5b7faed62a4f41999433b321e2b48682d8e8f057f2c"
    sha256 cellar: :any_skip_relocation, mojave:      "59f96770d9e4e166c6eabfb359ada98c41edece8b2fbb877b4e855977445aaa2"
    sha256 cellar: :any_skip_relocation, high_sierra: "96ed5e0a0ba3d05358c840ee0ca157d75ca5f4613fc0e152465806d9950bfa9e"
  end

  depends_on "cmake" => :build
  depends_on "rust" => :build

  uses_from_macos "libiconv"

  def install
    # Upstream specifies very old versions of onig_sys/cc that
    # cause issues when using Homebrew's clang shim on Apple Silicon.
    # Forcefully upgrade `onig_sys` and `cc` to slightly newer versions
    # that enable a succesful build.
    # https://github.com/jmacdonald/amp/issues/222
    inreplace "Cargo.lock" do |f|
      f.gsub! "68.0.1", "68.2.1"
      f.gsub! "5c6be7c4f985508684e54f18dd37f71e66f3e1ad9318336a520d7e42f0d3ea8e",
              "195ebddbb56740be48042ca117b8fb6e0d99fe392191a9362d82f5f69e510379"
      f.gsub! "1.0.45", "1.0.67"
      f.gsub! "4fc9a35e1f4290eb9e5fc54ba6cf40671ed2a2514c3eeb2b2a908dda2ea5a1be",
              "e3c69b077ad434294d3ce9f1f6143a2a4b89a8a2d54ef813d85003a4fd1137fd"
    end

    system "cargo", "install", *std_cargo_args
  end

  test do
    input, _, wait_thr = Open3.popen2 "script -q /dev/null"
    input.puts "stty rows 80 cols 43 && #{bin}/amp test.txt"
    sleep 1
    # switch to insert mode and add data
    input.putc "i"
    sleep 1
    input.puts "test data"
    # escape to normal mode, save the file, and quit
    input.putc "\e"
    sleep 1
    input.putc "s"
    sleep 1
    input.putc "Q"

    assert_match "test data\n", (testpath/"test.txt").read
  ensure
    Process.kill("TERM", wait_thr.pid)
  end
end
