# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uberinstaller/version'

Gem::Specification.new do |gem|
  gem.name          = "uberinstaller"
  gem.version       = Uberinstaller::VERSION
  gem.authors       = ["Edoardo Tenani"]
  gem.email         = ["edoardo.tenani@gmail.com"]
  gem.description   = %q{Handle installation of packages from JSON files}
  gem.summary       = %q{Handle installation of packages from JSON files}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"] 

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end
