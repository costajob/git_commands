require "pathname"
require "fileutils"
require "net/http"
require "git_commands/prompt"

module GitCommands
  class Command
    include Prompt

    class GitError < StandardError; end
    class NoBranchesError < StandardError; end
    class NoentRepositoryError < ArgumentError; end

    GITHUB_HOST = "github.com"
    UNFINISHED_REBASE_FILES = %w(rebase-merge rebase-apply)

    def self.check_connection
      !!Net::HTTP.new(GITHUB_HOST).head("/")
    rescue Errno::ENETUNREACH => e
      raise e, "There is no connection!"
    end

    attr_reader :out

    def initialize(repo:, branches:, out: STDOUT)
      self.class.check_connection
      @out = out
      @repo = fetch_repo(repo)
      @branches = fetch_branches(branches)
      @timestamp = Time.new.strftime("%Y-%m-%d")
      check_branches
    end

    def purge
      enter_repo do
        @branches.each do |branch|
          error("Trying ro remove master!", GitError) if branch == "master"
          warning("Removing branch: #{branch}")
          confirm("Remove local branch") do
            `git branch -D #{branch}`
          end
          confirm("Remove remote branch") do
            `git push origin :#{branch}`
          end
        end
      end
    end

    def rebase
      confirm("Proceed rebasing these branches") do
        enter_repo do
          @branches.each do |branch|
            warning("Rebasing branch: #{branch}")
            `git checkout #{branch}`
            `git pull origin #{branch}`
            rebase_with_master
            `git push origin #{branch}`
            `git checkout master`
            `git branch -D #{branch}`
            success "Rebased successfully!"
          end
        end
      end
    end

    def aggregate
      temp = "temp/#{@timestamp}"
      aggregate = "release/#{@timestamp}"
      confirm("Aggregate branches into #{aggregate}") do
        enter_repo do
          `git branch #{aggregate}`
          @branches.each do |branch|
            warning("Merging branch: #{branch}")
            `git checkout -b #{temp} origin/#{branch} --no-track`
            rebase_with_master
            `git rebase #{aggregate}`
            `git checkout #{aggregate}`
            `git merge #{temp}`
            `git branch -d #{temp}`
          end      
        end
        success "#{aggregate} branch created"
      end
    end

    private def fetch_repo(repo)
      return Pathname::new(repo) if File.exist?(repo)
      fail NoentRepositoryError, "#{repo} is not a valid GIT repository!" 
    end

    private def check_branches
      error("No branches have been loaded!", NoBranchesError) if @branches.empty?
      print_branches
    end

    private def fetch_branches(branches)
      warning("Loading branches file")
      return File.foreach(branches).map(&:strip) if File.exist?(branches)
      branches.to_s.split(",").map(&:strip) 
    end

    private def print_branches
      size = @branches.to_a.size
      plural = size > 1 ? "es" : ""
      success "Successfully loaded #{size} branch#{plural}:"
      @out.puts @branches.each_with_index.map { |branch, i| "#{(i+1).to_s.rjust(2, "0")}. #{branch}" } + [""]
    end

    private def pull_master
      `git checkout master`
      `git pull`
    end

    private def rebase_with_master
      `git rebase origin/master`
      error("Halting unfinished rebase!", GitError) { `git rebase --abort` } if unfinished_rebase?
    end

    private def enter_repo
      Dir.chdir(@repo) do
        pull_master
        yield
      end
    end

    private def unfinished_rebase?
      UNFINISHED_REBASE_FILES.any? do |name| 
        File.exists?(@repo.join(".git", name))
      end
    end
  end
end
