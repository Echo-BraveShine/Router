
Pod::Spec.new do |s|
s.name             = 'ERouter'
s.version          = '0.0.1'
s.summary          = 'Router Swift 路由'
s.description      = '简单的Router Swift 路由'

s.homepage         = "https://github.com/Echo-BraveShine/Router.git"
s.author           = { 'author' => '1239383708@qq.com' }
s.source           = { :git => 'https://github.com/Echo-BraveShine/Router.git', :tag => s.version.to_s }
s.license          = { :type => "Apache", :file => "LICENSE" }
s.swift_versions   = ['5.0']

s.ios.deployment_target = '11.0'

s.source_files = 'RouteDemo/Modules/ERouter/Code/*.swift'
s.static_framework = true

end
