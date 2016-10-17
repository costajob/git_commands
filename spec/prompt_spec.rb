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

  it "must confirm question" do
    def instance.input; "y"; end
    assert instance.confirm("Are you sure") { true }
  end

  it "must abort" do
    def instance.input; "n"; end
    begin
      instance.confirm("Are you sure")
    rescue SystemExit
      instance.out.string.must_equal "\e[36mAre you sure (Y/N)?\e[0m\e[31mAborted operation!\e[0m\n"
    end
  end
end
