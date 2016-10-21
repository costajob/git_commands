require "pathname"

module GitCommands
  class Repository
    LOCKING_FILES = %w(rebase-merge rebase-apply)

    class PathError < ArgumentError; end
    class InvalidError < StandardError; end

    def initialize(path)
      @path = Pathname::new(path.to_s)
      fail PathError, "'#{path}' must be an absolute path!" unless @path.absolute?
      fail InvalidError, "'#{path}' is not a valid GIT repository!" unless valid?
    end

    def to_path
      @path.to_s
    end

    def locked?
      LOCKING_FILES.any? do |name| 
        @path.join(".git", name).exist?
      end
    end

    def unlock
      Dir.chdir(self) do
        `git rebase --abort`
      end
    end

    private def valid?
      @path.directory? && work_tree?
    end

    private def work_tree?
      Dir.chdir(self) do
        `git rev-parse --is-inside-work-tree 2> /dev/null`.strip == "true"
      end
    end
  end
end
