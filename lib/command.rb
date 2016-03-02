require 'pathname'
require 'fileutils'
require 'net/http'
require_relative './prompt'

module GitUtils
  class Command
    include Prompt

    class GitError < StandardError; end
    class NoBranchesError < StandardError; end

    GITHUB_HOST = 'github.com'
    BASE_DIR = File.join(ENV['HOME'], 'Sites')
    UNFINISHED_REBASE_FILES = %w(rebase-merge rebase-apply)

    def self.check_connection
      !!Net::HTTP.new(GITHUB_HOST).head('/')
    rescue Errno::ENETUNREACH => e
      raise e, 'There is no connection!'
    end

    def initialize(repo:, base_dir: nil, branches_file: nil, branches: nil)
      self.class.check_connection
      @repo = repo || error(message: 'Please specify a valid repository name!', error: ArgumentError)
      @base_dir = base_dir || BASE_DIR
      @branches_file = branches_file || repo_path.join('.branches')
      @branches = branches.to_s.split(',')
      fetch_branches
      check_branches
    end

    def purge
      enter_repo do
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
      confirm('Proceed rebasing these branches') do
        enter_repo do
          @branches.each do |branch|
            warning(message: "Rebasing branch: #{branch}")
            `git checkout #{branch}`
            `git pull origin #{branch}`
            rebase_with_master
            `git push origin #{branch} -f`
            `git checkout master`
            `git branch -D #{branch}`
            success 'Rebased successfully!'
          end
        end
      end
    end

    def aggregate
      temp = "temp_#{aggregate_name}"
      confirm("Aggregate branches into #{aggregate_name}") do
        enter_repo do
          `git branch #{aggregate_name}`
          @branches.each do |branch|
            warning(message: "Merging branch: #{branch}")
            `git checkout -b #{temp} origin/#{branch} --no-track`
            rebase_with_master
            `git rebase #{aggregate_name}`
            `git checkout #{aggregate_name}`
            `git merge #{temp}`
            `git branch -d #{temp}`
          end      
        end
        success 'Aggregate branch created'
      end
    end

    private 

    def repo_path
      @repo_path ||= Pathname::new(File.join(@base_dir, @repo))
    end

    def fetch_branches
      return unless @branches.empty? && File.exist?(@branches_file)
      warning(message: 'Loading branches file')
      @branches = File.foreach(@branches_file).map(&:strip)
    end

    def check_branches
      error(message: 'No branches have been loaded!', error: NoBranchesError) if @branches.empty?
      print_branches
    end

    def print_branches
      size = @branches.to_a.size
      plural = size > 1 ? 'es' : ''
      success "Successfully loaded #{size} branch#{plural}:"
      puts @branches.each_with_index.map { |branch, i| "#{(i+1).to_s.rjust(2, '0')}. #{branch}" } + ['']
    end

    def pull_master
      `git checkout master`
      `git pull`
    end

    def rebase_with_master
      `git rebase origin/master`
      error(message: 'Halting unfinished rebase!', error: GitError) { `git rebase --abort` } if unfinished_rebase?
    end

    def enter_repo
      Dir.chdir repo_path do
        pull_master
        yield
      end
    end

    def unfinished_rebase?
      UNFINISHED_REBASE_FILES.any? do |name| 
        File.exists?(repo_path.join('.git', name))
      end
    end

    def aggregate_name
      @aggregate_name ||= Time.new.strftime("rb_%Y-%m-%d")
    end
  end
end
