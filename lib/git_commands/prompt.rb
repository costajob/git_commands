require "git_commands/colorize"

module GitCommands
  using Colorize
  module Prompt
    VALID_ANSWERS = %w[Y y N n]

    class AbortError < StandardError; end

    def out
      @out ||= STDOUT
    end

    def warning(message)
      out.puts "\n#{message}".yellow
    end

    def success(message)
      out.puts "\n#{message}".green
      true
    end

    def confirm(message)
      res = begin
        ask "#{message} (Y/N)?"
      end until VALID_ANSWERS.include?(res)
      case res
      when /y/i
        yield
      else
        fail(AbortError, "Aborted operation!")
      end
    end

    def error(message)
      out.puts message.to_s.red
    end

    private def ask(message)
      out.print message.cyan
      input
    end

    private def input
      STDIN.gets.chomp
    end
  end
end
