# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uberinstaller/version'

Gem::Specification.new do |gem|
  gem.name          = "uberinstaller"
  gem.version       = Uberinstaller::VERSION
  gem.authors       = ["Edoardo Tenani"]
  gem.email         = ["edoardo.tenani@gmail.com"]
  gem.description   = <<-LONGDESC 
  Uberinstaller is a ruby gem that make easy to install system packages from a JSON configuration file.
  Thinked for Ubuntu, can handle pre and post installation commands, repositories and PPA, package installation from system repositories, git repositories or local files.

  Supports different Package Managers as the defaults one can be modified, extended and changed as needed.
  LONGDESC
  gem.summary       = %q{Install lots of system packages from a single JSON configuration file}
  gem.homepage      = "https://github.com/endorama/UberInstaller"
  gem.license = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"] 

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'redcarpet'
  gem.add_development_dependency 'yard'

  gem.add_runtime_dependency 'colored'
  gem.add_runtime_dependency 'hash_keyword_args'
  gem.add_runtime_dependency 'octokit'
  gem.add_runtime_dependency 'thor'
end
