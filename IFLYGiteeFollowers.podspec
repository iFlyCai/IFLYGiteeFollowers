Pod::Spec.new do |s|
  s.name             = 'IFLYGiteeFollowers'
  s.version          = '0.0.2'
  s.summary          = 'Fetch and display Gitee followers list'

  s.description      = <<-DESC
A lightweight library to fetch the followers list of a Gitee user,
with support for pagination, error handling, and displaying in UI.
  DESC

  s.homepage         = 'https://github.com/iFlyCai/IFLYGiteeFollowers'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iFlyCai' => 'zhangchengcai3615@126.com' }
  s.source           = { :git => 'https://github.com/iFlyCai/IFLYGiteeFollowers.git', :tag => s.version.to_s }

  s.ios.deployment_target = '16.0'
  s.swift_version     = '5.7'
  # 如果 module_name 和 static_framework 没有特别用途，可以去掉或改为合理名称
   s.module_name = 'IFLYGiteeFollowers'
   s.static_framework = true

  # 源码文件路径，指定 .swift/.h 等需要被包含的源文件
  s.source_files = 'IFLYGiteeFollowers/Classes/**/*.{swift,h}'

  # 如果你有资源文件（xib、图片、json 等），可以配置 resources 或 resource_bundles
  # s.resource_bundles = {
  #   'IFLYGiteeFollowersResources' => ['IFLYGiteeFollowers/Assets/**/*']
  # }

  # 添加依赖
  s.dependency 'IFLYCommonKit'
end
