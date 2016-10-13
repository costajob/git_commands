module Mocks
  class Command
    def initialize(repo:, branches:)
      @repo = repo
      @branches = branches
    end

    %w[purge rebase aggregate].each do |msg|
      define_method(msg) do
        "#{msg} on #{@repo}"
      end
    end
  end

  class Prompt
    include GitCommands::Prompt

    def out
      @out ||= StringIO.new 
    end
  end
end
