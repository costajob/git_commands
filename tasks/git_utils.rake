require_relative '../lib/command'

namespace :git_utils do
  desc <<END
Setup the command instance:
  > rake git_utils:setup repo=git_repository base_dir=repo_path branches_file=file_listing_branches
  > rake git_utils:setup repo=git_repository base_dir=repo_path branch=single_branch_name
END
  task :setup do
    repo = ENV.fetch('repo') { fail ArgumentError, 'please specify a valid repository name!' }
    @command = GitUtils::Command::new(repo: repo, base_dir: ENV['base_dir'], branches_file: ENV['branches_file'], branch: ENV['branch'])
  end
  
  desc 'Load the branches from an external file or by spcifing one'
  task :branches => :setup do
    @command.branches
  end
  
  desc 'Purge specified branch/branches locally and from origin'
  task :purge => :branches do
    @command.purge
  end
  
  desc 'Rebase specified branch/branches with master'
  task :rebase => :branches do
    @command.rebase
  end
  
  desc 'Aggregate specified branches into a single one'
  task :aggregate => :branches do
    @command.aggregate
  end
end
