# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tokeneyes/version'

Gem::Specification.new do |spec|
  spec.name          = "tokeneyes"
  spec.version       = Tokeneyes::VERSION
  spec.authors       = ["Alex Koppel"]
  spec.email         = ["alex@alexkoppel.com"]

  spec.summary       = %q{A simple string tokenizer designed to capture punctuation and sentence flow information.}
  spec.description   = %q{A simple string tokenizer designed to capture punctuation and sentence flow information.}
  spec.homepage      = "https://github.com/arsduo/tokeneyes"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "faker"
end
