Pod::Spec.new do |s|
  s.name             = 'share_link'
  s.version          = '0.1.0'
  s.summary          = 'Share links with target-specific content'
  s.description      = <<-DESC
Share links with target-specific content (such as utm tags) and user selection feedback.
                       DESC
  s.homepage         = 'https://github.com/erickok/share_link'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Eric Kok' => 'eric@2312.nl' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
