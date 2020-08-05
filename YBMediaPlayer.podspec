#
# Be sure to run `pod lib lint YBMediaPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YBMediaPlayer'
  s.version          = '1.1.3'
  s.summary          = 'A Media Player on iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A Media Player created by Sun.
  Copyright (c) 2020 QingClass. All rights reserved.
                       DESC

  s.homepage         = 'https://git.qingclass.com/app-components/ybmediaplayer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '杨光' => 'guang.yang@qingclass.com' }
  s.source           = { :git => 'https://git.qingclass.com/app-components/ybmediaplayer.git', :tag => s.version.to_s }
  s.static_framework = true
  s.default_subspec = 'Core'

  s.ios.deployment_target = '9.0'
  
  s.subspec 'Core' do |core|
         core.source_files = 'YBMediaPlayer/Classes/Core/**/*'
         core.public_header_files = 'YBMediaPlayer/Classes/Core/**/*.h'
         core.frameworks = 'UIKit', 'MediaPlayer', 'AVFoundation'
     end
     
     s.subspec 'ControlView' do |controlView|
         controlView.source_files = 'YBMediaPlayer/Classes/ControlView/**/*.{h,m}'
         controlView.public_header_files = 'YBMediaPlayer/Classes/ControlView/**/*.h'
         controlView.resource = 'YBMediaPlayer/Classes/ControlView/YBMediaPlayer.bundle'
         controlView.dependency 'YBMediaPlayer/Core'
     end
     
     s.subspec 'AVPlayer' do |avPlayer|
         avPlayer.source_files = 'YBMediaPlayer/Classes/AVPlayer/**/*.{h,m}'
         avPlayer.public_header_files = 'YBMediaPlayer/Classes/AVPlayer/**/*.h'
         avPlayer.dependency 'YBMediaPlayer/Core'
     end
     
     s.subspec 'IJKPlayer' do |ijkplayer|
         ijkplayer.source_files = 'YBMediaPlayer/Classes/IJKMediaPlayer/*.{h,m}'
         ijkplayer.public_header_files = 'YBMediaPlayer/Classes/IJKMediaPlayer/*.h'
         ijkplayer.dependency 'YBMediaPlayer/Core'
         ijkplayer.dependency 'IJKMediaFramework'
         ijkplayer.ios.deployment_target = '9.0'
     end
end
