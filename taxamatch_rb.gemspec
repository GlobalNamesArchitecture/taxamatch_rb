# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'taxamatch_rb/version'

Gem::Specification.new do |gem|
  gem.name          = "taxamatch_rb"
  gem.version       = Taxamatch::VERSION
  gem.authors       = ["Dmitry Mozzherin"]
  gem.email         = ["dmozzherin@gmail.com"]

  gem.summary       = %q{Fuzzy matching of scientific names}
  gem.description   = "The purpose of Taxamatch gem is to facilitate fuzzy" \
                      "comparison of two scientific name renderings to find" \
                      "out if they actually point to the same scientific name."
  gem.homepage      = "https://github.com/GlobalNamesArchitecture/taxamatch_rb"
  gem.license       = "MIT"

  gem.files         = `git ls-files -z`.split("\x0").
                      reject { |f| f.match(%r{^(test|spec|features)/}) }
  gem.bindir        = "exe"
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "biodiversity", "~> 3.1"
  gem.add_runtime_dependency "damerau-levenshtein", "~> 1.0"
  gem.add_runtime_dependency "json", "~> 1.8"

  gem.add_development_dependency "bundler", "~> 1.6"
  gem.add_development_dependency "rake", "~> 10.4"
  gem.add_development_dependency "rspec", "~> 3.2"
  gem.add_development_dependency "cucumber", "~> 2.0"
end
