require "backburner"
require "squash/ruby"

module SquashRepeater
  module Ruby
    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield configuration if block_given?
    end

    class Configuration
      # Squash configuration is private:
      attr_accessor :squash_url, :squash_key, :squash_environment

      def initialize
        backburner do |c|
          # The nature of SquashRepeater is that a tiny local queueing system
          # captures the Squash notification, and retransmits it from a worker.
          # Therefore, we assume beanstalkd is running locally:

          c.beanstalk_url = "beanstalk://localhost"
          #c.beanstalk_url = "beanstalk://127.0.0.1"
          c.tube_namespace   = "squash-repeater"

          # NB: This relies on forking behaviour!
          c.default_worker = Backburner::Workers::Forking

          #TODO: Choose a better failure mode. Notify Munin?
          #c.on_error = lambda { |ex| Airbrake.notify(ex) }
          #TODO: Log to syslog, like our other tools?
          #c.logger = Logger.new(STDOUT)
        end
      end

      def squash_url=(value)
        @squash_url = value
        squash api_host: @squash_url
      end

      def squash_key=(value)
        @squash_key = value
        squash api_key: @squash_key
      end

      def squash_environment=(value)
        @squash_environment = value
        squash environment: @squash_environment
      end
      alias :environment :squash_environment
      alias :environment= :squash_environment=

      def queue_host=(value)
        backburner.configuration.beanstalk_url = "beanstalk://#{value}"
      end

      def queue_host
        backburner.configuration.beanstalk_url.sub(%r(^beanstalk://), "")
      end

      def queue_host=(value)
        backburner.configuration.beanstalk_url = "beanstalk://#{value}"
      end

      def namespace
        backburner.configuration.tube_namespace
      end

      def namespace=(value)
        backburner.configuration.tube_namespace = value
      end

      private

      def backburner(&p)
        if block_given?
          Backburner.configure(&p)
        else
          Backburner.configuration
        end
      end

      def squash(*args)
        Squash::Ruby.configure(*args)
      end
    end
  end
end

# Set the defaults:
SquashRepeater::Ruby.configure
