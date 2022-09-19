
Pod::Spec.new do |s|

  s.name         = "FanapPodAsyncSDK"
  s.version      = "1.1.0"
  s.summary      = "Fanap's POD Asyn SDK"
  s.description  = "This Package will use to connect the client to the Fanap's async service (DIRANA), and it will live the connection (with socket) to send and recieve messages..."
  s.homepage     = "https://pubgi.fanapsoft.ir/chat/ios/fanappodasyncsdk"
  s.license      = "MIT"
  s.author       = { "Hamed" => "hamed8080@gmail.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = "4.0"
  s.source       = { :git => "https://pubgi.fanapsoft.ir/chat/ios/fanappodasyncsdk.git", :tag => s.version }
  s.source_files = "Sources/FanapPodAsyncSDK/**/*.{h,swift,m}"
  s.framework  = "Foundation"
  s.dependency "Starscream" , '~> 3.0.5'
end
