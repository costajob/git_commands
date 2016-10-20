require "optparse"
require "git_commands/command"

module GitCommands
  class CLI
    include Prompt

    VALID_COMMANDS = %w[rebase aggregate purge]

    class UnknownCommandError < ArgumentError; end

    def initialize(command_name:, args: ARGV, out: STDOUT, command_klass: Command)
      @command_name = check_command_name(command_name)
      @command_klass = command_klass
      @args = args
      @out = out 
      @repo = nil
      @branches = nil
    end

    def call
      parser.parse!(@args)
      command = @command_klass.new(repo: @repo, branches: @branches)
      command.send(@command_name)
    rescue Command::GitError, AbortError, Repository::InvalidError => e
      error(e.message)  
      exit
    end

    private def create_command
      return @command if @command
    end

    private def check_command_name(name)
      return name if VALID_COMMANDS.include?(name)
      fail UnknownCommandError, "#{name} is not a supported command"
    end

    private def parser
      OptionParser.new do |opts|
        opts.banner = "Usage: #{@command_name} --repo=/Users/Elvis/greatest_hits --branches=feature/love_me_tender,fetaure/teddybear"

        opts.on("-rREPO", "--repo=REPO", "The path to the existing GIT repository") do |repo|
          @repo = repo
        end

        opts.on("-bBRANCHES", "--branches=BRANCHES", "Specify branches as: 1. a comma-separated list of names 2. the path to a file containing names on each line 3. via pattern matching") do |branches|
          @branches = branches
        end

        opts.on("-h", "--help", "Prints this help") do
          @out.puts opts
          exit
        end
      end
    end
  end
end