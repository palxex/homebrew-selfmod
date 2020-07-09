cask 'smartpss' do
  version '2.03.0.R.20191203'
  sha256 'c4e78bcebbf44244893e5e4c2a5398c8d3f7bbf5345723dfe373f164136fdaac'

  url 'https://dahuawiki.com/images/Files/Software/OSX/General_SmartPSS_ChnEng_Mac_IS_V2.03.0.R.20191203.pkg.zip'
  name 'SmartPSS'
  homepage 'https://dahuawiki.com/SmartPSS'

  pkg 'General_SmartPSS_ChnEng_Mac_IS_V2.03.0.R.20191203.pkg'
  uninstall pkgutil: 'com.GeneralSmartPSSChnEngMacISV2030R20191203.pkg'
end
