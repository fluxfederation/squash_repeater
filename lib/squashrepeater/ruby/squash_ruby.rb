require "squash/ruby"

#FUTURE(willjr): Look into using hooks, to try to decouple the two parts of the lib
# module Squash::Ruby

# Monkey-patch Squash::Ruby so that instead of immediately sending Squash
# notifications, capture the HTTP data in the local beanstalk/backburner queue
module Squash::Ruby
  class <<self
    private

    alias :http_transmit__original :http_transmit

    # processing
    def http_transmit(url, headers, body)
      SquashRepeater::Ruby.capture_exception(
        url: url, headers: headers, body: body,
        squash_configuration: @configuration,
        no_proxy_env: ENV["no_proxy"]
      )
    end
  end
end
