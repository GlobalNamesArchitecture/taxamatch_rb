# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{taxamatch_rb}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dmitry Mozzherin"]
  s.date = %q{2009-07-29}
  s.email = %q{dmozzherin@eol.org}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "features/step_definitions/common_steps.rb",
     "features/step_definitions/taxamatch_rb.rb",
     "features/support/common.rb",
     "features/support/env.rb",
     "features/support/matchers.rb",
     "features/taxamatch_rb.feature",
     "lib/taxamatch_rb.rb",
     "lib/taxamatch_rb/damerau_levenshtein_mod.rb",
     "lib/taxamatch_rb/normalizer.rb",
     "lib/taxamatch_rb/parser.rb",
     "lib/taxamatch_rb/phonetizer.rb",
     "spec/damerau_levenshtein_mod_test.txt",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/taxamatch_rb_spec.rb",
     "taxamatch_rb.gemspec"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/dimus/taxamatch_rb}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/taxamatch_rb_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<RubyInline>, [">= 0"])
      s.add_runtime_dependency(%q<dimus-biodiversity>, [">= 0"])
    else
      s.add_dependency(%q<RubyInline>, [">= 0"])
      s.add_dependency(%q<dimus-biodiversity>, [">= 0"])
    end
  else
    s.add_dependency(%q<RubyInline>, [">= 0"])
    s.add_dependency(%q<dimus-biodiversity>, [">= 0"])
  end
end
