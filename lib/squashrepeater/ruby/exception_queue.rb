require "backburner"

module SquashRepeater
  module Ruby
    class << self
      def transmit_exceptions
        Backburner.work
      end
      alias :work :transmit_exceptions

      def capture_exception(*args)
        Backburner.enqueue(ExceptionQueue, *args)
      end

      alias :enqueue :capture_exception
    end

    #TODO: Choose a better name
    class ExceptionQueue
      include Backburner::Queue
      queue "exception"

      # Process one captured Squash notification;  i.e. forward it to the Squash
      # server
      def self.perform(url, headers, body, squash_configuration, no_proxy_env=nil)
        #TODO: Change how Squash client deals with failures.
        #    Normally it logs to a special log file, whereas what we really want
        #    is for the job(s) to go back on the queue to be retried.

        #NB: :timeout_protection is a Proc object:
        squash_configuration = squash_configuration.dup

        #NB: The JSON conversion turns symbol-keys --> strings
        #NB: Squash::Ruby.configure turns string-keys --> symbols
        squash_configuration.delete("timeout_protection")

        #NB: This relies on forking behaviour!
        # We do this, because the queue may be shared, therefore the config may have been different from
        # each client.
        Squash::Ruby.configure(squash_configuration)
        ENV['no_proxy'] = no_proxy_env

        # Transmit it to the Squash server:
        Squash::Ruby.http_transmit__original(url, headers, body)
      end
    end
  end
end
