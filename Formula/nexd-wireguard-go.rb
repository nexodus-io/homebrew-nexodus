require "formula"

class NexdWireguardGo < Formula

  desc "Nexodus Friendly Wireguard Go"
  homepage "https://nexodus.io/"
  license "Apache-2.0"
  head "https://github.com/nexodus-io/wireguard-go.git", branch: "main"

  version "0.0.20230420"
  url "https://github.com/nexodus-io/wireguard-go/archive/refs/tags/#{version}.tar.gz"
  sha256 "2f8e546f92f85917c275bf04e01ad7f2db19e14cfe7c156c5861540570ac797d"

  depends_on "go@1.20" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    system "go", "build", "-ldflags=-X main.Version=#{version}", "-o", "nexd-wireguard-go", "."
    bin.install "nexd-wireguard-go"
  end

  test do
    system "#{bin}/nexd-wireguard-go", "version"
  end

end
