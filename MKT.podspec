Pod::Spec.new do |s|
  s.name             = 'MKT'
  s.version          = '0.1.1'
  s.summary          = 'This project is used for following up with customers.'

  s.description      = 'This project uses customer tracking so that businesses can create campaigns based on customer actions.'

  s.homepage         = 'https://github.com/pojaket01/mkt-cdxp'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mangkhang.tk' => 'mangkhang.tk@gmail.com' }
  s.source           = { :git => 'https://github.com/pojaket01/mkt-cdxp.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'
  s.ios.deployment_target = '10.0'

  s.source_files = 'MKT/Classes/**/*'
end
