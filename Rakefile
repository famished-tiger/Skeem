# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

# Combine RSpec and Cucumber tests
desc 'Run tests, with RSpec'
task test: :spec

task default: :test
