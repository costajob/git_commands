require "git_commands/prompt"
require "git_commands/branch"
require "git_commands/repository"
require "git_commands/aggregator"

module GitCommands
  class Computer
    include Prompt

    class GitError < StandardError; end

    attr_reader :out
    attr_accessor :target

    def initialize(repo:, branches:, origin: Branch::ORIGIN, target: Branch::MASTER, repo_klass: Repository, branch_klass: Branch, out: STDOUT)
      @out = out
      @repo = repo_klass.new(repo)
      @target = target
      @origin = origin
      Dir.chdir(@repo) do
        @branches = branch_klass.factory(branches)
        print_branches
      end
    end

    def remove
      enter_repo do
        confirm("Proceed removing these branches") do
          @branches.each do |branch|
            warning("Removing branch: #{branch}")
            `git branch -D #{branch}` if branch.exists?(false)
            `git push origin :#{branch}`
          end
        end
      end
    end

    def rebase
      confirm("Proceed rebasing these branches with #{@target}") do
        enter_repo do
          @branches.each do |branch|
            warning("Rebasing branch: #{branch}")
            `git checkout #{branch}`
            `git pull -r origin #{branch}`
            next unless rebase_with
            `git push --force-with-lease origin #{branch}`
            success("Rebased successfully!")
          end
          remove_locals
        end
      end
    end

    def aggregate(aggregator = Aggregator.new)
      temp = "temp/#{aggregator.timestamp}"
      aggregate_name = aggregator.call 
      confirm("Aggregate branches into #{aggregate_name}") do
        enter_repo do
          `git branch #{aggregate_name}`
          @branches.each do |branch|
            warning("Merging branch: #{branch}")
            `git checkout -b #{temp} origin/#{branch} --no-track`
            clean_and_exit([temp, aggregate_name]) unless rebase_with
            clean_and_exit([temp]) unless rebase_with(aggregate_name)
            `git checkout #{aggregate_name}`
            `git merge #{temp}`
            `git branch -D #{temp}`
          end      
        end
        success("#{aggregate_name} branch created")
      end
    end

    private def print_branches
      fail GitError, "No branches loaded!" if @branches.empty?
      size = @branches.to_a.size
      plural = size > 1 ? "es" : ""
      success("Successfully loaded #{size} branch#{plural}:")
      @out.puts @branches.each_with_index.map { |branch, i| "#{(i+1).to_s.rjust(2, "0")}. #{branch}" } + [""]
    end

    private def align
      `git fetch origin`
      `git fetch #{@origin} #{@target}`
      `git checkout #{@target}`
      `git pull -r`
    end

    private def rebase_with(branch = local_target)
      `git rebase #{branch}`
      return true unless @repo.locked?
      @repo.unlock
      error("Got conflicts, aborting rebase with #{branch}!")
    end

    private def local_target
      "#{@origin}/#{@target}"
    end

    private def enter_repo
      Dir.chdir(@repo) do
        align
        yield
      end
    end

    private def remove_locals(branches = @branches)
      `git checkout #{@target}`
      branches.each do |branch|
        `git branch -D #{branch}`
      end
    end

    private def clean_and_exit(branches)
      remove_locals(branches)
      exit
    end
  end
end
