require "spec_helper"

describe SquashRepeater::Ruby::Configuration::Squash do
  let(:config) { SquashRepeater::Ruby::Configuration::Squash.configuration }
  let(:squash_ruby) { class_double("Squash::Ruby").as_stubbed_const(:transfer_nested_constants => true) }

  it do
    [:set_this, :MosieAlong, :f00b4r].each do |key|
      expect(squash_ruby).to receive(:configure).with({ key => key.to_s })
      expect(squash_ruby).to receive(:configuration).with(key)
      config.send("#{key.to_s}=".to_sym, key.to_s)
    end
  end

  it "when setting and getting a Squash config attr" do
    [:set_this, :MosieAlong, :f00b4r].each do |key|
      expect(squash_ruby).to receive(:configuration).with(key).and_return(key.to_s)
      #expect { config.api_key = "Set this" }.to eq "Set this"
      expect(config.send(key)).to eq key.to_s
    end
  end
end
