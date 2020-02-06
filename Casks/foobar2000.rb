cask 'foobar2000' do
  version '2.1.57'
  sha256 'a49d61dca8ac41bddbc8498c74a4c7c03327d4f6051c8165a36805c73cf75875'

  url "https://www.foobar2000.org/files/4c0e30de7a12cecea37eed2af8c52498/foobar2000-v#{version}.dmg"
  name 'foobar2000'
  homepage 'https://www.foobar2000.org/'

  app 'foobar2000.app'
end