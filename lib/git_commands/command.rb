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

    def self.git_repo?(repo)
      `git rev-parse --is-inside-work-tree 2> /dev/null`.strip == "true"
    end

    def self.valid_branch?(branch)
      `git rev-parse --verify origin/#{branch} 2> /dev/null`.match(/^[0-9a-z]+/)
    end

    attr_reader :out

    def initialize(repo:, branches:, out: STDOUT)
      self.class.check_connection
      @out = out
      @repo = fetch_repo(repo)
      @branches = fetch_branches(String(branches))
      @timestamp = Time.new.strftime("%Y-%m-%d")
      print_branches
    end

    def purge
      enter_repo do
        @branches.each do |branch|
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
            `git checkout master`
          end      
        end
        success "#{aggregate} branch created"
      end
    end

    private def fetch_repo(repo)
      fail NoentRepositoryError, "'#{repo}' is not a valid GIT repository!" unless valid_repo?(repo)
      Pathname::new(repo)
    end

    private def valid_repo?(repo)
      return false unless File.directory?(repo)
      Dir.chdir(repo) do
        self.class.git_repo?(repo)
      end
    end

    private def fetch_branches(src)
      warning("Loading branches file")
      branches = File.foreach(src).map(&:strip) if valid_file?(src)
      branches ||= src.split(",").map(&:strip) 
      branches.tap do |list|
        fail(NoBranchesError, "No branches have been loaded!") if list.empty?
        list.each { |branch| check_branch(branch) }
      end
    end

    private def check_branch(branch)
      Dir.chdir(@repo) do
        fail(GitError, "Master branch cannot be included into commands operations!") if branch == "master"
        fail(GitError, "Branch '#{branch}' does not exist!") unless self.class.valid_branch?(branch)
      end
    end

    private def valid_file?(branches)
      File.exist?(branches) && !File.directory?(branches)
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
      if unfinished_rebase?
        `git rebase --abort`
        fail(GitError, "Halting unfinished rebase!")
      end
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
