require "pathname"
require "fileutils"
require "net/http"
require "git_commands/prompt"
require "git_commands/branch"
require "git_commands/repository"

module GitCommands
  class Command
    include Prompt

    class GitError < StandardError; end

    attr_reader :out

    def initialize(repo:, branches:, repo_klass: Repository, branch_klass: Branch, out: STDOUT)
      @out = out
      @repo = repo_klass.new(repo)
      @conflictual = []
      Dir.chdir(@repo) do
        @branches = branch_klass.factory(branches)
        @timestamp = Time.new.strftime("%Y-%m-%d")
        print_branches
      end
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
      confirm("Proceed rebasing these branches with master") do
        enter_repo do
          @branches.each do |branch|
            warning("Rebasing branch: #{branch}")
            `git checkout #{branch}`
            `git pull origin #{branch}`
            @conflictual << branch && next unless rebase_with_master
            `git push -f origin #{branch}`
            `git checkout #{Branch::MASTER}`
            `git branch -D #{branch}`
            success "Rebased successfully!"
          end
          delete_conflictual
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
            @conflictual << branch && next unless rebase_with_master
            `git rebase #{aggregate}`
            `git checkout #{aggregate}`
            `git merge #{temp}`
            `git branch -d #{temp}`
          end      
          `git checkout #{Branch::MASTER}`
        end
        delete_conflictual
        success "#{aggregate} branch created"
      end
    end

    private def print_branches
      fail GitError, "No branches loaded!" if @branches.empty?
      size = @branches.to_a.size
      plural = size > 1 ? "es" : ""
      success "Successfully loaded #{size} branch#{plural}:"
      @out.puts @branches.each_with_index.map { |branch, i| "#{(i+1).to_s.rjust(2, "0")}. #{branch}" } + [""]
    end

    private def pull_master
      `git checkout #{Branch::MASTER}`
      `git pull`
    end

    private def rebase_with_master
      `git rebase origin/#{Branch::MASTER}`
      return true unless @repo.locked?
      `git rebase --abort`
      error("Got conflicts, aborting rebase!")
    end

    private def delete_conflictual
      return if @conflictual.empty?
      @conflictual.each do |branch|
        `git branch -D #{branch}`
      end
    end

    private def enter_repo
      Dir.chdir(@repo) do
        pull_master
        yield
      end
    end
  end
end
