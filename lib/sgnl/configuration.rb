# frozen_string_literal: true

module Sgnl
  class Configuration
    attr_accessor :project_key,       # sk_live_* or sk_test_*
                  :api_url,           # defaults to https://api.sgnl.sh
                  :api_version,       # API version prefix (default: "v1")
                  :enabled,           # kill switch
                  :fix_prompts,       # enable AI fix prompt generation (default: true)
                  :slow_threshold_ms, # requests slower than this get reported (default: 2000)
                  :track_usage,       # auto-track pageviews via middleware (default: true)
                  :ignored_exceptions # exception classes to skip (default: common 4xx errors)

    def initialize
      @project_key = ENV["SGNL_PROJECT_KEY"] || ENV["SGNL_TEST_KEY"]
      @api_url = ENV.fetch("SGNL_API_URL", "https://api.sgnl.sh")
      @api_version = ENV.fetch("SGNL_API_VERSION", "v1")
      @enabled = true
      @fix_prompts = true
      @slow_threshold_ms = 2000
      @track_usage = true
      @ignored_exceptions = default_ignored_exceptions
    end

    private

    def default_ignored_exceptions
      exceptions = []
      exceptions << "ActionController::RoutingError" if defined?(ActionController::RoutingError)
      exceptions << "AbstractController::ActionNotFound" if defined?(AbstractController::ActionNotFound)
      exceptions << "ActionController::UnknownFormat" if defined?(ActionController::UnknownFormat)
      exceptions
    end
  end
end
