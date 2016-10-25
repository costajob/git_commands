require "pathname"

module GitCommands
  using Colorize
  class Branch
    MASTER = "master"
    ORIGIN = "origin/"

    def self.strip_origin(name)
      name.strip.split(ORIGIN).last
    end

    def self.by_file(path)
      return [] unless valid_path?(path)
      File.foreach(path).map do |name|
        new(name.strip)
      end.select(&:valid?)
    end

    def self.by_pattern(pattern)
      return [] unless pattern.index("*")
      `git branch -r --list #{ORIGIN}#{pattern}`.split("\n").map do |name|
        new(strip_origin(name))
      end.reject(&:master?)
    end

    def self.by_names(names_list)
      String(names_list).split(",").map do |name|
        new(name.strip)
      end.select(&:valid?)
    end

    def self.factory(src)
      return [] unless src
      branches = by_file(src)
      branches = by_pattern(src) if branches.empty?
      branches = by_names(src) if branches.empty?
      branches
    end

    def self.valid_path?(path)
      path = Pathname.new(path)
      path.absolute? && path.file?
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

    def master?
      @name == MASTER
    end

    def exists?(remote = true)
      origin = ORIGIN if remote
      `git rev-parse --verify #{origin}#{@name} 2> /dev/null`.match(/^[0-9a-z]+/)
    end
  end
end
