cask 'xtrafinder' do
  version '1.5.2'
  sha256 '6ff33018f826410d438c44d46f8ed9d3adeeeffb6a598a23a6141f80b9d1e27b'

  url 'https://trankynam.com/xtrafinder/downloads/XtraFinder.dmg'
  name 'XtraFinder'
  homepage 'https://trankynam.com/xtrafinder/'

  ohai "NEED SIP TURN OFF GLOBALLY!"

  if MacOS.version == :catalina
    installer script: {
                        executable: 'For OS X 10.15 Catalina/Install.command',
                        sudo:       true,
                      }
    uninstall script: {
                        executable:   'For OS X 10.15 Catalina/Uninstall.command',
                        sudo:         true,
                      }
  elsif MacOS.version == :mojave
    # TODO
  else
    pkg 'For OS X 10.13 - 10.6/XtraFinder.pkg'
    uninstall pkgutil: 'com.trankynam.xtrafinder.*'
  end
end
