Pod::Spec.new do |s|
  s.name             = 'SwiftGodot'
  s.version          = '1.0.0'
  s.summary          = 'Godot integration for Flutter on iOS using Swift.'
  s.description      = 'Godot bridge for iOS using Swift. Used in flutter_godot_widget.'
  s.homepage         = 'https://yourdomain.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Your Name' => 'your@email.com' }
  s.source           = { :path => '.' }

  s.swift_version    = '5.0'
  s.platform         = :ios, '13.0'
  s.source_files     = 'Sources/**/*.swift'
end
