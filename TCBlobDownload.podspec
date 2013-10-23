Pod::Spec.new do |s|
  s.name         = "TCBlobDownload"
  s.version      = "1.3.1"
  s.summary      = "A short description of TCBlobDownload."
  s.description  = <<-DESC
                   A longer description of TCBlobDownload in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC
  s.homepage     = "https://github.com/thibaultCha/TCBlobDownload"
  s.license      = 'MIT (example)'
  s.author       = { "Thibault Charbonnier" => "thibaultcha@me.com" }

  # s.platform     = :ios
  # s.platform     = :ios, '5.0'

  #  When using multiple platforms
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'

  s.source       = { :git => "https://github.com/thibaultCha/TCBlobDownload", :tag => "1.3.1" }
  s.source_files  = 'TCBlobDownload/TCBlobDownload/*.{h,m}'
  s.requires_arc = true
end
