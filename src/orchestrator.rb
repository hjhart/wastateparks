# frozen_string_literal: true

require_relative './application'

class Orchestrator
  include Logging

  def call
    logger.debug 'Starting the application...'

    every_n_minutes(5) do
      logger.debug "Checking on campsite #{config.campground.name} at #{Time.now.strftime('%X')}"
      result = CheckCampsiteAvailability.call(params: config)

      if result.success?
        logger.info 'You succeeded in either finding or not finding availability'
        # puts result.found_availability? ? "You found availability" : "You didn't find availability"
        # puts result.guid
        puts result.message
        # puts result.data.inspect
        # puts result.url
      end

      logger.error "There was an error finding what we were expecting #{result.error}" if result.failure?
    end
  end

  private

  def config
    # no availability
    CampgroundSearchParameters.new(campground: Campground.alta_lake, start_date: '2022-07-29', end_date: '2022-07-31',
                                   party_size: 2, subequipment: Subequipment.one_tent, minute_interval: 10)
    # some availability
    # CampgroundSearchParameters.new(Campground.alta_lake, '2022-06-29', '2022-06-30', 2, Subequipment.two_tents)
  end
end

Orchestrator.new.call
