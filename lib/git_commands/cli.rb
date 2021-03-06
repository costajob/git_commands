require "optparse"
require "git_commands/computer"

module GitCommands
  class CLI
    include Prompt

    VALID_COMMANDS = %w[rebase aggregate remove]

    class UnknownCommandError < ArgumentError; end

    def initialize(command_name:, args: ARGV, out: STDOUT, computer_klass: Computer)
      @command_name = check_command_name(command_name)
      @computer_klass = computer_klass
      @args = args
      @out = out 
      @repo = nil
      @branches = nil
    end

    def call
      parser.parse!(@args)
      @origin ||= Branch::ORIGIN
      @default ||= Branch::DEFAULT
      computer = @computer_klass.new(repo: @repo, branches: @branches, origin: @origin, default: @default)
      computer.send(@command_name)
    rescue Repository::PathError, Computer::GitError, AbortError, Repository::InvalidError => e
      error(e.message)  
      exit
    end

    private def check_command_name(name)
      return name if VALID_COMMANDS.include?(name)
      fail UnknownCommandError, "#{name} is not a supported command"
    end

    private def parser
      OptionParser.new do |opts|
        opts.banner = "Usage: #{@command_name} --repo=~/greatest_hits --origin=upstream --default=production --branches=feature/love_me_tender,fetaure/teddybear"

        opts.on("-rREPO", "--repo=REPO", "The path to the existing GIT repository") do |repo|
          @repo = File.expand_path(repo)
        end

        opts.on("-oORIGIN", "--origin=ORIGIN", "Specify the remote alias (origin)") do |origin|
          @origin = origin
        end

        opts.on("-dDEFAULT", "--default=DEFAULT", "Specify the default branch (master)") do |default|
          @default = default
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
