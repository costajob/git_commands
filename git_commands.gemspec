# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git_commands/version'

Gem::Specification.new do |s|
  s.name = "git_commands"
  s.version = GitCommands::VERSION
  s.authors = ["costajob"]
  s.email = ["costajob@gmail.com"]
  s.summary = "Utility library to rebase and aggregate your project branches"
  s.homepage = "https://github.com/costajob/git_commands.git"
  s.license = "MIT"
  s.required_ruby_version = ">= 2.1.8"

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|s|features)/}) }
  s.bindir = "bin"
  s.executables = %w[rebase aggregate purge]
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.11"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "rr", "~> 1.2"
end
