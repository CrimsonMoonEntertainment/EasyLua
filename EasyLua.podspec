#
# Be sure to run `pod lib lint EasyLua.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "EasyLua"
  s.version          = "1.1.3"
  s.summary          = "An easy to use library for integrating Lua with Objective-c on iOS."
  s.description      = <<-DESC
                        EasyLua is lightweight, easy to integrate, and easy to use library for bridging Obj-C and Lua.
                        Our goal was to make a library which is easy to call into lua and out
                        to iOS with no knowlege required of how the lua c bridge worked.
                       DESC
  s.homepage         = "https://github.com/CrimsonMoonEntertainment/EasyLua.git"
  s.license          = 'MIT'
  s.author           = { "David Holtkamp" => "david@crimson-moon.com" }
  s.source           = { :git => "https://github.com/CrimsonMoonEntertainment/EasyLua.git", :tag => s.version.to_s }
  s.social_media_url = 'https://www.facebook.com/CrimsonMoonEntertainment'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resources = ['Pod/Assets/*.png', 'Pod/Assets/*.lua']

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = ['Foundation', 'UIKit', 'CoreGraphics']
  s.dependency 'lua', '~> 5.2'
end
