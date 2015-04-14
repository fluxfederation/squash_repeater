# Configuration methods are in `configure.rb`
# Exception capture and re-run are in `exception_queue.rb`

require "squash_repeater/version"
require "squash_repeater/configure"
require "squash_repeater/exception_queue"
require "squash_repeater/squash_ruby"

# For Rails generators (only if Rails is used):
require "generators/squash_repeater/install_generator" if defined? Rails

class SquashRepeater::Error < RuntimeError; end
