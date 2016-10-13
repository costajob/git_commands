require "spec_helper"

describe GitCommands::Prompt do
  let(:klass) { Mocks::Prompt }
  let(:instance) { klass::new }

  it "must print a warning" do
    instance.warning("should print the warning")
    instance.out.string.must_equal "\n\e[37m****************************\e[0m\n* \e[33mshould print the warning\e[0m *\n\e[37m****************************\e[0m\n\n"
  end

  it "must print success message" do
    instance.success("i win!")
    instance.out.string.must_equal "\e[32mi win!\e[0m\n"
  end

  %w[y Y].each do |answer|
    it "must confirm question" do
      stub(instance).input { answer }
      assert instance.confirm("Are you sure") { true }
    end
  end

  %w[n N].each do |answer|
    it "must abort" do
      stub(instance).input { answer }
      Proc::new { instance.confirm("Are you sure") }.must_raise klass::AbortError
    end
  end
end
