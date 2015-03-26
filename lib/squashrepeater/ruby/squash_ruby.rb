require "squash/ruby"

# Monkey-patch Squash::Ruby so that instead of immediately sending Squash
# notifications, capture the HTTP data in the local beanstalk/backburner queue
module Squash
  module Ruby
    class <<self
      private

      alias :http_transmit__original :http_transmit

      # Capture the HTTP data, and store it in the beanstalkd queue for later
      # processing
      def http_transmit(url, headers, body)
        SquashRepeater::Ruby.enqueue(url, headers, body, @configuration, ENV["no_proxy"])
      end
    end
  end
end
