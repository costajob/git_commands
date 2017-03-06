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

  it "must call internal methods for default pattern" do
    instance = klass.new
    instance.call.must_equal("release/rc-0.bugfix_LOW_20170306")
  end

  it "must call method missing for custom pattern" do
    instance = klass.new(pattern: "release/rc-<unknown><timestamp>")
    instance.call.must_equal "release/rc-20170306"
  end
end
