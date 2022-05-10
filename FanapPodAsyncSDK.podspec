
Pod::Spec.new do |s|

  s.name         = "FanapPodAsyncSDK"
  s.version      = "0.10.0.2"
  s.summary      = "Fanap's POD Asyn SDK"
  s.description  = "This Package will use to connect the client to the Fanap's async service (DIRANA), and it will live the connection (with socket) to send and recieve messages..."
  s.homepage     = "https://github.com/FanapSoft/pod-async-ios-sdk"
  s.license      = "MIT"
  s.author       = { "Hamed" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "4.0"
  s.source       = { :git => "https://github.com/FanapSoft/pod-async-ios-sdk.git", :tag => s.version }
  s.source_files = "Pod-Async-iOS-SDK/Async/**/*.{h,swift,m}"
  s.framework  = "Foundation"
  s.dependency "Starscream" , '~> 3.0.5'
  s.dependency "Sentry" , '~> 4.3.1'

end
