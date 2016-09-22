require 'bundler/gem_tasks'
require 'rake/testtask'
import 'lib/tasks/git_commands.rake'

Rake::TestTask.new(:spec) do |t|
  t.libs << 'lib'
  t.libs << 'spec'
  t.test_files = FileList['spec/*_spec.rb']
end

task :default => :spec
