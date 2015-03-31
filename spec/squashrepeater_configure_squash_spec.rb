require "spec_helper"

describe SquashRepeater::Ruby::Configuration::Squash do
  let(:config) { SquashRepeater::Ruby::Configuration::Squash.configuration }
  let(:squash_ruby) { class_double("Squash::Ruby").as_stubbed_const(:transfer_nested_constants => true) }

  it do
    expect(squash_ruby).to receive(:configure).with({ :set_this => "Set this" })
    expect(squash_ruby).to receive(:configuration).with(:set_this)
    config.set_this = "Set this"
  end

  it do
    expect(squash_ruby).to receive(:configure).with({ :set_this => "Set this" })
    expect(squash_ruby).to receive(:configuration).with(:set_this)
    config.set_this = "Set this"
    expect(config.set_this).to equal "Set this"
  end
end
