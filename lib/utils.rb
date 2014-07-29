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
  
  def method_missing(id, *args, &block)
    if @@color_codes.keys.include?(id)
      "\e[#{@@color_codes[id]}m#{self}\e[0m"
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
  
  def choose(options, &b)
    msg = options.fetch(:msg)
    choices = options.fetch(:choices)
    multi = options.fetch(:multi, true)
    multi_label = multi ? ' - use '.magenta + '+'.bold + ' to separate choices, '.magenta + '*'.bold + ' for all - '.magenta : ' '
    if choices.is_a?(Hash)
      choiches = choices.keys.map(&:to_s)
      labels = choices.map { |k,v| "#{v} [" + "#{k}".bold.yellow + "]".normal }
    else
      labels = choices.map { |choice| choice.to_s.bold.yellow }
    end
    begin
      res = ask "#{msg}".bold + multi_label + "(#{labels.join(' - ')})?".normal
      responses = multi ? (res == '*' ? choiches : res.split('+').map(&:strip)) : res
    end until responses.all? { |response| choiches.include?(response) }
    responses.each do |r|
      b.call(r)
    end
  end
end
