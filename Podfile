source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "7.0"

target "VENTokenFieldSample" do
  pod 'VENTokenField', :path => '.'
end

target "VENTokenFieldSampleTests" do
  pod 'KIF', '~> 3.0.4'
end

begin
  require 'slather'
  Slather.prepare_pods(self)
rescue LoadError
  puts 'Slather has been disabled (not installed).'
end

