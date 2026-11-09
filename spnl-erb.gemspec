Gem::Specification.new do |s|
  s.name = 'spnl-erb'
  s.version = '0.2.0'
  s.summary = 'Build-time standard ERB compilation for Spinel'
  s.authors = ['gorin9']
  s.homepage = 'https://github.com/gorin9/spnl-erb'
  s.license = 'MIT'
  s.required_ruby_version = '>= 3.1'
  s.files = Dir['lib/**/*.rb', 'web/**/*.rb', 'spnl_*/**/*.rb', 'spnl_*.rb', 'native/*', 'bin/*', 'README.md', 'LICENSE', 'spin.toml', 'spinel-packer']
  s.require_paths = ['.', 'lib']
  s.executables = ['spnl-erb']
  s.add_runtime_dependency 'erb', '= 2.2.3'
end
