require "spec_helper"

describe GitCommands::Branch do
  let(:klass) { GitCommands::Branch }
  let(:instance) { klass.new("feature/love_me_tender") }

  it "must check valid branch" do
    instance.valid?.must_equal true
  end

  it "must detect not existent branch" do
    def instance.exists?; false; end
    instance.valid?.must_equal false
  end

  it "must detect master branch" do
    klass.new("master").valid?.must_equal false
  end

  describe "Factories" do
    let(:names) { %w[feature/love-me-tender feature/all-shock-up feature/dont-be-cruel] }
    let(:names_file) { Tempfile.new("branches") << names.join("\n") }
    before { names_file.rewind }

    it "must return an empty array for nil value" do
      klass.by_names(nil).must_be_empty
    end 

    it "must parse the names list properly" do
      klass.by_names(names.join(", ")).must_equal names.map { |name| klass.new(name) }
    end

    it "must return an empty array if file does not exist" do
      klass.by_file("noent").must_be_empty
    end

    it "must parse the names file properly" do
      klass.by_file(names_file.path).must_equal names.map { |name| klass.new(name) }
    end

    it "must fetch the names by pattern" do
      klass.by_pattern("feature*").must_equal names.map { |name| klass.new(name) }
    end

    it "must return an empty array" do
      klass.factory(nil).must_be_empty
    end

    it "must factory by file" do
      klass.factory(names_file.path).must_equal names.map { |name| klass.new(name) }
    end

    it "must factory by names" do
      klass.factory(names.join(", ")).must_equal names.map { |name| klass.new(name) }
    end

    it "must factory by pattern" do
      klass.factory("feature*").must_equal names.map { |name| klass.new(name) }
    end
  end
end
