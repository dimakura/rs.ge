# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rs/version"

Gem::Specification.new do |s|
  s.name        = "rs.ge"
  s.version     = RS::VERSION
  s.authors     = ["Dimitri Kurashvili"]
  s.email       = ["dimitri@c12.ge"]
  s.homepage    = "http://c12.ge"
  s.summary     = %q{rs.ge web services}
  s.description = %q{ruby client for rs.ge web services}

  s.rubyforge_project = "rs"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec', '~> 2'
  s.add_development_dependency 'simplecov'

  s.add_runtime_dependency 'savon'
  s.add_runtime_dependency 'httpi'
  s.add_runtime_dependency 'prawn', '~>0.12'
end
