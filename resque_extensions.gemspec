# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque_extensions/version'

Gem::Specification.new do |gem|
  gem.name          = "resque_extensions"
  gem.version       = ResqueExtensions::VERSION
  gem.authors       = ["Dan Langevin"]
  gem.email         = ["dan.langevin@lifebooker.com"]
  gem.description   = %q{An extension to Resque that makes it act more like Delayed::Job}
  gem.summary       = %q{Resque extensions to add .async}
  gem.homepage      = "https://github.com/dlangevin/resque_extensions"

  # works with resque before 2.0
  gem.add_dependency "resque", "~> 1"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
