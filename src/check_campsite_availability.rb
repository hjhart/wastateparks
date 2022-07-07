# frozen_string_literal: true

require_relative './application'

class CheckCampsiteAvailability
  include Interactor
  include Logging

  def call
    context.guid = [context.campground.id, context.params.start_date, context.params.end_date]

    query = URI.encode_www_form(campground_url_params)
    url = URI::HTTPS.build(host: 'washington.goingtocamp.com', path: '/create-booking/results', query: query)

    logger.debug "Opening #{url}"
    driver.get url

    # wait until "List view" button is visible
    wait.until do
      driver.find_element(:css, '.btn-search-results-toggle-label')
    end

    logger.debug "Clicking consent button"
    # click consent button
    driver.find_element(:css, '#consentButton').click

    # wait until consent button is gone
    wait.until do
      driver.find_elements(:css, '#consentButton').size.zero?
    end

    logger.debug "Clicking list view"
    # click "List view"
    driver.find_elements(:css, '.btn-search-results-toggle-label').last.click

    # wait until availability or list results show up
    wait.until do
      driver.find_elements(:css,
                           '.list-view-results').size.positive? || driver.find_elements(:css,
                                                                                        '.availability-panel').size.positive?
    end

    logger.debug "Looking for results..."
    results_pane = driver.find_elements(:css, '.list-view-results')
    if results_pane.size.positive?
      context.message = "Availability was found at campground #{context.campground.name}"
      relevant_text = results_pane.first.find_elements(:css, ".resource-name").map do |element|
        next unless element.displayed?
        element.text.strip
      end
      context.data = { "available_sites": relevant_text}
      CampsiteResultEnhancer.call(driver: driver, url: driver.current_url, context: context, logger: logger)
      context.availability_found = true
      context.url = driver.current_url
    else
      no_availability_panel = driver.find_elements(:css, '.availability-panel')
      if no_availability_panel.size.positive?
        if no_availability_panel.first.text.include?('No Available')
          context.message = 'no availability found!'
        else
          context.fail!(error: "Unable to find expected 'No Available' text")
        end
      else
        context.fail!(error: "Couldn't find either list results or availability panel")
      end
    end
  rescue StandardError => e
    context.fail!(error: e.message)
  ensure
    driver.close
  end

  private

  def campground_url_params
    {
      'mapId' => context.campground.resource_location_id,
      'searchTabGroupId' => 0,
      'bookingCategoryId' => 0,
      'startDate' => context.params.start_date,
      'endDate' => context.params.end_date,
      'isReserving' => true,
      'equipmentId' => Equipment.camping,
      'subEquipmentId' => context.params.subequipment_id,
      'partySize' => context.params.party_size,
      'resourceLocationId' => '-2147483538',
      'nights' => 2,
      'searchTime' => '2022-06-26T14:13:52.532'
    }
  end

  def driver
    @driver ||= begin
      options = Selenium::WebDriver::Chrome::Options.new
      # options.add_argument('--headless')
      Selenium::WebDriver.for :chrome, options: options
    end
  end

  def wait
    @wait ||= Selenium::WebDriver::Wait.new(timeout: 10) # seconds
  end
end

class CampsiteResultEnhancer
  def self.call(driver:, context:, url:, logger:)
    logger.debug " -> Enhancing result with first available site"
    results_pane = driver.find_elements(:css, '.list-view-results').first
    first_availability = results_pane.find_elements(:css, '.availability-label').select { |el| el.displayed? }.first
    
    original_number_of_entries = driver.find_elements(:css, '.list-view-results .list-entry').size 
    first_availability.click
    logger.debug " -> Clicked on first layer of availability"

    wait.until do
      entries = driver.find_elements(:css, '.list-view-results .list-entry').size
      logger.debug " -> Number of entries changed from #{original_number_of_entries} to #{entries}"
      entries > 0 && entries != original_number_of_entries 
    end
    
    results_pane = driver.find_elements(:css, '.list-view-results').first
    first_availability = results_pane.find_elements(:css, '.availability-label').select { |el| el.displayed? }.first
    first_availability.click
    logger.debug " -> Clicked on second layer of availability"

    wait.until do
      driver.find_elements(:css, '.more-details').size.positive?
    end
    logger.debug " -> Found details"
    columns = results_pane.find_elements(:css, '.more-details > div')
    campsite_name = results_pane.find_elements(:css, "h2").first.text.strip
    context.guid << campsite_name
    context.url = driver.current_url
    context.message = context.message + " at campsite #{campsite_name}"
    data = { site_name: campsite_name }
    columns.each do |column|
      keys = column.find_elements(:css, 'div div.details-header').map { |el| el.text.strip }
      values = column.find_elements(:css, 'div ul').map { |list| 
        list.find_elements(:css, 'li.details-entry').map { |list_item| list_item.text.strip }.join(" / ")
      }

      if keys.size == values.size
        data = data.merge(keys.zip(values).to_h)
        logger.debug " -> Added #{keys.zip(values).to_h}"
      else  
        logger.error " -> Something unexpected happened! Keys do not match values in column. Skipping column. {keys: #{keys}, values: #{values}}"
        debugger
      end
    end
    
    context.data = data if data.keys.size > 0
  rescue StandardError => e
    logger.error " -> Something unexpected happened! Couldn't find 'details' pane. Skipping."
  end

  def self.wait
    @wait ||= Selenium::WebDriver::Wait.new(timeout: 10) # seconds
  end
end