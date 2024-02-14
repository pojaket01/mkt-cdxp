Pod::Spec.new do |s|
  s.name             = 'MKT'
  s.version          = '0.1.1'
  s.summary          = 'A short description of MKT.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/pojaket01/mkt-cdxp'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mangkhang.tk' => 'mangkhang.tk@gmail.com' }
  s.source           = { :git => 'https://github.com/pojaket01/mkt-cdxp.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'MKT/Classes/**/*'
end
