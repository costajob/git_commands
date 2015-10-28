module GitUtils
  module Colorize
    CODES = {
      red: 31,
      green: 32,
      yellow: 33,
      blue: 34,
      magenta: 35,
      cyan: 36,
      grey: 37
    }

    refine String do
      CODES.each do |message, code|
        define_method(message) do
          "\e[#{code}m#{self}\e[0m"
        end
      end
    end
  end
end
