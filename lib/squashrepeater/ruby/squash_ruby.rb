require "squash/ruby"

# Monkey-patch Squash::Ruby so that instead of immediately sending Squash
# notifications, capture the HTTP data in the local beanstalk/backburner queue
module Squash::Ruby
  class <<self
    private

    alias :http_transmit__original :http_transmit

    # processing
    def http_transmit(url, headers, body)
      SquashRepeater::Ruby.capture_exception(url, headers, body, @configuration, ENV["no_proxy"])
    end
  end
end


#FUTURE(willjr): Look into using hooks, to try to decouple the two parts of the lib
# module Squash::Ruby

#   # You need to set a configuration :http_transmit_hook
#   # This is supposed to contain lambdas/procs that will


#   class << self
#     private

#     alias :http_transmit__original :http_transmit

#     def http_transmit(url, headers, body)
#       no_hook = lambda {|*args| self.http_transmit__original(*args) }
#       http_transmit_hook = configuration(:http_transmit_hook) || no_hook
#       http_transmit_hook.call(url, headers, body)
#     end
#   end
# end
