# frozen_string_literal: true

require_relative "sgnl/configuration"
require_relative "sgnl/backtrace_parser"
require_relative "sgnl/client"
require_relative "sgnl/tracker"
require_relative "sgnl/middleware"
require_relative "sgnl/railtie"

module Sgnl
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    # Report an error manually.
    #
    #   Sgnl.error(exception)
    #   Sgnl.error(exception, metadata: { user_id: 42 })
    #
    def error(exception, metadata: {})
      return unless enabled?

      frames = BacktraceParser.parse(exception.backtrace || [])
      tracker.push(
        type: "error",
        message: "#{exception.class}: #{exception.message}",
        backtrace: frames,
        metadata: metadata
      )
    end

    # Track a slow operation manually.
    #
    #   Sgnl.slow("POST /api/chat", duration_ms: 4200, metadata: { model: "gpt-4" })
    #
    def slow(message, duration_ms:, metadata: {})
      return unless enabled?

      tracker.push(
        type: "slow",
        message: message,
        metadata: metadata.merge(duration_ms: duration_ms)
      )
    end

    # Track a usage event (pageview, API call, etc).
    #
    #   Sgnl.usage("pageview", metadata: { path: "/dashboard" })
    #
    def usage(message, metadata: {})
      return unless enabled?

      tracker.push(
        type: "usage",
        message: message,
        metadata: metadata
      )
    end

    # Record a deploy.
    #
    #   Sgnl.deploy(sha: "abc123", message: "v1.2.0")
    #
    def deploy(sha: nil, message: nil, source: "sdk")
      return unless enabled?

      tracker.push(
        type: "deploy",
        message: message || "Deploy #{sha}",
        metadata: { sha: sha, source: source }.compact
      )
    end

    def tracker
      @tracker ||= begin
        t = Tracker.new
        sync_settings
        t
      end
    end

    def shutdown
      @tracker&.shutdown
    end

    def enabled?
      configuration.enabled && configuration.project_key
    end

    def reset!
      shutdown
      @tracker = nil
      @configuration = Configuration.new
    end

    private

    def sync_settings
      return unless enabled?

      client = Client.new(
        project_key: configuration.project_key,
        api_url: configuration.api_url,
        api_version: configuration.api_version
      )
      client.update_app_settings(
        fix_prompts_enabled: configuration.fix_prompts
      )
    rescue StandardError
      # Never let config sync break the app
    end
  end
end
