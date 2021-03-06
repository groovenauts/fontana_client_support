# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fontana_client_support/version'

Gem::Specification.new do |spec|
  spec.name          = "fontana_client_support"
  spec.version       = FontanaClientSupport::VERSION
  spec.authors       = ["akima"]
  spec.email         = ["t-akima@groovenauts.jp"]
  spec.description   = %q{gem to support development and testing with GSS/fontana}
  spec.summary       = %q{gem to support development and testing with GSS/fontana}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "httpclient"
  spec.add_development_dependency "json"
end
