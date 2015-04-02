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
    def initialize
      self.logger = Logger.new(STDOUT)

      backburner do |c|
        # The nature of SquashRepeater is that a tiny local queueing system
        # captures the Squash notification, and retransmits it from a worker.
        # Therefore, we assume beanstalkd is running locally:
        c.beanstalk_url = "beanstalk://localhost"
        #c.beanstalk_url = "beanstalk://127.0.0.1"
        c.tube_namespace   = "squash-repeater"

        # NB: This relies on forking behaviour!
        c.default_worker = Backburner::Workers::Forking

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
        SquashRepeater::Ruby::Configuration::Squash.configure(&p)
      else
        SquashRepeater::Ruby::Configuration::Squash.configuration
      end
    end

    def loggers
      [backburner.logger]  #FUTURE: Can we somehow get a Squash logger for this?
    end

    def logger=(value)
      # Squash doesn't allow you to use a different logger
      backburner.logger = value  #FUTURE: Can we somehow set a Squash logger for this?
    end
  end
end

# This class relies on the class hierarchy having been created (above):
require "squashrepeater/ruby/configure/squash"

# Set the defaults:
SquashRepeater::Ruby.configure
