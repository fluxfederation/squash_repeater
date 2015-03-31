# Wrap Squash::Ruby's slightly nasty configuration method with
# a config-block class
class SquashRepeater::Ruby::Configuration::Squash
  def self.configure
    self.configuration  # Initialise
    yield configuration if block_given?
  end

  def self.configuration
    @configuration ||= self.new
    return @configuration
  end

  def method_missing(method_sym, *args, &p)
    fail "Can't extract a meaningful name from the provided method_sym" unless method_sym.to_s =~ /^(.+)(=|)$/
    key, val = $1.to_sym, args[0]
    if method_sym.to_s =~ /=$/
      # Setter
      Squash::Ruby.configure({ key => val })

    else
      # Getter
      Squash::Ruby.configuration(key)
    end
  end
end
