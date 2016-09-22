require 'spec_helper'
require 'git_commands/prompt'

describe GitCommands::Prompt do
  let(:klass) { class Mock; include GitCommands::Prompt; end }
  let(:instance) { klass::new }

  it 'must print a warning' do
    refute instance.warning(:message => "should print the warning")
  end

  it 'must print success message' do
    refute instance.success('i win!')
  end

  %w[y Y].each do |answer|
    it 'must confirm question' do
      stub(instance).input { answer }
      assert instance.confirm('Are you sure') { true }
    end
  end

  %w[n N].each do |answer|
    it 'must abort' do
      stub(instance).input { answer }
      Proc::new { instance.confirm('Are you sure') }.must_raise klass::AbortError
    end
  end
end
