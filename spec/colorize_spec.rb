require "spec_helper"

using GitCommands::Colorize

describe GitCommands::Colorize do
  let(:instance) { "colorize me!" }
  let(:out) { StringIO.new }

  it "must colorize red" do
    out.puts "must be red: " << instance.red
    out.string.must_equal "must be red: \e[31mcolorize me!\e[0m\n"
  end

  it "must colorize green" do
    out.puts "must be green: " << instance.green
    out.string.must_equal "must be green: \e[32mcolorize me!\e[0m\n"
  end

  it "must colorize yellow" do
    out.puts "must be yellow: " << instance.yellow
    out.string.must_equal "must be yellow: \e[33mcolorize me!\e[0m\n"
  end

  it "must colorize blue" do
    out.puts "must be blue: " << instance.blue
    out.string.must_equal "must be blue: \e[34mcolorize me!\e[0m\n"
  end

  it "must colorize magenta" do
    out.puts "must be magenta: " << instance.magenta
    out.string.must_equal "must be magenta: \e[35mcolorize me!\e[0m\n"
  end

  it "must colorize cyan" do
    out.puts "must be cyan: " << instance.cyan
    out.string.must_equal "must be cyan: \e[36mcolorize me!\e[0m\n"
  end

  it "must colorize grey" do
    out.puts "must be grey: " << instance.grey
    out.string.must_equal "must be grey: \e[37mcolorize me!\e[0m\n"
  end
end
