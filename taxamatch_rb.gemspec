# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{taxamatch_rb}
  s.version = "0.6.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dmitry Mozzherin"]
  s.date = %q{2010-03-30}
  s.description = %q{This gem implements algorithsm for fuzzy matching scientific names developed by Tony Rees}
  s.email = %q{dmozzherin@eol.org}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "README.rdoc",
     "lib/taxamatch_rb.rb",
     "lib/taxamatch_rb/atomizer.rb",
     "lib/taxamatch_rb/authmatch.rb",
     "lib/taxamatch_rb/damerau_levenshtein_mod.rb",
     "lib/taxamatch_rb/normalizer.rb",
     "lib/taxamatch_rb/phonetizer.rb",
     "spec/damerau_levenshtein_mod_test.txt",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/taxamatch_rb_spec.rb",
     "spec/taxamatch_test.txt"
  ]
  s.homepage = %q{http://github.com/dimus/taxamatch_rb}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Implementation of Tony Rees Taxamatch algorithms}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/taxamatch_rb_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<RubyInline>, [">= 0"])
      s.add_runtime_dependency(%q<biodiversity>, [">= 0.5.13"])
    else
      s.add_dependency(%q<RubyInline>, [">= 0"])
      s.add_dependency(%q<biodiversity>, [">= 0.5.13"])
    end
  else
    s.add_dependency(%q<RubyInline>, [">= 0"])
    s.add_dependency(%q<biodiversity>, [">= 0.5.13"])
  end
end

