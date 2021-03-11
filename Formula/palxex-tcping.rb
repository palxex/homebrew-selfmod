class PalxexTcping < Formula
  desc "TCP connect to the given IP/port combo"
  homepage "https://github.com/palxex/tcping"
  license "GPLv2+"
  head "https://github.com/palxex/tcping.git"

  def install
    system "make"
    bin.install "tcping"
  end

  test do
    system "#{bin}/tcping", "www.google.com", "80"
  end
end
