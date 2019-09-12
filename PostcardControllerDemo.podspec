Pod::Spec.new do |s|
  #项目名
  s.name         = "PostcardControllerDemo"
  #版本号对应github项目的tag
  s.version      = "1.0.0"
  s.summary      = "卡片转场动画库"
  # description可以注释
  # s.description  = <<-DESC
  #                DESC
  #项目地址
  s.homepage     = "https://github.com/lyimin/PostcardController"
  #这里使用指定license文件的方式
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "eamon" => "liangeamon@gmail.com" }
  s.platform     = :ios, "10.0"
  #版本号对应github项目的tag
  s.source       = { :git => "https://github.com/lyimin/PostcardController.git", :tag => "1.0.0" }
  #重要：要上传的文件路径
  s.source_files  = "Source/*.{swift}"
  #资源文件
  s.resources = "Source/resource/*.png"
  #依赖的库
  s.framework  = "UIKit"
  #如果依赖多个库，可以写成以下方式
  # s.frameworks = "SomeFramework", "AnotherFramework"
  #如果依赖其他三方库 ，如果依赖多个三方库，则配置多个s.dependency即可
  s.dependency "SnapKit", "~> 5.0.0"

end