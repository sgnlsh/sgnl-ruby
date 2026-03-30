# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Sgnl
  class Client
    TIMEOUT = 5

    def initialize(project_key:, api_url:, api_version: "v1")
      @project_key = project_key
      @base_url = "#{api_url}/#{api_version}"
      @uri = URI.parse("#{@base_url}/events")
    end

    def send_event(payload)
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = @uri.scheme == "https"
      http.open_timeout = TIMEOUT
      http.read_timeout = TIMEOUT

      request = Net::HTTP::Post.new(@uri.path)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@project_key}"
      request.body = JSON.generate(payload)

      response = http.request(request)
      response.code.to_i < 500
    rescue StandardError
      false
    end

    def update_app_settings(settings)
      uri = URI.parse("#{@base_url}/apps/me")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = TIMEOUT
      http.read_timeout = TIMEOUT

      request = Net::HTTP::Patch.new(uri.path)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@project_key}"
      request.body = JSON.generate(settings)

      response = http.request(request)
      response.code.to_i < 400
    rescue StandardError
      false
    end
  end
end
