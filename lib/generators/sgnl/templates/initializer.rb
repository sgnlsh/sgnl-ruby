# frozen_string_literal: true

Sgnl.configure do |config|
  # The API determines environment from the key prefix:
  #   sk_live_* → live environment (production data)
  #   sk_test_* → test environment (dev/staging data)
  #
  # Set SGNL_PROJECT_KEY per environment:
  #   development: SGNL_PROJECT_KEY=sk_test_...
  #   production:  SGNL_PROJECT_KEY=sk_live_...
  #
  # Falls back to SGNL_TEST_KEY if SGNL_PROJECT_KEY is not set.
  # config.project_key = ENV["SGNL_PROJECT_KEY"]

  # Requests slower than this (ms) are reported as slow events.
  # config.slow_threshold_ms = 2000

  # Auto-track GET pageviews via middleware.
  # config.track_usage = true

  # Disable in test environment:
  config.enabled = !Rails.env.test?
end
