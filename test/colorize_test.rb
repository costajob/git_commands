require 'test_helper'
require_relative '../lib/colorize'

using GitUtils::Colorize

describe GitUtils::Colorize do
  let(:klass) { GitUtils::Colorize }
  let(:instance) { 'oh my' }

  it 'must respond to bold' do
    instance.bold.must_be_instance_of String
  end

  it 'must respond to normal' do
    instance.normal.must_be_instance_of String
  end

  it 'must respond to dynamic methods' do
    refute puts "should be red: " << instance.red
    refute puts "should be green: " << instance.green
    refute puts "should be yellow: " << instance.yellow
    refute puts "should be blue: " << instance.blue
    refute puts "should be magenta: " << instance.magenta
    refute puts "should be cyan: " << instance.cyan
    refute puts "should be grey: " << instance.grey
  end
end
