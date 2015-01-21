require "rails/generators"

module SquashRepeater
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Creates SquashRepeater initializer for your application"

      def copy_initializer
        template "squash_repeater_initializer.rb", "config/initializers/squash_repeater.rb"

        puts "Install complete! Truly Outrageous!"
      end
    end
  end
end
