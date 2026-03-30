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

      track_usage(env, status) if Sgnl.configuration.track_usage
      track_slow(env, duration_ms) if duration_ms >= Sgnl.configuration.slow_threshold_ms

      [status, headers, response]
    end

    private

    def report_error(exception, env)
      Sgnl.error(exception, metadata: request_metadata(env))
    end

    def track_usage(env, status)
      return unless env["REQUEST_METHOD"] == "GET"
      return if status.to_i >= 400

      Sgnl.usage("pageview", metadata: {
        path: env["PATH_INFO"],
        method: env["REQUEST_METHOD"],
        status: status.to_i
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
        path: env["PATH_INFO"],
        user_agent: env["HTTP_USER_AGENT"]
      }
      meta[:controller] = env["action_controller.instance"]&.class&.name if env["action_controller.instance"]
      meta.compact
    end

    def ignored?(exception)
      Sgnl.configuration.ignored_exceptions.include?(exception.class.name)
    end
  end
end
