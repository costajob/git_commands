Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each {|file| require file }
include Utils

namespace :git do
  desc 'Set base directory: i.e rake git:basedir projdir=/my/proj/dir filedir=/my/file/dir'
  task :basedirs do
    keys = %w[projdir filedir]
    Git::basedirs(options(keys))
  end
  
  desc 'Provide the GIT repository: i.e. rake git:repos'
  task :repo => :basedirs do
    Git::repo
  end
  
  desc 'Load the branches from an external file and/or by spcifing a specific one: i.e. rake git:branches file=aggregate branch=add_this_one'
  task :branches => :basedirs do
    keys = %w[file branch]
    Git::branches(options(keys))
  end
  
  desc 'Aligns specified branch with origin: i.e. rake git:align branch=my_branch'
  task :align => :repo do
    branch = ENV['branch'] || 'master'
    Git::align(branch)
  end
  
  desc 'Remove the specified branch/branches locally and from origin: i.e. rake git:remove file=remove'
  task :remove => [:repo, :branches] do
    Git::remove
  end
  
  desc 'Rebase the specified branches with master with options: i.e rake git:rebase file=rebase options=i'
  task :rebase => [:align, :branches] do
    options = ENV['opts'] ? ENV['opts'].split('') : []
    Git::rebase(options)
  end
  
  desc 'Aggregate specified branches into a single one: i.e. rake git:aggregate file=aggregate'
  task :aggregate => [:align, :branches] do
    Git::aggregate
  end
  
  def options(keys = [])
    hash = {}
    keys.each do |key|
      hash[key.to_sym] = ENV[key] if ENV[key]
    end
    hash
  end    
end

namespace :publishing do
  desc 'Create a SQL to output publishing jobs on QA server by starting date'
  task :jobs_from do
    starting_from = ENV['date'] || Date.today.strftime("%Y-%m-%d")
    SqlJobsAnalyzer::exec(starting_from)
  end
  
  desc 'Purge all of the published contents'
  task :purge do
    projdir = ENV['projdir'] || File.join(ENV['HOME'], 'Sites', 'oro')
    Purger::exec(projdir)
  end
end