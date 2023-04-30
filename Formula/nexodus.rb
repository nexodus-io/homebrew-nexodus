require "formula"

class Nexodus < Formula

  desc "Secure IP Connectivity for Hybrid Infrastructure and the Edge"
  homepage "https://nexodus.io/"
  license "Apache-2.0"
  head "https://github.com/nexodus-io/nexodus.git", branch: "main"

  version "prod"
  url "https://github.com/nexodus-io/nexodus/archive/refs/tags/#{version}.tar.gz"

  # TODO: post a checksum of the source tar ball somehere so we don't need update this for each release.
  # sha256 `curl -L -s https://github.com/nexodus-io/nexodus/some_checksums.txt`.split(' ').first

  depends_on "go@1.20" => :build
  depends_on "wireguard-tools" => :recommended
  depends_on "nexd-wireguard-go" => :recommended

  def install
    ENV["CGO_ENABLED"] = "0"
    system "go", "build", "-ldflags=-X main.Version=#{version}", "-o", "./dist/nexd", "./cmd/nexd"
    system "go", "build", "-ldflags=-X main.Version=#{version}", "-o", "./dist/nexctl", "./cmd/nexctl"
    bin.install "dist/nexd"
    bin.install "dist/nexctl"
  end

  service do
    run [opt_bin/"nexd", "https://try.nexodus.io"]
    require_root true
    keep_alive true
    log_path var/"log/nexd-stdout.log"
    error_log_path var/"log/nexd-stderr.log"
    environment_variables PATH: std_service_path_env
  end

  test do
    system "#{bin}/nexctl", "version"
  end

end
