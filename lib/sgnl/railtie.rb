# frozen_string_literal: true

module Sgnl
  class Railtie < Rails::Railtie
    initializer "sgnl.middleware" do |app|
      app.middleware.use Sgnl::Middleware
    end

    # Subscribe to Rails 7.1+ error reporting if available.
    initializer "sgnl.error_subscriber" do
      if defined?(Rails.error) && Rails.error.respond_to?(:subscribe)
        Rails.error.subscribe(Sgnl::ErrorSubscriber.new)
      end
    end

    at_exit { Sgnl.shutdown }
  end

  class ErrorSubscriber
    def report(error, handled:, severity:, context: {}, source: nil)
      return if handled # only report unhandled crashes
      return unless Sgnl.enabled?

      Sgnl.error(error, metadata: context.merge(severity: severity, source: source).compact)
    end
  end
end
