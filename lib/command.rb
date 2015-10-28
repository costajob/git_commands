require 'pathname'
require 'fileutils'
require_relative './prompt'

module GitUtils
  using Colorize
  class Command
    include Prompt

    class GitError < StandardError; end
    class NoBranchesError < StandardError; end

    BASE_DIR = File.join(ENV['HOME'], 'Sites')
    UNFINISHED_REBASE_FILES = %w(rebase-merge rebase-apply)

    def initialize(repo:, base_dir: nil, branches_file: nil, branches: nil)
      @repo = repo || fail(ArgumentError, 'Please specify a valid repository name!')
      @base_dir = base_dir || BASE_DIR
      @branches_file = branches_file || repo_path.join('.branches')
      @branches = branches.to_s.split(',') + fetch_branches
      confirm_branches
    end

    def align_master
      warning(message: 'Aligning master branch')
      Dir.chdir repo_path do
        `git checkout master`
        `git pull`
      end
    end

    def purge
      Dir.chdir repo_path do
        %x[git checkout master]
        @branches.each do |branch|
          error(message: 'Trying ro remove master!', error: GitError) if branch == 'master'
          warning(message: "Removing branch: #{branch}")
          confirm('Remove local branch') do
            `git branch -D #{branch}`
          end
          confirm('Remove remote branch') do
            `git push origin :#{branch}`
          end
        end
      end
    end

    def rebase
      align_master
      Dir.chdir repo_path do
        @branches.each do |branch|
          warning(message: "Rebasing branch: #{branch}")
          `git checkout #{branch}`
          `git pull origin #{branch}`
          `git rebase origin/master`
          error(message: 'Halting unfinished rebase', error: GitError) { `git rebase --abort` } if unfinished_rebase?
          `git push origin #{branch} -f`
          `git checkout master`
          `git branch -D #{branch}`
          success 'Rebased successfully!'
        end
      end
    end

    def aggregate
      temp = "temp_#{aggregate_branch}"
      warning(message: "Creating aggregate branch: #{aggregate_branch}")
      Dir.chdir repo_path do
        `git branch #{aggregate_branch}`
        @branches.each do |branch|
          `git checkout -b #{temp} origin/#{branch} --no-track`
          `git rebase origin/master`
          `git rebase #{aggregate_branch}`
          `git checkout #{aggregate_branch}`
          `git merge #{temp}`
          `git branch -d #{temp}`
        end      
      end
      success 'Aggregate branch created'
    end

    private 

    def fetch_branches
      return [] unless File.exist?(@branches_file)
      warning(message: 'Loading branches file')
      File.foreach(@branches_file).map(&:strip)
    end

    def repo_path
      @repo_path ||= Pathname::new(File.join(@base_dir, @repo))
    end

    def unfinished_rebase?
      UNFINISHED_REBASE_FILES.any? do |name| 
        File.exists?(repo_path.join('.git', name))
      end
    end

    def aggregate_branch
      @aggregate_branch ||= Time.new.strftime("rb_%Y-%m-%d")
    end

    def confirm_branches
      error(message: 'No branches have been loaded!', error: NoBranchesError) if @branches.empty?
      size = @branches.to_a.size
      plural = size > 1 ? 'es' : ''
      success "Successfully loaded #{size} branch#{plural}:"
      puts @branches.each_with_index.map { |branch, i| "#{i+1}. #{branch}" }
    end
  end
end
