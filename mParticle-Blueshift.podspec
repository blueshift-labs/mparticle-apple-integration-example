Pod::Spec.new do |s|
  s.name         = "mParticle-Blueshift"
  s.version      = "1.0.0"
  s.summary      = "iOS SDK for integrating push notification and analytics"

  s.description  = <<-DESC
                   A longer description of Blueshift-mParticle-Kit in Markdown format.
                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/blueshift-labs/Blueshift-iOS-SDK"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author             = { "Blueshift" => "success@getblueshift.com" }
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-example.git", :tag => "1.0.0" }
  s.exclude_files = "Classes/Exclude"
  s.ios.source_files = 'mParticle-Blueshift/*.{h,m}'
  s.ios.dependency 'mParticle-Apple-SDK', '~> 7.7.0'
  s.ios.frameworks = 'CoreTelephony', 'SystemConfiguration'
  s.ios.dependency 'BlueShift-iOS-SDK', '~> 2.0.7'
  
end
