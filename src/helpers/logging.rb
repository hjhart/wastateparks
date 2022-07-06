# frozen_string_literal: true

module Logging
  # This is the magical bit that gets mixed into your classes
  def logger
    Logging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    @logger ||= begin 
      $stdout.sync = true
      logger = Logger.new($stdout)
      if ENV['DEBUG'] == 'true'
        logger.level = Logger::DEBUG
      else
        logger.level = Logger::INFO
      end
      logger
    end
  end
end
