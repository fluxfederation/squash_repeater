# Configuration methods are in `configure.rb`
# Exception capture and re-run are in `exception_queue.rb`

module SquashRepeater
  class Error < RuntimeError; end
end

require "squash_repeater/version"
require "squash_repeater/configure"
require "squash_repeater/exception_queue"
require "squash_repeater/squash_ruby"
