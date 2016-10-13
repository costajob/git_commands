require "spec_helper"

def `(command); command; end

describe GitCommands::Command do
  let(:klass) { GitCommands::Command }
  let(:repo) { Tempfile.new("greatest_hits") }
  let(:out) { StringIO.new }
  let(:instance) { klass.new(repo: repo.path, branches: branches.join(","), out: out) }
  let(:branches) { %w[feature/love-me-tender feature/all-shock-up feature/dont-be-cruel] }
  let(:branches_file) { Tempfile.new("branches") << branches.join("\n") }

  before do
    branches_file.rewind
    stub(klass).check_connection { true }
  end

  it "must raise an error if no valid repo is specified" do
    Proc.new { klass.new(repo: "noent", branches: "feature/love-me-tender") }.must_raise GitCommands::Command::NoentRepositoryError
  end

  it "must return single element array when branch is defined" do
    instance.instance_variable_get(:@branches).must_equal branches
  end

  it "must fetch branches from file" do
    instance = klass.new(repo: repo.path, branches: branches_file.path, out: out)
    instance.instance_variable_get(:@branches).must_equal branches
  end

  describe "git commands" do
    let(:repo) { File.expand_path("../../spec", __FILE__) }
    let(:instance) { klass.new(repo: repo, branches: branches.join(","), out: out) }
    before { stub(instance).input { "Y" } }

    it "must remove local and remote branches" do
      instance.purge.must_equal branches
    end

    it "must raise an error when trying to remove master" do
      instance = klass.new(repo: repo, branches: "master", out: out)
      Proc.new { instance.purge }.must_raise klass::GitError
    end

    it "must rebase with master" do
      instance.rebase.must_equal branches
    end

    it "must raise an error for unfinished rebase" do
      stub(instance).unfinished_rebase? { true }
      Proc.new { instance.rebase }.must_raise klass::GitError
    end

    it "must aggregate branches into a single one" do
      refute instance.aggregate
    end
  end
end
