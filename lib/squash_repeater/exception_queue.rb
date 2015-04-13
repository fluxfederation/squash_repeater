require "time"
require "timeout"
require "backburner"

module SquashRepeater
  class CaptureTimeoutError < SquashRepeater::Error
    def to_s
      original_message = super
      "Capturing the exception timed-out#{" (#{original_message})" if original_message && !original_message.empty?}"
    end
  end

  class << self
    def transmit_exceptions
      Backburner.work
    end
    alias :work :transmit_exceptions

    # Capture the HTTP data, and store it in the beanstalkd queue for later
    def capture_exception(url: nil, headers: nil, body: nil, squash_configuration: nil, no_proxy_env: nil)
      #FUTURE: Required keyword args, for Ruby 2.1+
      #def capture_exception(url:, headers:, body:, squash_configuration:, no_proxy_env: nil)
      fail "Missing required keyword arg" unless url && headers && body && squash_configuration

      # If things fail, it's useful to know how long it caused the exception-capture to block the
      # calling process:
      start = Time.now

      begin
        Timeout::timeout(configuration.capture_timeout, CaptureTimeoutError) do
          #NB: Backburner doesn't seem able to #perform with keyword args:
          Backburner.enqueue(ExceptionQueue, url, headers, body, squash_configuration, no_proxy_env)
        end

      rescue CaptureTimeoutError, Beaneater::NotConnected, Beaneater::InvalidTubeName, Beaneater::JobNotReserved, Beaneater::UnexpectedResponse => e
        failsafe_handler(
          e, message: "whilst trying to connect to Beanstalk", time_start: start,
          args: {
            url: url,
            headers: headers,
            body: body,
            squash_configuration: squash_configuration,
            no_proxy_env: no_proxy_env
          }
        )
        raise
      end
    end
    alias :enqueue :capture_exception

    def failsafe_handler(exception, message: nil, time_start: nil, args: {})
      configuration.logger.error "Failed: #{exception}" + (message && !message.empty? ? ", #{message}." : ".")
      configuration.logger.error "      : #{exception.inspect}"

      configuration.logger.error "  (Took #{Time.now - time_start}s to fail)" if time_start
      configuration.logger.error ["*****","  original_args = #{args.inspect}", "*****"].join("\n")
    end
  end

  class ExceptionQueue
    include Backburner::Queue
    queue "exception"

    # Process one captured Squash notification;  i.e. forward it to the Squash
    # server
    def self.perform(url, headers, body, squash_configuration, no_proxy_env=nil)
      #TODO: Change how Squash client deals with failures.
      #    Normally it logs to a special log file, whereas what we really want
      #    is for the job(s) to go back on the queue to be retried.

      # If things fail, it's useful to know how long it caused the exception-capture to block the
      # calling process:
      start = Time.now

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

      begin
        # Transmit it to the Squash server:
        Squash::Ruby.http_transmit__original(url, headers, body)

      rescue SocketError => e
        SquashRepeater.failsafe_handler(e, message: "whilst trying to connect to Squash", time_start: start)
        raise
      end
    end
  end
end
