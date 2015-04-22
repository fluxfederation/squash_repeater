require "squash_repeater"

SquashRepeater.configure do |c|
  # The nature of SquashRepeater is that a tiny local queueing system
  # captures the Squash notification, and retransmits it from a worker.
  # Therefore, we assume beanstalkd is running locally:

  ###
  # Backburner defaults:
  #c.backburner.beanstalk_url = "beanstalk://localhost"
  #c.backburner.tube_namespace = "squash-repeater"
  #c.backburner.max_job_retries = 10   # retry jobs 10 times
  #c.backburner.retry_delay = 30   # wait 30 seconds in between retries

  ###
  # You can set Squash::Ruby config here, or through their configration method. Either way, they must be set:
  # @param api_host:
  #c.squash.api_host = "http://no.where"
  # @param api_key:
  #c.squash.api_key = "12345"
  # @param environment:
  c.squash.environment = Rails.env if defined? Rails.env
  # @param disabled:
  #c.squash.disabled = !c.squash_key

  ###
  # This sets the SquashRepeater and Backburner logging.
  # There's no easy way to set Squash to use Logger:
  c.logger = Rails.logger if defined? Rails.logger
end
