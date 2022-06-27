# frozen_string_literal: true

require_relative './application'

class CheckCampsiteAvailability
  include Interactor

  def call
    context.guid = [context.params.campground.id, context.params.start_date, context.params.end_date].join('-')

    query = URI.encode_www_form(campground_url_params)
    url = URI::HTTPS.build(host: 'washington.goingtocamp.com', path: '/create-booking/results', query: query)
    driver.get url

    # wait until "List view" button is visible
    wait.until do
      driver.find_element(:css, '.btn-search-results-toggle-label')
    end

    # click consent button
    driver.find_element(:css, '#consentButton').click

    # wait until consent button is gone
    wait.until do
      driver.find_elements(:css, '#consentButton').size.zero?
    end

    # click "List view"
    driver.find_elements(:css, '.btn-search-results-toggle-label').last.click

    # wait until availability or list results show up
    wait.until do
      driver.find_elements(:css,
                           '.list-view-results').size.positive? || driver.find_elements(:css,
                                                                                        '.availability-panel').size.positive?
    end

    results_pane = driver.find_elements(:css, '.list-view-results')
    if results_pane.size.positive?
      context.message = "Availability was found at campsite #{context.params.campground.name}!"
      relevant_text = results_pane.first.find_elements(:css, ".resource-name").map(&:text).join(", ")
      context.data = { "available_sites": relevant_text}
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
      'mapId' => context.params.campground.id,
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
