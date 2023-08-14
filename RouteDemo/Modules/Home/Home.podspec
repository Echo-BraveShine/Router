
Pod::Spec.new do |s|
s.name             = 'Home'
s.version          = '0.0.1'
s.summary          = 'A short description of GTAccountModule.'
s.description      = '库'

s.homepage         = 'https://github.com/'
s.author           = { 'author' => 'test@163.com' }
s.source           = { :git => 'https://github.com/', :tag => s.version.to_s }

s.ios.deployment_target = '11.0'

s.source_files = 'Code/**/*'
s.static_framework = true
s.resource_bundles={
'Library'=>['Resource/Media.xcassets','Code/**/*.xib'],
}
s.dependency 'ERouter'

end
