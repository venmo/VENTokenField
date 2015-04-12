Pod::Spec.new do |s|
  s.name         = 'VENTokenField'
  s.version      = '2.4.0'
  s.summary      = 'Token field used in the Venmo app.'
  s.description   = <<-DESC
                   An easy to use token field that in used in the Venmo app.
                   DESC
  s.homepage     = 'https://github.com/venmo/VENTokenField'
  s.screenshot   = 'http://i.imgur.com/a1FfEBi.gif'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Venmo' => 'ios@venmo.com'}
  s.source       = { :git => 'https://github.com/venmo/VENTokenField.git', :tag => "v#{s.version}" }
  s.source_files = 'VENTokenField/**/*.{h,m}'
  s.resources   = ["VENTokenField/**/*.{xib,png}"]
  s.dependency 'FrameAccessor', '~> 1.0'
  s.platform     = :ios, '7.0'
  s.requires_arc = true
end
