# frozen_string_literal: true

module Sgnl
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      begin
        status, headers, response = @app.call(env)
      rescue Exception => e # rubocop:disable Lint/RescueException
        report_error(e, env) unless ignored?(e)
        raise
      end

      duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round

      track_usage(env, status, duration_ms) if Sgnl.configuration.track_usage
      track_slow(env, duration_ms) if duration_ms >= Sgnl.configuration.slow_threshold_ms

      [status, headers, response]
    end

    private

    def report_error(exception, env)
      Sgnl.error(exception, metadata: request_metadata(env))
    end

    ASSET_EXTENSIONS = /\.(js|css|png|jpg|jpeg|gif|svg|ico|woff2?|ttf|eot|map)$/i

    def track_usage(env, status, duration_ms)
      return unless env["REQUEST_METHOD"] == "GET"
      return if status.to_i >= 400
      return if env["PATH_INFO"]&.match?(ASSET_EXTENSIONS)
      return if env["PATH_INFO"]&.start_with?("/assets", "/packs", "/vite")
      return unless env["HTTP_ACCEPT"]&.include?("text/html") || env["action_controller.instance"]
      return if rand > Sgnl.configuration.usage_sample_rate

      Sgnl.usage("pageview", metadata: {
        path: scrub_path(env["PATH_INFO"]),
        method: env["REQUEST_METHOD"],
        status: status.to_i,
        latency_ms: duration_ms
      })
    end

    def track_slow(env, duration_ms)
      Sgnl.slow(
        "#{env["REQUEST_METHOD"]} #{env["PATH_INFO"]}",
        duration_ms: duration_ms,
        metadata: request_metadata(env)
      )
    end

    def request_metadata(env)
      meta = {
        method: env["REQUEST_METHOD"],
        path: scrub_path(env["PATH_INFO"]),
      }
      meta[:controller] = env["action_controller.instance"]&.class&.name if env["action_controller.instance"]
      meta.compact
    end

    # Replace numeric IDs and UUIDs in paths with :id to avoid sending identifiers
    def scrub_path(path)
      return path unless path
      path
        .gsub(%r{/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}}i, "/:id") # UUIDs
        .gsub(%r{/\d+}, "/:id") # numeric IDs
    end

    def ignored?(exception)
      Sgnl.configuration.ignored_exceptions.include?(exception.class.name)
    end
  end
end
