module GitCommands
  module Colorize
    CODES = {
      :red => 31,
      :green => 32,
      :yellow => 33,
      :blue => 34,
      :magenta => 35,
      :cyan => 36,
      :grey => 37
    }

  end
end

String.instance_eval do
  GitCommands::Colorize::CODES.each do |message, code|
    define_method(message) do
      "\e[#{code}m#{self}\e[0m"
    end
  end
end
