require "spec_helper"

describe GitCommands::CLI do
  it "must raise an error for unknown command" do
    -> { GitCommands::CLI.new(command_name: "noent") }.must_raise GitCommands::CLI::UnknownCommandError
  end

  it "must call the spcified command on the built instance" do
    repo = "/Users/Elvis/greatest_hits"
    GitCommands::CLI::VALID_COMMANDS.each do |name|
      cli = GitCommands::CLI.new(command_name: name, 
                                 args: %W[--repo=#{repo} --branches=teddybear,love_me_tender], 
                                 command_klass: Mocks::Command)
      cli.call.must_equal "#{name} on #{repo}"
    end
  end

  it "must print the help" do
    out = StringIO.new
    cli = GitCommands::CLI.new(command_name: "rebase", 
                               args: %w[--help],
                               out: out,
                               command_klass: Mocks::Command)

    begin
      cli.call
    rescue SystemExit
      out.string.must_equal "Usage: rebase --repo=/Users/Elvis/greatest_hits --branches=feature/love_me_tender,fetaure/teddybear\n    -r, --repo=REPO                  The path to the existing GIT repository\n    -b, --branches=BRANCHES          Specify branches as: 1. a comma-separated list of names 2. the path to a file containing names on each line 3. via pattern matching\n    -h, --help                       Prints this help\n"
    end
  end
end
