require "backburner"
require "squash/ruby"

module SquashRepeater::Ruby
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new  # Initialise
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

        #TODO: Choose a better failure mode:
        #c.on_error = lambda { |ex| Airbrake.notify(ex) }

        c.logger = Logger.new(STDOUT)
      end
    end

    def squash_url
      squash.api_host
    end

    def squash_url=(value)
      squash.api_host = value
    end

    def squash_key
      squash.api_key
    end

    def squash_key=(value)
      squash.api_key = value
    end

    def squash_environment=(value)
      squash.environment = value
    end

    def squash_environment=(value)
      squash.environment = value
    end
    alias :environment :squash_environment
    alias :environment= :squash_environment=

    def squash_disabled
      squash.disabled
    end

    def squash_disabled=(value)
      squash.disabled = value
    end
    alias :disabled :squash_disabled
    alias :disabled= :squash_disabled=

    def queue_host=(value)
      backburner.beanstalk_url = "beanstalk://#{value}"
    end

    def queue_host
      backburner.beanstalk_url.sub(%r(^beanstalk://), "")
    end

    def queue_host=(value)
      backburner.beanstalk_url = "beanstalk://#{value}"
    end

    def namespace
      backburner.tube_namespace
    end

    def namespace=(value)
      backburner.tube_namespace = value
    end

    def logger
      backburner.logger
    end

    def logger=(value)
      # Squash doesn't allow you to use a different logger
      backburner.logger = value
    end

    private

    def backburner(&p)
      if block_given?
        Backburner.configure(&p)
      else
        Backburner.configuration
      end
    end

    def squash(&p)
      if block_given?
        SquashRepeater::Ruby::Configuration::Squash.configure(&p)
      else
        SquashRepeater::Ruby::Configuration::Squash.configuration
      end
      #Squash::Ruby.configure(*args)
    end
  end
end

require "squashrepeater/ruby/configure/squash"

# Set the defaults:
SquashRepeater::Ruby.configure
