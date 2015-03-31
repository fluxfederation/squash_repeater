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
    if method_sym.to_s =~ /^(.*)=$/
      # Setter
      key, val = $1.to_sym, args[0]
      Squash::Ruby.configure({ key => val })

    else
      # Getter
      key = $1.to_sym
      Squash::Ruby.configuration(key)
    end
  end
end
