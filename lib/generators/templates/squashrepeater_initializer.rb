require "squashrepeater/ruby"

SquashRepeater::Ruby.configure do |c|
  # The nature of SquashRepeater is that a tiny local queueing system
  # captures the Squash notification, and retransmits it from a worker.
  # Therefore, we assume beanstalkd is running locally:

  ###
  # Backburner defaults:
  # c.queue_host = "localhost"
  # c.namespace = "squash-repeater"

  ###
  # You can set Squash::Ruby config here, or through their configration method. Either way, they must be set:
  # @param api_host:
  # c.squash_url = "http://no.where"
  # @param api_key:
  # c.squash_key = "12345"
  # @param environment:
  c.environment = Rails.env if defined? Rails.env

  ###
  # This sets the Backburner (queue) logging.  There's no easy way to set Squash to use Logger:
  c.logger = Rails.logger if defined? Rails.logger
end
