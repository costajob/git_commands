require 'test_helper'
require_relative '../lib/prompt'

describe GitUtils::Prompt do
  let(:klass) { class Mock; include GitUtils::Prompt; end }
  let(:instance) { klass::new }

  it 'must print a warning' do
    refute instance.warning(message: "should print the warning")
  end

  it 'must print success message' do
    refute instance.success('i win!')
  end

  it 'must respond to ask ' do
    res = 'blue suede shoes'
    stub(instance).input { res }
    instance.ask('What is your Elvis favorite song?').must_equal res
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
      -> { instance.confirm('Are you sure') }.must_raise klass::AbortError
    end
  end
end
