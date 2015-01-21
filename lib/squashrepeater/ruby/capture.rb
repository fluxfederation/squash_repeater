require "backburner"

# The nature of SquashRepeater is that a tiny local queueing system captures
# the Squash notification, and retransmits it from a worker.  Therefore, we
# assume beanstalkd is running locally:
Backburner.configure do |config|
  config.beanstalk_url    = ["beanstalk://127.0.0.1"]
  config.tube_namespace   = "squash-repeater"

  # NB: This relies on forking behaviour!
  config.default_worker = Backburner::Workers::Forking

  #TODO: Choose a better failure mode. Notify Munin?
  #config.on_error = lambda { |ex| Airbrake.notify(ex) }
  #TODO: Log to syslog, like our other tools?
  #config.logger = Logger.new(STDOUT)
end

module SquashRepeater
  module Ruby
    def self.work
      Backburner.work
    end

    def self.enqueue(*args)
      Backburner.enqueue(Capture, *args)
    end

    class Capture
      include Backburner::Queue
      queue "exception"

      # Process one captured Squash notification;  i.e. forward it to the Squash
      # server
      def self.perform(url, headers, body, squash_configuration, no_proxy_env=nil)
        #NB: :timeout_protection is a Proc object:
        squash_configuration = squash_configuration.dup

        #NB: The JSON conversion turns symbol-keys --> strings
        #NB: Squash::Ruby.configure turns string-keys --> symbols
        squash_configuration.delete("timeout_protection")

        #NB: This relies on forking behaviour!
        Squash::Ruby.configure(squash_configuration)
        ENV['no_proxy'] = no_proxy_env

        # Transmit it to the Squash server:
        Squash::Ruby.http_transmit__original(url, headers, body)
      end
    end
  end
end
