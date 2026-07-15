module Morphosource
  # Writes every message to both a Logger (e.g. a run-specific log file) and STDOUT
  # (captured by container log aggregation regardless of whether the file survives),
  # so callers don't have to remember to do both separately at each call site.
  class DualLogger
    def initialize(logger = nil, prefix: nil)
      @logger = logger
      @prefix = prefix
    end

    def log(msg, level: :info)
      @logger&.send(level, msg)
      puts [@prefix, msg].compact.join(' ')
    end
  end
end
