# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'rs/version'

Gem::Specification.new do |s|
  s.name        = 'rs.ge'
  s.version     = RS::VERSION
  s.authors     = [ 'Dimitri Kurashvili' ]
  s.email       = [ 'dimakura@gmail.com' ]
  s.homepage    = 'http://carbon.ge'
  s.summary     = %q{rs.ge web services}
  s.description = %q{Ruby client for rs.ge web services}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = [ 'lib' ]

  s.add_dependency 'savon', '~>2.2'
end
