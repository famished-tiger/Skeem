# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'skeem/version'

# Implementation module
module PkgExtending
  def self.pkg_files(aPackage)
    file_list = Dir[
      '.rubocop.yml',
      '.rspec',
      '.travis.yml',
      '.yardopts',
      'appveyor.yml',
      'Gemfile',
      'Rakefile',
      'CHANGELOG.md',
      'LICENSE.txt',
      'README.md',
      'skeem.gemspec',
      'bin/*.*',
      'lib/*.*',
      'lib/**/*.rb',
      'lib/**/*.skm',
      'spec/**/*.rb',
      'spec/**/*.skm',
      'spec/**/*.yml'
    ]
    aPackage.files = file_list
    aPackage.test_files = Dir['spec/**/*_spec.rb']
    aPackage.require_path = 'lib'
  end

  def self.pkg_documentation(aPackage)
    aPackage.rdoc_options << '--charset=UTF-8 --exclude="examples|spec"'
    aPackage.extra_rdoc_files = ['README.md']
  end
end # module


Gem::Specification.new do |spec|
  spec.name          = 'skeem'
  spec.version       = Skeem::VERSION
  spec.authors       = ['Dimitri Geshef']
  spec.email         = ['famished.tiger@yahoo.com']

  spec.description = <<-DESCR
  Skeem is a Scheme language interpreter implemented in Ruby.
DESCR
  spec.summary = <<-SUMMARY
  Skeem is an interpreter of a subset of the Scheme programming language.
  Scheme is a descendent of the Lisp language.
SUMMARY
  spec.homepage      = 'https://github.com/famished-tiger/Skeem'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.5.0'

  spec.bindir = 'bin'
  spec.executables << 'skeem'
  spec.require_paths = ['lib']
  PkgExtending.pkg_files(spec)
  PkgExtending.pkg_documentation(spec)
  # Runtime dependencies
  spec.add_dependency 'rley', '~> 0.8.03'

  # Development dependencies
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
