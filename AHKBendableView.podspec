Pod::Spec.new do |s|
  s.name             = "AHKBendableView"
  s.version          = "0.1.0"
  s.summary          = "UIView subclass that bends its edges when its position changes."
  s.homepage         = "https://github.com/fastred/AHKBendableView"
  s.license          = 'MIT'
  s.author           = { "Arkadiusz Holko" => "fastred@fastred.org" }
  s.source           = { :git => "https://github.com/fastred/AHKBendableView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/arekholko'
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Classes/*.swift'
  s.frameworks = 'QuartzCore'
end
