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
  s.version          = "0.1.0"
  s.summary          = "An easy to use library for integrating Lua with Objective-c on iOS."
  s.description      = <<-DESC
                        EasyLua is an easy to integrate and easy to use library.
                        Our goal was to make a library which is easy to call into lua and out
                        to iOS with no knowlege required of how the lua c bridge worked.
                       DESC
  s.homepage         = "https://github.com/CrimsonMoonEntertainment/EasyLua.git"
  s.license          = 'MIT'
  s.author           = { "David Holtkamp" => "david@crimson-moon.com" }
  s.source           = { :git => "https://github.com/CrimsonMoonEntertainment/EasyLua.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resources = ['Pod/Assets/*.png', 'Pod/Assets/*.lua']

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Foundation'
  s.dependency 'lua', '~> 5.2'
end
