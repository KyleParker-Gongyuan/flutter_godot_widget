#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_godot_widget.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_godot_widget'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for embedding Godot engine.'
  s.description      = <<-DESC
A Flutter plugin that allows embedding Godot 4.x engine in Flutter applications with bidirectional communication support.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  
  # iOS frameworks needed for Godot integration
  s.frameworks = 'Metal', 'MetalKit', 'CoreHaptics', 'AVFoundation', 'GameController'
  
  # SwiftGodot integration:
  # - Add via Xcode: File → Add Package Dependencies → https://github.com/migueldeicaza/SwiftGodot
  # - SwiftGodot loads Godot project files dynamically (no pre-compilation needed)
  # - Project files are in Assets/ folder and loaded at runtime
  
  # Include Godot assets
  s.resource_bundles = {
    'flutter_godot_widget' => ['Assets/**/*']
  }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'ENABLE_BITCODE' => 'NO'
  }
  s.swift_version = '5.0'
  
  # Note: You will need to add the Godot XCFramework manually or via SwiftGodotKit
  # See the README for instructions on building or obtaining the Godot iOS framework
end
