require_relative '../lib/command'

namespace :git_utils do
  desc <<END
Setup the command instance:
  > rake git_utils:setup repo=git_repository base_dir=repo_path branches_file=file_listing_branches branches=list,of,branches,separated,by,comma
END
  task :setup do
    @command = GitUtils::Command::new(repo: ENV['repo'], base_dir: ENV['base_dir'], branches_file: ENV['branches_file'], branches: ENV['branches'])
  end
  
  desc 'Purge specified branches locally and from origin'
  task :purge => :setup do
    @command.purge
  end
  
  desc 'Rebase specified branches with master'
  task :rebase => :setup do
    @command.rebase
  end
  
  desc 'Aggregate specified branches into a single one'
  task :aggregate => :setup do
    @command.aggregate
  end
end
