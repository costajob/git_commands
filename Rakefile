require 'rake/testtask'
import 'tasks/git_utils.rake'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
end

task :default => :test
