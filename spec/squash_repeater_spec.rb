require "spec_helper"

require "stringio"
require "logger"

describe SquashRepeater do
  let(:backburner) { class_double("Backburner").as_stubbed_const(:transfer_nested_constants => true) }
  let(:backburner_enqueue_args) { ["one", "two", :three, {four: "three"}, :five] }
  let(:capture_exception_args) { {url: "one", headers: "two", body: :three, squash_configuration: {four: "three"}, no_proxy_env: :five} }

  it do
    expect(backburner).to receive(:work)
    SquashRepeater.work
  end

  it do
    expect(backburner).to receive(:enqueue).with(SquashRepeater::ExceptionQueue, *backburner_enqueue_args)
    SquashRepeater.capture_exception(**capture_exception_args)
  end

  context "within #capture_exception" do
    let!(:logger_output) { StringIO.new }

    around do |eg|
      _logger = SquashRepeater.configuration.logger
      SquashRepeater.configuration.logger = Logger.new logger_output
      eg.run
      SquashRepeater.configuration.logger = _logger
    end

    context "the logger output" do
      it "for a handled error-type should not be empty" do
        expect(backburner).to receive(:enqueue).with(SquashRepeater::ExceptionQueue, *backburner_enqueue_args).and_raise(Beaneater::NotConnected)
        expect { SquashRepeater.capture_exception(**capture_exception_args) }.to raise_error
        expect(logger_output.string).not_to be_empty
      end

      it "for a non-handled error-type should be empty" do
        expect(backburner).to receive(:enqueue).with(SquashRepeater::ExceptionQueue, *backburner_enqueue_args).and_raise(KeyError)
        expect { SquashRepeater.capture_exception(**capture_exception_args) }.to raise_error
        expect(logger_output.string).to be_empty
      end

    end

    it do
      expect(backburner).to receive(:enqueue).with(SquashRepeater::ExceptionQueue, *backburner_enqueue_args).and_raise(Beaneater::NotConnected)
      expect { SquashRepeater.capture_exception(**capture_exception_args) }.to raise_error
    end

    #NB: This is technically a medium/large test because of the timeout:
    it "raises CaptureTimeoutError when worker doesn't return within the timeout" do
      expect(backburner).to receive(:enqueue).with(SquashRepeater::ExceptionQueue, *backburner_enqueue_args) { sleep SquashRepeater.configuration.capture_timeout + 1 }
      expect { SquashRepeater.capture_exception(**capture_exception_args) }.to raise_error(SquashRepeater::CaptureTimeoutError)
    end
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
