# frozen_string_literal: true

require_relative './application'

class Orchestrator
  include Logging
  include Storage


  def call
    logger.debug 'Starting the application...'

    every_n_minutes(config.minutes_interval) do
      logger.debug "Checking on campsite #{config.campground.name} at #{Time.now.strftime('%X')}"
      result = CheckCampsiteAvailability.call(params: config)

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
  end

  private

  def config
    # no availability
    # CampgroundSearchParameters.new(campground: Campground.alta_lake, start_date: '2022-07-29', end_date: '2022-07-31',
                                  #  party_size: 2, subequipment_id: Subequipment.one_tent, minutes_interval: 10)
    # some availability
    CampgroundSearchParameters.new(campground: Campground.alta_lake, start_date: '2022-06-29', end_date: '2022-06-30',
                                   party_size: 2, subequipment_id: Subequipment.one_tent, minutes_interval: 10)
  end
end

Orchestrator.new.call
