# Wrap Squash::Ruby's slightly nasty configuration method with
# a config-block class
#
# Squash accepts configuration via a key-value hash passed to the #configure class method
# and provides reading that configuration by passing a key the #configuration class method and returning the
# value for that key/attribute.
# This class attempts to emulate a tradtional Configure-block class (a la Struct / OpenStruct) but calls-into
# Squash's configuration methods;  this helps make the rest of the SquashRepeater Configure class simpler.
# This class is probably more-like OpenStruct in-use, as it doesn't do any checking of "allowed" attributes, which
# is more-similar to how Squash treats configuration attr's.
# I didn't bother implementing all the methods you might expect, as this should really only be consumed by
# SquashRepeater users, at a fairly simplistic level.

class SquashRepeater::Ruby::Configuration::Squash
  def self.configure
    self.configuration  # Initialise
    yield configuration if block_given?
  end

  def self.configuration
    @configuration ||= self.new
    #return @configuration
  end

  def method_missing(method_sym, val=nil)
    fail "Can't extract a meaningful name from the provided method_sym" unless method_sym.to_s =~ /^(.+?)=?$/
    key = $1.to_sym

    if method_sym.to_s =~ /=$/
      # Setter
      Squash::Ruby.configure({ key => val })
    end
    # Getter
    #NB: Always return the value for the key
    Squash::Ruby.configuration(key)
  end
end
