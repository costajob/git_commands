require 'test_helper'
require_relative '../lib/command'

def `(command); command; end

describe GitUtils::Command do
  let(:klass) { GitUtils::Command }
  let(:repo) { 'elvis-greatest-hits' }
  let(:instance) { klass::new(repo: repo) }
  let(:branch) { 'feature/blue-suede-shoes' }
  let(:branches) { %w[feature/love-me-tender feature/all-shock-up feature/dont-be-cruel] }
  let(:branches_file) { Tempfile.new('branches') << branches.join("\n") }
  before { branches_file.rewind }

  it 'must define state' do
    %w[base_dir branches_file branch repo].each do |attr|
      assert instance.instance_variable_defined?(:"@#{attr}")
    end
  end

  it 'must return single element array when branch is defined' do
    instance = klass::new(repo: repo, branch: branch)
    instance.branches
    instance.instance_variable_get(:@branches).must_equal [branch]
  end

  it 'must fetch branches from file' do
    instance = klass::new(repo: repo, branches_file: branches_file.path)
    instance.branches
    instance.instance_variable_get(:@branches).must_equal branches
  end

  describe 'git commands' do
    let(:pwd) { File.expand_path('../..', __FILE__) }
    let(:instance) { klass::new(repo: 'test', base_dir: pwd, branch: branch) }
    before { stub(instance).input { 'Y' } }

    it 'must remove local and remote branches' do
      instance.purge.must_equal [branch]
    end

    it 'must raise an error when trying to remove master' do
      instance = klass::new(repo: 'test', base_dir: pwd, branch: 'master')
      -> { instance.purge }.must_raise klass::GitError
    end

    it 'must rebase with master' do
      instance.rebase.must_equal [branch]
    end

    it 'must raise an error for unfinished rebase' do
      stub(instance).unfinished_rebase? { true }
      -> { instance.rebase }.must_raise klass::GitError
    end

    it 'must aggregate branches into a single one' do
      instance = klass::new(repo: 'test', base_dir: pwd, branches_file: branches_file.path)
      refute instance.aggregate
    end
  end
end
