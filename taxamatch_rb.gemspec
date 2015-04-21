# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'taxamatch_rb/version'

Gem::Specification.new do |gem|
  gem.name          = "taxamatch_rb"
  gem.version       = Taxamatch::VERSION
  gem.authors       = ["Dmitry Mozzherin"]
  gem.email         = ["dmozzherin@gmail.com"]

  gem.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  gem.description   = %q{TODO: Write a longer description or delete this line.}
  gem.homepage      = "TODO: Put your gem's website or public repo URL here."
  gem.license       = "MIT"

  gem.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  gem.bindir        = "exe"
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  if gem.respond_to?(:metadata)
    gem.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  gem.add_runtime_dependency "biodiversity", "~> 3.1"
  gem.add_runtime_dependency "damerau-levenshtein", "~> 0.5"
  gem.add_runtime_dependency "json", "~> 1.8"

  gem.add_development_dependency "bundler", "~> 1.6"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "rspec", "~> 2.1"
  gem.add_development_dependency "cucumber", "~> 1.3"
end
