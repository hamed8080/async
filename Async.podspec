
Pod::Spec.new do |s|

  s.name         = "Async"
  s.version      = "1.2.0"
  s.summary      = "Swift Async SDK"
  s.description  = "This Package will use to connect the client to the async server (DIRANA), and it will live the connection (with socket) to send and recieve messages..."
  s.homepage     = "https://pubgi.fanapsoft.ir/chat/ios/async"
  s.license      = "MIT"
  s.author       = { "Hamed" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "4.0"
  s.source       = { :git => "https://pubgi.fanapsoft.ir/chat/ios/async.git", :tag => s.version }
  s.source_files = "Sources/Async/**/*.{h,swift,m}"
  s.framework  = "Foundation"
  s.dependency "Starscream" , '~> 3.0.5'
  s.dependency "Logger" , '~> 1.0.0'
end
