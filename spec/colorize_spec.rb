require 'spec_helper'
require 'git_utils/colorize'

describe GitUtils::Colorize do
  let(:klass) { GitUtils::Colorize }
  let(:instance) { 'colorize me!' }

  it 'must respond to dynamic methods' do
    refute puts 'must be red: ' << instance.red
    refute puts 'must be green: ' << instance.green
    refute puts 'must be yellow: ' << instance.yellow
    refute puts 'must be blue: ' << instance.blue
    refute puts 'must be magenta: ' << instance.magenta
    refute puts 'must be cyan: ' << instance.cyan
    refute puts 'must be grey: ' << instance.grey
  end
end
