# frozen_string_literal: true

require_relative './application'

class Orchestrator
  include Logging
  include Storage


  def call
    logger.debug 'Starting the application...'

    every_n_minutes(config.minutes_interval) do
      config.campgrounds.each do |campground|
        logger.debug "Checking on campsite #{campground.name} at #{Time.now.strftime('%X')}"
        result = CheckCampsiteAvailability.call(params: config, campground: campground)

        if result.success?
          logger.info 'Ran checker successfully'
          logger.info [result.message, result.data].join(' ')
          if result.availability_found
            storage.insert_availability(guid: result.guid, message: result.message, data: result.data, url: result.url) 
            Notification.from_result(result).send!
          end
        end

        logger.error "There was an error finding what we were expecting #{result.error}" if result.failure?
      end
      logger.debug "Pausing until next check in #{config.minutes_interval} minutes"
    end
  end

  private

  def config
    # config_file = YAML.load_file('./config/no_availability_search.yml')
    config_file = YAML.load_file('./config/search.yml')
    CampgroundSearchParameters.new(config_file.to_h)
  end
end

Orchestrator.new.call
