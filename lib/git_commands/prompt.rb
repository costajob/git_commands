require "git_commands/colorize"

module GitCommands
  using Colorize
  module Prompt
    VALID_ANSWERS = %w[Y y N n]

    def out
      @out ||= STDOUT
    end

    def warning(message, char = "*")
      spacer = (char * (message.size + 4)).grey
      out.puts "\n", spacer, "#{char} #{message.to_s.yellow} #{char}", spacer, "\n"
    end

    def error(message, error = StandardError)
      out.puts message.to_s.red
      yield if block_given?
      fail error, message
    end

    def success(message)
      out.puts message.to_s.green
    end

    def confirm(message)
      res = begin
        ask "#{message} (Y/N)?"
      end until VALID_ANSWERS.include?(res)
      case res
      when /y/i
        yield
      else
        abort!("Aborted operation!")
      end
    end

    private 
    
    def ask(message)
      out.print message.cyan
      input
    end

    def abort!(message)
      out.puts message.to_s.red
      exit
    end

    def input
      STDIN.gets.chomp
    end
  end
end
