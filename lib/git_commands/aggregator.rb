module GitCommands
  class Aggregator
    PATTERN = ENV.fetch("AGGREGATE_PATTERN") { "release/<timestamp>" }
    NAME = ENV["AGGREGATE_NAME"]

    class InvalidPatternError < ArgumentError; end

    def initialize(name: NAME, pattern: PATTERN)
      @name = name
      @pattern = check_pattern(pattern)
      define_methods
    end

    def timestamp
      @timestamp ||= Time.new.strftime("%Y%m%d")
    end

    def call
      return @name if @name
      @pattern.gsub(/<[\w_]+>/) do |part|
        msg = part.gsub(/<|>/, "")
        send(msg)
      end
    end

    private def check_pattern(pattern)
      fail InvalidPatternError unless pattern.match(/<\w+>/) 
      pattern
    end

    private def pattern_methods
      @methods ||= @pattern.scan(/<(\w+)>/).flatten - ["timestamp"]
    end

    def define_methods
      pattern_methods.each do |name|
        define_singleton_method(name) do
          ENV.fetch(name.upcase) { "" }
        end
      end
    end
  end
end
