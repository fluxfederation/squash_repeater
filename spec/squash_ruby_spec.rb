require "spec_helper"

describe Squash::Ruby do
  let(:squash_repeater) { class_double("SquashRepeater::Ruby").as_stubbed_const(:transfer_nested_constants => true) }

  context "with ENV['no_proxy'] unset" do
    it do
      #NB: This is a crappy, env-dependent test...
      expect(ENV["no_proxy"]).to be_nil
    end
  end

  context "with ENV['no_proxy'] set" do
    around do |eg|
      env_no_proxy = ENV["no_proxy"]
      ENV["no_proxy"] = "TEST no_proxy"
      eg.run

      ENV["no_proxy"] = env_no_proxy
    end

    it do
      expect(squash_repeater).to receive(:enqueue).with("url", "headers", "body", nil, "TEST no_proxy")
      Squash::Ruby.class_eval { http_transmit("url", "headers", "body") }
    end
  end
end
