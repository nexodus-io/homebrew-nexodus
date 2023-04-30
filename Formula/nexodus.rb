require "formula"
require 'date'

class Nexodus < Formula

  desc "Secure IP Connectivity for Hybrid Infrastructure and the Edge"
  homepage "https://nexodus.io/"
  license "Apache-2.0"
  head "https://github.com/nexodus-io/nexodus.git", branch: "main"

  def self.curl_github_api(url)
    curl = "curl -L -s -H 'X-GitHub-Api-Version: 2022-11-28' -H 'Accept: application/vnd.github+json'"
    if ENV['HOMEBREW_GITHUB_API_TOKEN']
      curl += " -H 'Authorization: token #{ENV['HOMEBREW_GITHUB_API_TOKEN']}'"
    end
    resp = JSON.parse(`#{curl} #{url}`)
    # puts JSON.pretty_generate(resp) 
    resp
  end

  def self.fetch_sha_and_date(tag) 

    resp = curl_github_api "https://api.github.com/repos/nexodus-io/nexodus/git/refs/tags/#{tag}"
    sha = resp["object"]["sha"]

    resp = curl_github_api resp["object"]["url"]
    date = Date.parse(resp["committer"]["date"]).strftime("%Y%m%d")    

    return sha, date
  end

  def self.init 
     sha, date = fetch_sha_and_date("prod")
     version "0.1.#{date}git#{sha}"
     url "https://github.com/nexodus-io/nexodus/archive/#{sha}.tar.gz"   
  end
  init

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
