# campground.rb
require 'kimurai'

class Campground < Kimurai::Base
  attr_accessor :visited_campground_names, :visited_section_names, :visited_plot_names

  @name = "campground"
  @engine = :selenium_chrome
  start_date = "2020-08-01T00:00:00.000Z"
  end_date = "2020-08-02T00:00:00.000Z"
  party_size = 2
  params = { 
    "mapId" => -2147483346,
    "searchTabGroupId" => 0,
    "bookingCategoryId" => 0,
    "startDate" => start_date,
    "endDate" => end_date,
    "nights" => 1,
    "isReserving" => true,
    "equipmentId" => -32768,
    "subEquipmentId" => -32768,
    "partySize" => party_size,
    "searchTime" => "Mon%20Jul%2027%202020%2017:36:28%20GMT-0700%20(Pacific%20Daylight%20Time)",
    "resourceLocationId" => "-2147483538"
  }
  start_url = URI::HTTPS.build(host: "washington.goingtocamp.com", path: "/create-booking/results", query: params.to_query)
  @start_urls = [start_url.to_s]

  def parse(response, url:, data: {})
    browser.click_on 'I Consent'
    response = browser.current_response

    items = {}
    visited_campground_names = []
    visited_section_names = []
    visited_plot_names = []

    browser.click_on 'LIST View'
    while browser.all(:css, ".resource-name div", text: none_of_these_words_regexp(visited_campground_names), wait: 2).present?
      # Click on campground
      campground_selection_url = browser.current_url
      campground_element = browser.all(:css, ".resource-name div", text: none_of_these_words_regexp(visited_campground_names)).first
      logger.info "Found element with html #{campground_element['innerHTML']}"
      campground_name = campground_element.text
      break if campground_name.blank?
      visited_campground_names << campground_name
      campground_element.click

      wait_until_breadcrumb_updated_to_display(campground_name)
      show_and_hide_available_locations

      while browser.all(:css, ".resource-name div", text: none_of_these_words_regexp(visited_section_names), wait: 2).present?
        # Click on campground section
        section_selection_url = browser.current_url
        section_element = browser.all(:css, ".resource-name div", text: none_of_these_words_regexp(visited_section_names)).first
        logger.info "Found element with html #{section_element['innerHTML']}"
        section_name = section_element.text
        break if section_name.blank?
        visited_section_names << section_name
        section_element.click

        wait_until_breadcrumb_updated_to_display(section_name)
        show_and_hide_available_locations

        while browser.all(:css, ".resource-name div", text: none_of_these_words_regexp(visited_plot_names), wait: 2).present?
          # Click on campground plot for details
          plot_selection_url = browser.current_url
          plot_element = browser.all(:css, ".resource-name div", text: none_of_these_words_regexp(visited_plot_names)).first
          logger.info "Found element with html #{plot_element['innerHTML']}"
          plot_name = plot_element.text
          break if plot_name.blank?
          hide_covid_notice
          begin
            plot_element.click
          rescue Selenium::WebDriver::Error::ElementNotInteractableError => e
            logger.error e.message
            break
          end
          visited_plot_names << plot_name

          # Gather details
          logger.debug "Grabbing details"
          text = browser.find(:css, '.view-details', match: :first).text
          
          logger.debug "Grabbing image"
          image = browser.find(:css, '.site-image', match: :first)['src']
          i = 0
          details = {}
          logger.debug "Grabbing more details..."
          more_details = browser.all(:css, '.more-details div div')
          while (i < more_details.size) do
            value = more_details[i].text 
            key = more_details[i+1].text.underscore
            value.gsub!(key, "")
            details[key] = value.strip
            i+=2
          end
          directions_url = URI::HTTPS.build(host: "maps.google.com", path: "/maps", query: {saddr: "1911 18th ave s 98144", daddr: campground_name}.to_query)
          item_name = "#{campground_name} > #{section_name} > #{plot_name}"
          item = { 
            campground_name: item_name, 
            directions_url: directions_url,
            campground_url: section_selection_url,
            booking_url: plot_selection_url, 
            description: text, 
            image: image 

          }.merge(details)
          items[campground_name] = item
          # End adding unique item
          logger.debug "Saving item #{item_name}..."
          save_to "results.json", item, format: :pretty_json

          browser.visit plot_selection_url
          browser.click_on 'LIST View'
        end
        visited_plot_names = []
        browser.visit section_selection_url
        browser.click_on 'LIST View'
      end
      visited_section_names = []
      browser.visit campground_selection_url
      browser.click_on 'LIST View'
    end
  end

  private

  def none_of_these_words_regexp(visited_names)
    return nil if visited_names.empty?
    logger.debug "Filtering out #{visited_names.join(", ")}"
    Regexp.new("^(?!.*(#{visited_names.join('|')})).*$")
  end

  def wait_until_breadcrumb_updated_to_display(name)
    # Wait until the deepest breadcrumb equals name
    browser.find(:css, "ol[aria-label='Search Result Breadcrumbs'] li button[disabled]", text: name, match: :first)
  end

  def show_and_hide_available_locations()
    unavailable_items = browser.all(:css, '.resource-availability', text: /Unavailable|Non-Reservable/, wait: 0.5)
    while unavailable_items.present?
      checkbox = browser.find(:css, '.mat-checkbox-label', text: /Show available .* only/, match: :first)
      checkbox.click
      sleep 0.5
      unavailable_items = browser.all(:css, '.resource-availability', text: /Unavailable|Non-Reservable/, wait: 0.5)
    end
  end

  def hide_covid_notice()
    covid_notice = browser.all(:css, '.mat-checkbox-label', text: "I have read and acknowledge all of the park alerts listed.", wait: 0.5)
    if covid_notice.present?
      checkbox = browser.find(:css, '.mat-checkbox-label', text: "I have read and acknowledge all of the park alerts listed.")
      checkbox.click
    end
  end

end

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    tr(" ", "_").
    downcase
  end
end

Campground.crawl!
