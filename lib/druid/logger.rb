# Supported Levels: https://github.com/twitter/util
require 'logger'

module Druid
  class Logger
    include Druid::TopLevelPackages

    attr_accessor :logger
    delegate :debug, :info, :warn, :error, :fatal, :unknown, to: :logger

    def initialize
      @logger = ::Logger.new(STDOUT)
    end

    def set_level(level)
      set_logger_level(level)
      set_logback_level(level)
      set_twitter_level(level)
    end

    private

    def set_logback_level(level)
      org.slf4j.LoggerFactory.
        getLogger(org.slf4j.Logger.ROOT_LOGGER_NAME).
        setLevel(get_logback_level(level))
    end

    def set_logger_level(level)
      logger.level = get_logger_level(level)
    end

    def set_twitter_level(level)
      com.twitter.logging.Logger.
        get("com.twitter").
        setLevel(java.util.logging.Level::WARNING)
    end

    def get_logback_level(level)
      ch.qos.logback.classic.Level.const_get(map_logback_level(level))
    end

    def get_logger_level(level)
      @logger.class.const_get(map_logger_level(level))
    end

    def get_twitter_level(level)
      java.util.logging.Level.const_get(map_twitter_level(level))
    end

    def map_logback_level(level)
      case level
      when :critical
        'ERROR'.freeze
      when :fatal
        'ERROR'.freeze
      else
        level.to_s.upcase
      end
    end

    def map_logger_level(level)
      case level
      when :trace
        'DEBUG'.freeze
      when :critical
        'ERROR'.freeze
      else
        level.to_s.upcase
      end
    end

    def map_twitter_level(level)
      case level
      when :warn
        'WARNING'.freeze
      else
        level.to_s.upcase
      end
    end
  end
end
