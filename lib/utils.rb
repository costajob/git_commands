class String
  @@color_codes = {
    :red => 31,
    :green => 32,
    :yellow => 33,
    :blue => 34,
    :magenta => 35,
    :cyan => 36,
    :grey => 37
  }

  def bold
    "\e[1m#{self}"
  end
  
  def normal
    "\e[0m#{self}"
  end
  
  def method_missing(method, *args, &block)
    if @@color_codes.keys.include?(method)
      "\e[#{@@color_codes[method]}m#{self}\e[0m"
    else
      super
    end
  end
end

module Utils
  @@astrerisk_len = 90
  
  def print_spacer(s)
    puts
    puts ('*' * @@astrerisk_len).grey.bold
    puts s.green
  end
  
  def ask message
    print message.bold.grey
    STDIN.gets.chomp
  end
  
  def confirm(msg, &b)
    begin
      res = ask "#{msg} (Y/N)?"
    end until %w(Y N y n).include?(res)
    if res =~ /y/i
      b.call
    elsif res =~ /n/i
      puts 'Aborting...'.red.bold
    end
  end
end
