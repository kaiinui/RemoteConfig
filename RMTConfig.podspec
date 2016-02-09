Pod::Spec.new do |s|
  s.name         = "RMTConfig"
  s.version      = "0.2.0"
  s.summary      = "[iOS] Easy remote configuration"
  s.homepage     = "https://github.com/kaiinui/RemoteConfig"
  s.license      = { :type => "MIT", :text => "MIT"}
  s.author       = { "kaiinui" => "lied.der.optik@gmail.com" }
  s.source       = { :git => "https://github.com/kaiinui/RemoteConfig.git", :tag => "v0.2.0" }
  s.source_files  = "RemoteConfig/Classes/**/*.{h,m}"
  s.requires_arc = true
  s.platform = "ios", '7.0'
end
