Pod::Spec.new do |s|
  s.name = 'Archiver.swift'
  s.version = '0.4.0'
  s.license = 'MIT'
  s.summary = 'Protocol-Oriented Value Archiving in Swift'
  s.homepage = 'https://github.com/toddkramer/Archiver'
  s.social_media_url = 'http://twitter.com/_toddkramer'
  s.author = 'Todd Kramer'
  s.source = { :git => 'https://github.com/toddkramer/Archiver.git', :tag => s.version }

  s.module_name = 'Archiver'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Sources/*.swift'
end
