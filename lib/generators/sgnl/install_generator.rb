# frozen_string_literal: true

module Sgnl
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      desc "Creates a sgnl initializer."

      def copy_initializer
        template "initializer.rb", "config/initializers/sgnl.rb"
      end

      def show_instructions
        say ""
        say "sgnl installed! Set your project key:", :green
        say "  1. Get your sk_live_* key from app.sgnl.sh"
        say "  2. Add SGNL_PROJECT_KEY to your environment (or edit config/initializers/sgnl.rb)"
        say ""
      end
    end
  end
end
