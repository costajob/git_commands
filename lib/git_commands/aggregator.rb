module GitCommands
  class Aggregator
    PATTERN = ENV.fetch("AGGREGATOR_PATTERN") { "release/rc-<progressive>.<release_type>_<risk>_<timestamp>" }
    NAME = ENV["AGGREGATOR_NAME"]

    class InvalidPatternError < ArgumentError; end

    def initialize(name: NAME, pattern: PATTERN)
      @name = name
      @pattern = check_pattern(pattern)
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

    private def progressive
      ENV.fetch("PROGRESSIVE") { 0 }
    end

    private def release_type
      ENV.fetch("RELEASE_TYPE") { "bugfix" }
    end 

    private def risk
      ENV.fetch("RISK") { "LOW" }
    end

    def method_missing(name)
      ENV.fetch(name.to_s.upcase) { "" }
    end
  end
end
