require "spec_helper"

describe GitCommands::Repository do
  let(:path) { Dir.mktmpdir("greatest_hits") }
  let(:klass) { GitCommands::Repository }
  let(:instance) { klass.new(path) }

  it "must detect invalid path" do
    -> { klass.new(nil) }.must_raise klass::PathError
  end

  it "must detect non existent path" do
    -> { klass.new("/var/greatest_hits") }.must_raise klass::InvalidError
  end

  it "must detect unlocked state" do
    instance.locked?.must_equal false
  end

  it "must detect locked state" do
    FileUtils.mkdir_p(File.join(path, ".git", "rebase-merge"))
    instance.locked?.must_equal true
  end
end
