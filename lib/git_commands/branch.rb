module GitCommands
  class Branch
    MASTER = "master"
    ORIGIN = "origin/"

    def self.strip_origin(name)
      name.strip.split(ORIGIN).last
    end

    def self.by_names(names_list)
      String(names_list).split(",").map do |name|
        new(name.strip)
      end.select(&:valid?)
    end

    def self.by_file(names_file)
      return [] unless File.file?(names_file)
      File.foreach(names_file).map do |name|
        new(name.strip)
      end.select(&:valid?)
    end

    def self.by_pattern(pattern)
      return [] unless pattern.index("*")
      `git branch -r --list #{ORIGIN}#{pattern}`.split("\n").map do |name|
        new(strip_origin(name))
      end
    end

    def self.factory(src)
      return [] unless src
      branches = by_file(src)
      branches = by_pattern(src) if branches.empty?
      branches = by_names(src) if branches.empty?
      branches
    end

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def to_s
      @name
    end

    def valid?
      return false if master?
      return false unless exists?
      true
    end

    def ==(other)
      self.name == other.name
    end

    private def master?
      @name == MASTER
    end

    private def exists?
      `git rev-parse --verify origin/#{@name} 2> /dev/null`.match(/^[0-9a-z]+/)
    end
  end
end
