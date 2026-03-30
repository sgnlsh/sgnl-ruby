# frozen_string_literal: true

Sgnl.configure do |config|
  # Your project key from app.sgnl.sh (sk_live_* or sk_test_*).
  # Defaults to ENV["SGNL_PROJECT_KEY"].
  # config.project_key = "sk_live_..."

  # Requests slower than this (ms) are reported as slow events.
  # config.slow_threshold_ms = 2000

  # Auto-track GET pageviews via middleware.
  # config.track_usage = true

  # Disable in specific environments:
  # config.enabled = !Rails.env.test?
end
