lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json_resource/version'

Gem::Specification.new do |s|
  s.name          = 'json_resource'
  s.version       = JsonResource::VERSION
  s.authors       = ['Matthias Grosser']
  s.email         = ['mtgrosser@gmx.net']
  s.license       = 'MIT'

  s.summary       = 'Create Ruby objects from JSON data'
  s.homepage      = 'https://github.com/mtgrosser/json_resource'

  s.files = ['LICENSE', 'README.md', 'CHANGELOG.md'] + Dir['lib/**/*.{rb}']
  
  s.required_ruby_version = '>= 2.6.0'

  s.add_dependency 'json'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'irb'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'webmock'
end
