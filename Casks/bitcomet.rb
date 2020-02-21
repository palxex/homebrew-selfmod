cask 'bitcomet' do
  version '1.63.0'
  sha256 '12fe07e02a1306e1247b35ca86b75e04331f25cf347cca9154b1592ee5367b91'

  url "https://download.bitcomet.com/mac/BitComet_#{version}.dmg"
  name 'bitcomet'
  homepage 'https://www.bitcomet.com/'

  app 'BitComet.app'
end