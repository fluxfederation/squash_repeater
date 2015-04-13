require "spec_helper"

describe SquashRepeater do
  let(:backburner) { class_double("Backburner").as_stubbed_const(:transfer_nested_constants => true) }

  it do
    expect(backburner).to receive(:work)
    SquashRepeater.work
  end

  it do
    expect(backburner).to receive(:enqueue).with(SquashRepeater::ExceptionQueue, "one", "two", :three, {four: "three"}, :five)
    SquashRepeater.capture_exception(url: "one", headers: "two", body: :three, squash_configuration: {four: "three"}, no_proxy_env: :five)
  end
end

describe SquashRepeater::ExceptionQueue do
  let(:squash_ruby) { class_double("Squash::Ruby").as_stubbed_const(:transfer_nested_constants => true) }

  it do
    expect(squash_ruby).to receive(:configure).with(
      config1: "config1", config2: "config2")
    expect(squash_ruby).to receive(:http_transmit__original).with(
      "url", "headers", "body"
    )

    SquashRepeater::ExceptionQueue.perform(
      "url", "headers", "body", { config1: "config1", config2: "config2" }
    )
  end

  it "configuration dup removes 'timeout_protection'" do
    expect(squash_ruby).to receive(:configure).with(
      config1: "config1", config2: "config2")
    expect(squash_ruby).to receive(:http_transmit__original)

    SquashRepeater::ExceptionQueue.perform(
      "url", "headers", "body",
      { config1: "config1", config2: "config2",
       "timeout_protection" => "should not be here" }
    )
  end
end
