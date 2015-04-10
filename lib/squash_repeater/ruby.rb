# Configuration methods are in `configure.rb`
# Exception capture and re-run are in `exception_queue.rb`

module SquashRepeater
  class Error < RuntimeError; end
end

require "squash_repeater/ruby/version"
require "squash_repeater/ruby/configure"
require "squash_repeater/ruby/exception_queue"
require "squash_repeater/ruby/squash_ruby"
