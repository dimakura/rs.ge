require "bundler/gem_tasks"

# RSpec
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:test) do |spec|
  spec.rspec_opts = ["--color", "--format progress"]
  spec.pattern = 'spec/**/*.rb'
  spec.verbose = false
end

task :default => :test
