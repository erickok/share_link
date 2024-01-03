Pod::Spec.new do |s|
  s.name             = 'share_link'
  s.version          = '0.1.1'
  s.summary          = 'Share links with UTM targeting parameters'
  s.description      = <<-DESC
Share links with UTM targeting parameters and feedback on the user-selected app.
                       DESC
  s.homepage         = 'https://github.com/erickok/share_link'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Eric Kok' => 'eric@2312.nl' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
