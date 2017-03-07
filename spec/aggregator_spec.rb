require "spec_helper"

describe GitCommands::Aggregator do
  let(:klass) { GitCommands::Aggregator }

  it "must raise an error for invalid pattern" do
    -> { klass.new(pattern: "release/wrong-pattern") }.must_raise klass::InvalidPatternError
  end

  it "must return name if present" do
    name = "release/rc-1.bugfix_LOW_20170201"
    instance = klass.new(name: name)
    instance.call.must_equal name
  end

  it "must return simple name for simple pattern" do
    instance = klass.new(pattern: "release/<timestamp>")
    instance.call.must_equal("release/#{instance.timestamp}")
  end

  it "must replace with env variables for custom pattern" do
    ENV["RELEASE_TYPE"] = "bugfix"
    ENV["RISK"] = "LOW"
    ENV["PROGRESSIVE"] = "3"
    instance = klass.new(pattern: "release/rc-<progressive>.<release_type>_<risk>_<timestamp>")
    instance.call.must_equal "release/rc-3.bugfix_LOW_#{instance.timestamp}"
  end

  it "must fallback to empty string for missing env variables" do
    instance = klass.new(pattern: "aggregate/rc-<unknown><timestamp>")
    instance.call.must_equal "aggregate/rc-#{instance.timestamp}"
  end
end
