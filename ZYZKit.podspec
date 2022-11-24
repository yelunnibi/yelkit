#
# Be sure to run `pod lib lint ZYZKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZYZKit'
  s.version          = '1.0.0'
  s.summary          = 'ZYZKit'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: ZYZKit Common tool
                       DESC

  s.homepage         = 'https://github.com/githubdelegate/ZYZKit.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wz' => 'ostmail@163.com' }
  s.source           = { :git => 'https://github.com/githubdelegate/ZYZKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.platform = :ios
  s.ios.deployment_target = '14.0'
  
  s.swift_version = '5.0'

  s.source_files = 'ZYZKit/Classes/**/*'
  
  s.subspec 'Common' do |spc|
      spc.ios.deployment_target = '14.0'
      
      spc.source_files = 'ZYZKit/Classes/Common/**/*'
      spc.dependency 'AFNetworking', '~> 2.3'
      spc.dependency 'MBProgressHUD', '~> 1.2.0'
  end
  
  
  
  s.subspec 'PDF' do |sp|
    sp.ios.deployment_target = '14.0'
    
    sp.source_files = 'ZYZKit/Classes/PDF/**/*'
    sp.dependency  'Zip', '~> 2.1'
    sp.dependency  'ZYZKit/Common'
    sp.frameworks = 'PDFKit'
  end
  
  
  s.subspec 'Helper' do |sp|
    sp.ios.deployment_target = '14.0'
    
    sp.source_files = 'ZYZKit/Classes/Helper/**/*'
    sp.dependency  'ZYZKit/Common'
    sp.dependency  'TLPhotoPicker'
    sp.frameworks = 'Photos'
  end

 
  
  # s.resource_bundles = {
  #   'ZYZKit' => ['ZYZKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit', 'Foundation'
   
end
