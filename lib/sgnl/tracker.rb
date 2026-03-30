# frozen_string_literal: true

require "thread"

module Sgnl
  class Tracker
    MAX_QUEUE = 100

    def initialize
      @queue = SizedQueue.new(MAX_QUEUE)
      @thread = start_thread
    end

    def push(event)
      @queue.push(event, true) # non-blocking; drops if full
    rescue ThreadError
      # queue full — drop the event silently
    end

    def shutdown
      @queue.push(:stop)
      @thread&.join(5)
    end

    private

    def start_thread
      Thread.new do
        client = Client.new(
          project_key: Sgnl.configuration.project_key,
          api_url: Sgnl.configuration.api_url,
          api_version: Sgnl.configuration.api_version
        )

        loop do
          event = @queue.pop
          break if event == :stop

          payload = {
            type: event[:type],
            message: event[:message],
            backtrace: event[:backtrace],
            metadata: event[:metadata],
            occurred_at: Time.now.utc.iso8601
          }.compact

          client.send_event(payload)
        end
      end.tap { |t| t.abort_on_exception = false }
    end
  end
end
