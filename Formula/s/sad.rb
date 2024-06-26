class Sad < Formula
  desc "CLI search and replace | Space Age seD"
  homepage "https://github.com/ms-jpq/sad"
  url "https://github.com/ms-jpq/sad/archive/refs/tags/v0.4.30.tar.gz"
  sha256 "2f16ef0b904e27220491382d3de9e60ea1d5f62245869205c54a6d33f9e5dc34"
  license "MIT"
  head "https://github.com/ms-jpq/sad.git", branch: "senpai"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "7f9a906c12839def65ad44065df55ab109dbaf86acf958484d6a608091d396b4"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "8cd63d04aeda1c31cfa7067702adaa8bbb612b96a145992165551f07d9d65251"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "e88cc7b8330c3746bb3e7d6bf9fa4503a5a06a8ccf878111fe86f383b8f3a259"
    sha256 cellar: :any_skip_relocation, sonoma:         "a548687bf5565b60e2999caec378ec8e238d5b0bd2f8076c7be3c134ade5a2df"
    sha256 cellar: :any_skip_relocation, ventura:        "efdb18bc37d65781ed2fd4b22556f26c602b456fd125df2648f93f4f0520691b"
    sha256 cellar: :any_skip_relocation, monterey:       "06e666d7c5df129a898a642ad140098beedb630e163da0aec4cfd877b52da9e1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "a2864b62bf92f199e527d6e9725819c4674abc61bead0f462d0c9f7474a87f82"
  end

  depends_on "rust" => :build

  uses_from_macos "python" => :build

  # patch release version, upstream pr ref, https://github.com/ms-jpq/sad/pull/327
  patch do
    url "https://github.com/ms-jpq/sad/commit/d2a8bae6f3b64cc695020536e6f59b9ec7eb95e4.patch?full_index=1"
    sha256 "7e41c3739288928fcd718a0428c4e51d6c50818f07f5047bb9605cb269dd3af4"
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    test_file = testpath/"test.txt"
    test_file.write "a,b,c,d,e\n1,2,3,4,5\n"
    system "find #{testpath} -name 'test.txt' | #{bin}/sad -k 'a' 'test' > /dev/null"
    assert_equal "test,b,c,d,e\n1,2,3,4,5\n", test_file.read

    assert_match "sad #{version}", shell_output("#{bin}/sad --version")
  end
end
