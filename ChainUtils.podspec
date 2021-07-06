Pod::Spec.new do |s|
  s.name             = 'ChainUtils'
  s.version          = '3.0.0'
  s.summary          = 'Light weight encryption SDK for iOS'

  s.homepage         = 'https://github.com/RyuGames/ChainUtils'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'WyattMufson' => 'wyatt@ryu.games' }
  s.source           = { :git => 'https://github.com/RyuGames/ChainUtils.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.3'

  s.source_files = 'ChainUtils/Classes/**/*'
  s.vendored_frameworks = 'neoutils.framework'
  s.dependency 'NetworkUtils', '2.0.1'

  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
