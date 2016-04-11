# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git_utils/version'

Gem::Specification.new do |s|
  s.name = "git_utils"
  s.version = GitUtils::VERSION
  s.authors = ["costajob"]
  s.email = ["costajob@gmail.com"]
  s.summary = "Utility library to rebase and aggregate your project branches"
  s.homepage = "https://github.com/costajob/git_utils.git"
  s.license = "MIT"
  s.required_ruby_version = ">= 1.9.2"
  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|s|features)/}) }
  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "rr"
end
