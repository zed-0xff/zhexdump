# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zhexdump/version'

Gem::Specification.new do |gem|
  gem.name          = "zhexdump"
  gem.version       = ZHexdump::VERSION
  gem.authors       = ["Andrey \"Zed\" Zaikin"]
  gem.email         = ["zed.0xff@gmail.com"]
  gem.summary       = %q{A highly flexible hexdump implementation.}
  gem.description   = gem.summary
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rspec'
end
