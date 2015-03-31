module SquashRepeater::Ruby::Configuration::Squash
  def self.configure
    yield self
  end
  
  def method_missing(method_sym, *args, &p)
    return super  unless respond_to?(method_sym)

    if method_sym.to_s =~ /^(.*)=$/
      # Setter
      Squash::Ruby.configure({ $1.to_sym => args[0] })
    else
      # Getter
      Squash::Ruby.configuration($1.to_sym)
    end
  end

  def respond_to?(method_sym, include_private=false)
    method_name = method_sym.to_s.sub(/=$/, "")
    Squash::Ruby.configuration(method_name.to_sym) ? true : super
  end
end
