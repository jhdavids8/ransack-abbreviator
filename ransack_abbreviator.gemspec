# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ransack_abbreviator/version"

Gem::Specification.new do |s|
  s.name        = "ransack_abbreviator"
  s.version     = RansackAbbreviator::VERSION
  s.authors     = ["Jamie Davidson"]
  s.email       = ["jhdavids8@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "ransack_abbreviator"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'ransack', '~> 0.7'
  s.add_development_dependency 'rspec', '~> 2.8.0'
  s.add_development_dependency 'machinist', '~> 1.0.6'
  s.add_development_dependency 'faker', '~> 0.9.5'
  s.add_development_dependency 'sqlite3', '~> 1.3.3'
end
