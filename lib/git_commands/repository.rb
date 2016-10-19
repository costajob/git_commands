require "pathname"

module GitCommands
  class Repository
    LOCKING_FILES = %w(rebase-merge rebase-apply)

    class InvalidError < StandardError; end

    def initialize(path)
      @path = Pathname::new(path.to_s)
      fail InvalidError, "'#{path}' is not a valid GIT repository!" unless valid?
    end

    def to_path
      @path.to_s
    end

    def locked?
      LOCKING_FILES.any? do |name| 
        File.exists?(@path.join(".git", name))
      end
    end

    private def valid?
      return false unless exists?
      work_tree?
    end

    private def exists?
      File.directory?(@path)
    end

    private def work_tree?
      Dir.chdir(@path) do
        `git rev-parse --is-inside-work-tree 2> /dev/null`.strip == "true"
      end
    end
  end
end
