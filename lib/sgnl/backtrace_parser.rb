# frozen_string_literal: true

module Sgnl
  module BacktraceParser
    # Converts Ruby backtrace lines into the API's frame format.
    #
    # Input:  "app/models/user.rb:42:in `save!'"
    # Output: { file: "app/models/user.rb", line: 42, method: "save!" }
    #
    FRAME_PATTERN = /\A(.+):(\d+):in [`'](.+)'\z/
    MAX_FRAMES = 20

    module_function

    def parse(backtrace)
      backtrace.first(MAX_FRAMES).filter_map do |line|
        match = FRAME_PATTERN.match(line)
        next unless match

        { file: match[1], line: match[2].to_i, method: match[3] }
      end
    end
  end
end
