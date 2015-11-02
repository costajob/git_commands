require_relative 'colorize'

module GitUtils
  using Colorize
  module Prompt
    VALID_ANSWERS = %w[Y y N n]

    class AbortError < StandardError; end

    def warning(message:, char: '*')
      spacer = (char * (message.size + 4)).grey
      puts "\n", spacer, "#{char} #{message.to_s.yellow} #{char}", spacer, "\n"
    end

    def error(message:, error: StandardError)
      puts message.to_s.red
      yield if block_given?
      fail error, message
    end

    def success(message)
      puts message.to_s.green
    end

    def confirm(message)
      res = begin
        ask "#{message} (Y/N)?"
      end until VALID_ANSWERS.include?(res)
      case res
      when /y/i
        yield
      else
        error(message: 'Aborted operation!', error: AbortError)
      end
    end

    private 
    
    def ask(message)
      print message.cyan
      input
    end

    def input
      STDIN.gets.chomp
    end
  end
end
