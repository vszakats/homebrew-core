class Jackett < Formula
  desc "API Support for your favorite torrent trackers"
  homepage "https://github.com/Jackett/Jackett"
  url "https://github.com/Jackett/Jackett/archive/refs/tags/v0.22.586.tar.gz"
  sha256 "99aa0d29ee233a58f61b75ec5c86551456cf4cf164d59ca6d3133d4ea24dab54"
  license "GPL-2.0-only"
  head "https://github.com/Jackett/Jackett.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "0a282cb761056468c02881fafbfb00f0afbee17da2432ccdd4e2ac03637a3beb"
    sha256 cellar: :any,                 arm64_ventura:  "a12f4812d041e0effb5c4d8da992c2a4a3069d7a92adf949237621b95a1dbbbe"
    sha256 cellar: :any,                 arm64_monterey: "f97d9eedfd782d72f43f1c6123db3f06e457e7b502755d0e830456e0a84ad436"
    sha256 cellar: :any,                 sonoma:         "dfc8fe3924542224b91418f30be608fa25129faae69bbf609e5a15e64c9a569b"
    sha256 cellar: :any,                 ventura:        "f31629db033827ddbafdfac0453bf6288d15f8ceb1c33952bd76fae13f38d5fc"
    sha256 cellar: :any,                 monterey:       "5c87fb42a9f6533559d7050aec0d40d5593056cc35efeb0a0c7bfe5a7f447a96"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "965c4faf54cb1f07bc4af22b4f8b02dcb2ebb32330a1967eb1370830ed2a053d"
  end

  depends_on "dotnet"

  def install
    dotnet = Formula["dotnet"]
    os = OS.mac? ? "osx" : OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s

    args = %W[
      --configuration Release
      --framework net#{dotnet.version.major_minor}
      --output #{libexec}
      --runtime #{os}-#{arch}
      --no-self-contained
    ]
    if build.stable?
      args += %W[
        /p:AssemblyVersion=#{version}
        /p:FileVersion=#{version}
        /p:InformationalVersion=#{version}
        /p:Version=#{version}
      ]
    end

    system "dotnet", "publish", "src/Jackett.Server", *args

    (bin/"jackett").write_env_script libexec/"jackett", "--NoUpdates",
      DOTNET_ROOT: "${DOTNET_ROOT:-#{dotnet.opt_libexec}}"
  end

  service do
    run opt_bin/"jackett"
    keep_alive true
    working_dir opt_libexec
    log_path var/"log/jackett.log"
    error_log_path var/"log/jackett.log"
  end

  test do
    assert_match(/^Jackett v#{Regexp.escape(version)}$/, shell_output("#{bin}/jackett --version 2>&1; true"))

    port = free_port

    pid = fork do
      exec bin/"jackett", "-d", testpath, "-p", port.to_s
    end

    begin
      sleep 15
      assert_match "<title>Jackett</title>", shell_output("curl -b cookiefile -c cookiefile -L --silent http://localhost:#{port}")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
