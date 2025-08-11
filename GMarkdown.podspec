Pod::Spec.new do |s|
  s.name             = 'GMarkdown'
  s.version          = '0.1.1'
  s.summary          = 'A powerful and versatile Markdown rendering library for Swift developers'
  s.description      = <<-DESC
                       GMarkdown is a powerful and versatile Markdown rendering library designed for Swift developers. 
                       Built on top of the swift-markdown parser, GMarkdown offers pure native rendering capabilities, 
                       ensuring seamless integration and high performance for your iOS applications.
                       
                       Features:
                       - Pure Native Rendering
                       - Rich Text Support  
                       - Image Rendering
                       - Code Blocks with syntax highlighting
                       - Tables
                       - LaTeX Math Formulas
                       - Mermaid Diagrams
                       - HTML Preview
                       DESC

  s.homepage         = 'https://github.com/GIKICoder/GMarkdown.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'GIKICoder' => 'giki.biu@gmail.com' }
  s.source           = { :git => 'https://github.com/GIKICoder/GMarkdown.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/**/*.swift'
  
  # Resource files from Assets directory
  s.resources = [
    'Sources/Assets/**/*'
  ]
  
  # Dependencies
  s.dependency 'swift-markdown-pod', '1.0.1'
  s.dependency 'SwiftMath-pod', '2.0.1.pod'
  s.dependency 'MathJaxSwift-pod', '3.2.2'
  s.dependency 'MPITextKit'
  
  # Frameworks
  s.frameworks = 'UIKit', 'Foundation', 'WebKit', 'JavaScriptCore', 'Photos'
  
  # Additional settings
  s.requires_arc = true
  
  # Compiler conditions for resource loading
  s.pod_target_xcconfig = {
    'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'COCOAPODS'
  }
end
