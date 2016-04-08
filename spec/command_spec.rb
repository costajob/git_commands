require 'spec_helper'
require 'git_utils/command'

def `(command); command; end

describe GitUtils::Command do
  let(:klass) { GitUtils::Command }
  let(:repo) { 'elvis-greatest-hits' }
  let(:instance) { klass::new(repo: repo, branches: branches.join(',')) }
  let(:branches) { %w[feature/love-me-tender feature/all-shock-up feature/dont-be-cruel] }
  let(:branches_file) { Tempfile.new('branches') << branches.join("\n") }
  before do
    branches_file.rewind
    stub(klass).check_connection { true }
  end

  it 'must define state' do
    %w[base_dir branches_file branches repo].each do |attr|
      assert instance.instance_variable_defined?(:"@#{attr}")
    end
  end

  it 'must raise an error if no valid repo is specified' do
    -> { klass::new(repo: nil) }.must_raise ArgumentError
  end

  it 'must raise an error if no branches are fetched' do
    -> { klass::new(repo: repo) }.must_raise klass::NoBranchesError
  end

  it 'must return single element array when branch is defined' do
    instance.instance_variable_get(:@branches).must_equal branches
  end

  it 'must fetch branches from file' do
    instance = klass::new(repo: repo, branches_file: branches_file.path)
    instance.instance_variable_get(:@branches).must_equal branches
  end

  it 'must fetch branches from argument only' do
    branches = %w[feature/return-to-sender feature/teddy-bear]
    instance = klass::new(repo: repo, branches: branches.join(","), branches_file: branches_file.path)
    instance.instance_variable_get(:@branches).must_equal branches
  end

  describe 'git commands' do
    let(:pwd) { File.expand_path('../..', __FILE__) }
    let(:instance) { klass::new(repo: 'spec', base_dir: pwd, branches: branches.join(',')) }
    before { stub(instance).input { 'Y' } }

    it 'must remove local and remote branches' do
      instance.purge.must_equal branches
    end

    it 'must raise an error when trying to remove master' do
      instance = klass::new(repo: 'spec', base_dir: pwd, branches: 'master')
      -> { instance.purge }.must_raise klass::GitError
    end

    it 'must rebase with master' do
      instance.rebase.must_equal branches
    end

    it 'must raise an error for unfinished rebase' do
      stub(instance).unfinished_rebase? { true }
      -> { instance.rebase }.must_raise klass::GitError
    end

    it 'must aggregate branches into a single one' do
      refute instance.aggregate
    end
  end
end
