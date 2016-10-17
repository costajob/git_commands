require "spec_helper"

def `(command); command; end

describe GitCommands::Command do
  let(:klass) { GitCommands::Command }
  let(:repo) { Dir.mktmpdir("greatest_hits") }
  let(:out) { StringIO.new }
  let(:branches) { %w[feature/love-me-tender feature/all-shock-up feature/dont-be-cruel] }
  let(:branches_file) { Tempfile.new("branches") << branches.join("\n") }

  before do
    branches_file.rewind
    def klass.check_connection; true; end
    def klass.git_repo?(repo); true; end
    def klass.valid_branch?(branch); true; end
  end

  after { def klass.valid_branch?(branch); true; end }

  it "must raise an error if repo does not exist" do
    Proc.new { klass.new(repo: "noent", branches: "feature/love-me-tender") }.must_raise GitCommands::Command::NoentRepositoryError
  end

  it "must raise an error for invalid GIT repo" do
    def klass.git_repo?(repo); false; end
    Proc.new { klass.new(repo: repo, branches: "feature/love-me-tender") }.must_raise GitCommands::Command::NoentRepositoryError
  end

  it "must raise an error when master is included into branches list" do
    Proc.new { klass.new(repo: repo, branches: "master,feature/in_the_ghetto", out: out) }.must_raise klass::GitError
  end

  it "must raise an error if branch is invalid" do
    def klass.valid_branch?(branch); false; end
    Proc.new { klass.new(repo: repo, branches: branches.join(","), out: out) }.must_raise klass::GitError
  end

  it "must fetch branches from file" do
    instance = klass.new(repo: repo, branches: branches_file.path, out: out)
    instance.instance_variable_get(:@branches).must_equal branches
  end

  describe "git commands" do
    let(:instance) { klass.new(repo: repo, branches: branches.join(","), out: out) }
    before { def instance.input; "Y"; end }

    it "must remove local and remote branches" do
      instance.purge.must_equal branches
    end

    it "must rebase with master" do
      instance.rebase.must_equal branches
    end

    it "must raise an error for unfinished rebase" do
      def instance.unfinished_rebase?; true; end
      Proc.new { instance.rebase }.must_raise klass::GitError
    end

    it "must aggregate branches into a single one" do
      instance.aggregate.must_equal true
    end
  end
end
