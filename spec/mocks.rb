module Mocks
  def `(command)
    case command
    when /^git branch -r/
      "  master\n  origin/feature/love-me-tender\n  origin/feature/all-shock-up\n  origin/feature/dont-be-cruel\n"
    when /^git rev-parse --verify origin/ 
      "830537aa0d35ae6b3a44610a1a0c1d7388224ca7"
    when /^git rev-parse --is-inside-work-tree/
      "true"
    else
      command
    end
  end

  class Repository
    attr_reader :path

    def initialize(path)
      @path = Pathname.new(path)
    end

    def to_path
      @path.to_s
    end

    def locked?
      false
    end
  end

  class Branch
    def self.factory(src)
      src.split(",").map do |name|
        new(name.strip)
      end
    end

    def initialize(name)
      @name = name
    end

    def to_s
      @name
    end

    def valid?
      true
    end

    def exists?(remote = true)
      true
    end
  end

  class Computer
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
