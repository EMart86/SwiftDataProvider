#
# Be sure to run `pod lib lint SwiftDataProvider.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftDataProvider'
  s.version          = '1.6.0'
  s.summary          = 'Reduce boilerplate code for UITableView and UITableViewController\'s data source'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Handling TableViews and animated updates is now easer than you think. Design your TableView with your Models instead of keeping track of all the IndexPaths and IndexSets.
                       DESC

  s.homepage         = 'https://github.com/EMart86/SwiftDataProvider'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Martin Eberl' => 'eberl_ma@gmx.at' }
  s.source           = { :git => 'https://github.com/EMart86/SwiftDataProvider.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.2'

  s.source_files = 'SwiftDataProvider/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SwiftDataProvider' => ['SwiftDataProvider/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
