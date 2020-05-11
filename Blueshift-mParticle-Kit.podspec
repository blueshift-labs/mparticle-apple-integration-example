Pod::Spec.new do |s|
  # s.name         = "Blueshift-mParticle-Kit"
  s.name         = "Blueshift-mParticle-Kit"
  s.version      = "0.0.3"
  s.summary      = "iOS SDK for integrating push notification and analytics"

  s.description  = <<-DESC
                   A longer description of Blueshift-mParticle-Kit in Markdown format.
                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage    = "https://github.com/blueshift-labs/mparticle-apple-integration-blueshift"
  s.license     = { :type => "MIT", :file => "LICENSE" }
  s.author      = { "Blueshift" => "success@getblueshift.com" }
  s.source      = { :git => "https://github.com/blueshift-labs/mparticle-apple-integration-blueshift.git", :tag => "0.0.3" }
  s.exclude_files         = "Classes/Exclude"
  s.ios.deployment_target = "9.0"
  s.ios.frameworks        = 'CoreTelephony', 'SystemConfiguration'
  s.ios.source_files      = 'Blueshift-mParticle-Kit/*.{h,m}'
  s.ios.dependency 'mParticle-Apple-SDK'
  s.ios.dependency 'BlueShift-iOS-SDK'

end
