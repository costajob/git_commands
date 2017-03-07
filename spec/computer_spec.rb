require "spec_helper"

describe GitCommands::Computer do
  let(:klass) { GitCommands::Computer }
  let(:out) { StringIO.new }
  let(:path) { Dir.mktmpdir("greatest_hits") }
  let(:branches) { "feature/love-me-tender, feature/all-shock-up, feature/dont-be-cruel" }
  let(:instance) { klass.new(repo: path, branches: branches, repo_klass: Mocks::Repository, branch_klass: Mocks::Branch, out: out) }
  before { def instance.input; "Y"; end }

  it "must remove branches" do
    instance.remove
    instance.out.string.must_equal "\e[32m\nSuccessfully loaded 3 branches:\e[0m\n01. feature/love-me-tender\n02. feature/all-shock-up\n03. feature/dont-be-cruel\n\n\e[36mProceed removing these branches (Y/N)?\e[0m\e[33m\nRemoving branch: feature/love-me-tender\e[0m\n\e[33m\nRemoving branch: feature/all-shock-up\e[0m\n\e[33m\nRemoving branch: feature/dont-be-cruel\e[0m\n"
  end

  it "must rebase with master" do
    instance.rebase
    instance.out.string.must_equal "\e[32m\nSuccessfully loaded 3 branches:\e[0m\n01. feature/love-me-tender\n02. feature/all-shock-up\n03. feature/dont-be-cruel\n\n\e[36mProceed rebasing these branches with: origin/master (Y/N)?\e[0m\e[33m\nRebasing branch: feature/love-me-tender\e[0m\n\e[32m\nRebased successfully!\e[0m\n\e[33m\nRebasing branch: feature/all-shock-up\e[0m\n\e[32m\nRebased successfully!\e[0m\n\e[33m\nRebasing branch: feature/dont-be-cruel\e[0m\n\e[32m\nRebased successfully!\e[0m\n"
  end

  it "must aggregate branches into a single one" do
    aggregator = Mocks::Aggregator.new
    instance.aggregate(aggregator)
    instance.out.string.must_equal "\e[32m\nSuccessfully loaded 3 branches:\e[0m\n01. feature/love-me-tender\n02. feature/all-shock-up\n03. feature/dont-be-cruel\n\n\e[36mAggregate branches into aggregate/2017-02-01 (Y/N)?\e[0m\e[33m\nMerging branch: feature/love-me-tender\e[0m\n\e[33m\nMerging branch: feature/all-shock-up\e[0m\n\e[33m\nMerging branch: feature/dont-be-cruel\e[0m\n\e[32m\naggregate/2017-02-01 branch created\e[0m\n"
  end

  it "must rebase with specific default" do
    instance.instance_variable_set(:@origin, "upstream")
    instance.instance_variable_set(:@default, "production")
    instance.rebase
    instance.out.string.must_equal "\e[32m\nSuccessfully loaded 3 branches:\e[0m\n01. feature/love-me-tender\n02. feature/all-shock-up\n03. feature/dont-be-cruel\n\n\e[36mProceed rebasing these branches with: upstream/production (Y/N)?\e[0m\e[33m\nRebasing branch: feature/love-me-tender\e[0m\n\e[32m\nRebased successfully!\e[0m\n\e[33m\nRebasing branch: feature/all-shock-up\e[0m\n\e[32m\nRebased successfully!\e[0m\n\e[33m\nRebasing branch: feature/dont-be-cruel\e[0m\n\e[32m\nRebased successfully!\e[0m\n"
  end
end
