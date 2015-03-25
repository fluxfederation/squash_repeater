require "squashrepeater/ruby"

SquashRepeater::Ruby.configure do |c|
  # The nature of SquashRepeater is that a tiny local queueing system
  # captures the Squash notification, and retransmits it from a worker.
  # Therefore, we assume beanstalkd is running locally:

  # c.queue_host = "localhost"
  # c.namespace = "squash-repeater"

  # You can set Squash::Ruby config here, or through their configration method:
  # Squash::Ruby api_host:
  c.squash_url = "http://no.where"
  # Squash::Ruby api_key:
  c.squash_key = "12345"
  #Squash::Ruby environment:
  c.environment = Rails.env if defined? Rails.env
end
