require "backburner"
require "squash/ruby"

module SquashRepeater
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new  # Initialise
    yield configuration if block_given?
  end

  class Configuration
    attr_reader :logger
    attr_accessor :capture_timeout

    def initialize
      #NB: You definitely want to think about changing this to something more "substantial"; beanstalkd goes down, you'll lose data.
      self.logger = Logger.new(STDERR)
      self.capture_timeout = 2  # seconds

      backburner do |c|
        # The nature of SquashRepeater is that a tiny local queueing system
        # captures the Squash notification, and retransmits it from a worker.
        # Therefore, we assume beanstalkd is running locally:
        c.beanstalk_url = "beanstalk://localhost"
        #c.beanstalk_url = "beanstalk://127.0.0.1"
        c.tube_namespace   = "squash-repeater"

        c.max_job_retries = 10 # retry jobs 10 times
        c.retry_delay = 30 # wait 30 seconds in between retries

        # NB: This relies on forking behaviour!
        # NB: Both ::Simple and ::Forking seem to have a bug in them (https://github.com/nesquena/backburner/issues/93)
        c.default_worker = Backburner::Workers::ThreadsOnFork

        #c.on_error = lambda { |ex| Airbrake.notify(ex) }  #FUTURE: Choose a better failure mode:
      end
    end

    def backburner(&p)
      if block_given?
        Backburner.configure(&p)
      else
        Backburner.configuration
      end
    end

    def squash(&p)
      if block_given?
        SquashRepeater::Configuration::Squash.configure(&p)
      else
        SquashRepeater::Configuration::Squash.configuration
      end
    end

    # Return an array of all available loggers
    def loggers
      [logger, backburner.logger]  #FUTURE: Can we somehow get a Squash logger for this?
    end

    def logger=(value)
      #FUTURE: Can we somehow also set a Squash logger for this?
      #NB: Squash doesn't allow you to use a different logger
      @logger = value
      #NB: Backburner can be quite chatty.  You may prefer to change the default log-level a bit higher because of this.
      backburner.logger = @logger
    end
  end
end

# This class relies on the class hierarchy having been created (above):
require "squash_repeater/configure/squash"

# Set the defaults:
SquashRepeater.configure
