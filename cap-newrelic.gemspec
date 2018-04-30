# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'cap-newrelic'
  spec.version       = '0.4.1'
  spec.authors       = 'Robert Coleman'
  spec.email         = 'github@robert.net.nz'
  spec.homepage      = 'http://github.com/rjocoleman/cap-newrelic'
  spec.summary       = 'New Relic Deployment API notification for Capistrano v3+'
  spec.description   = 'New Relic Deployment API notification for Capistrano v3+'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '~> 3.2', '>= 3.2'
  spec.add_dependency 'faraday',    '~> 0.9'
end
