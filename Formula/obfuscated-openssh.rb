class ObfuscatedOpenssh < Formula
  desc "OpenBSD freely-licensed SSH connectivity tools with obfuscated patch"
  homepage "https://www.openssh.com/"
  url "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.5p1.tar.gz"
  mirror "https://mirror.vdms.io/pub/OpenBSD/OpenSSH/portable/openssh-8.5p1.tar.gz"
  version "8.5p1"
  sha256 "f52f3f41d429aa9918e38cf200af225ccdd8e66f052da572870c89737646ec25"
  license "SSH-OpenSSH"


  livecheck do
    url "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/"
    regex(/href=.*?openssh[._-]v?(\d+(?:\.\d+)+(?:p\d+)?)\.t/i)
  end

  conflicts_with "openssh",
    :because => "both install ssh scp sshd etc"

  # Please don't resubmit the keychain patch option. It will never be accepted.
  # https://archive.is/hSB6d#10%25

  depends_on "pkg-config" => :build
  depends_on "ldns"
  depends_on "libfido2"
  depends_on "openssl@1.1"
  
  unless OS.mac?
    depends_on "libedit"
    depends_on "krb5"
    depends_on "zlib"
    depends_on "lsof" => :test
  end

  resource "com.openssh.sshd.sb" do
    url "https://opensource.apple.com/source/OpenSSH/OpenSSH-209.50.1/com.openssh.sshd.sb"
    sha256 "a273f86360ea5da3910cfa4c118be931d10904267605cdd4b2055ced3a829774"
  end

  # Both these patches are applied by Apple.
  if OS.mac?
    patch do
      url "https://raw.githubusercontent.com/Homebrew/patches/1860b0a745f1fe726900974845d1b0dd3c3398d6/openssh/patch-sandbox-darwin.c-apple-sandbox-named-external.diff"
      sha256 "d886b98f99fd27e3157b02b5b57f3fb49f43fd33806195970d4567f12be66e71"
    end

    patch do
      url "https://raw.githubusercontent.com/Homebrew/patches/d8b2d8c2612fd251ac6de17bf0cc5174c3aab94c/openssh/patch-sshd.c-apple-sandbox-named-external.diff"
      sha256 "3505c58bf1e584c8af92d916fe5f3f1899a6b15cc64a00ddece1dc0874b2f78f"
    end
  end

  patch do
    url "https://raw.githubusercontent.com/zinglau/obfuscated-openssh-patches/master/portable/8.5.diff"
    sha256 "eef6253ee0bed9fe083005b3012190f5736fa257e2e19537ddb1627b2109bb28"
  end

  def install
    ENV.append "CPPFLAGS", "-D__APPLE_SANDBOX_NAMED_EXTERNAL__" if OS.mac?

    # Ensure sandbox profile prefix is correct.
    # We introduce this issue with patching, it's not an upstream bug.
    inreplace "sandbox-darwin.c", "@PREFIX@/share/openssh", etc/"ssh" if OS.mac?

    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}/ssh
      --with-ldns
      --with-libedit
      --with-kerberos5
      --with-ssl-dir=#{Formula["openssl@1.1"].opt_prefix}
      --with-security-key-builtin
    ]

    args << "--with-pam" if OS.mac?
    args << "--with-privsep-path=#{var}/lib/sshd" unless OS.mac?

    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "install"

    # This was removed by upstream with very little announcement and has
    # potential to break scripts, so recreate it for now.
    # Debian have done the same thing.
    bin.install_symlink bin/"ssh" => "slogin"

    buildpath.install resource("com.openssh.sshd.sb")
    (etc/"ssh").install "com.openssh.sshd.sb" => "org.openssh.sshd.sb"
  end

  plist_options :startup => true

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_sbin}/sshd</string>
      </array>
      <key>StandardOutPath</key>
      <string>/tmp/#{plist_name}.log</string>
      <key>StandardErrorPath</key>
      <string>/tmp/#{plist_name}.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    if ENV["HOMEBREW_GITHUB_ACTIONS"]
      # Fixes "Starting sshd: Privilege separation user sshd does not exist FAILED" in docker
      system "groupadd", "-g", "133", "sshd"
      system "useradd", "-u", "133", "-g", "133", "-c", "sshd", "-d", "/", "sshd"
    end

    assert_match "OpenSSH_", shell_output("#{bin}/ssh -V 2>&1")

    port = free_port
    fork { exec sbin/"sshd", "-D", "-p", port.to_s }
    sleep 2
    assert_match "sshd", shell_output("lsof -i :#{port}")
  end
end
