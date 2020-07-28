# campground.rb
require 'kimurai'

class Campground < Kimurai::Base
  @name = "campground"
  @engine = :selenium_chrome
  @start_urls = ["https://washington.goingtocamp.com/create-booking/results?mapId=-2147483346&searchTabGroupId=0&bookingCategoryId=0&startDate=2020-08-01T00:00:00.000Z&endDate=2020-08-02T00:00:00.000Z&nights=1&isReserving=true&equipmentId=-32768&subEquipmentId=-32768&partySize=2&searchTime=Mon%20Jul%2027%202020%2017:36:28%20GMT-0700%20(Pacific%20Daylight%20Time)&resourceLocationId=-2147483538"]

  def wait_until_breadcrumb_updated_to_display(name)
    # Wait until the deepest breadcrumb equals name
    browser.find(:css, "ol[aria-label='Search Result Breadcrumbs'] li button[disabled]", text: name, match: :first)
  end

  def show_and_hide_available_locations()
    unavailable_items = browser.all(:css, '.resource-availability', text: /Unavailable|Non-Reservable/)
    while unavailable_items.present?
      checkbox = browser.find(:css, '.mat-checkbox-label', text: /Show available .* only/, match: :first)
      checkbox.click
      sleep 0.5
      unavailable_items = browser.all(:css, '.resource-availability', text: /Unavailable|Non-Reservable/, wait: 0.5)
    end
  end

  def parse(response, url:, data: {})
    browser.click_on 'I Consent'
    response = browser.current_response
    # available_campgrounds = browser.find(:css, '.available', match: :first)
    # available_campgrounds.map { |camp| camp['id'] }
    # available_campgrounds.each do |campground|
    #   campground.click
    # end

    browser.click_on 'LIST View'
    # browser.find(:css, 'div#map .available', match: :first).click

    campground_name = browser.find(:css, '.resource-name div', match: :first).text
    # TODO: Grab number of campgrounds below
    browser.find(:css, "[aria-controls=site-details] .icon-available", match: :first).click

    wait_until_breadcrumb_updated_to_display(campground_name)
    show_and_hide_available_locations
    # Click on campground section
    section_name = browser.find(:css, '.resource-name div', match: :first).text
    browser.find(:css, "[aria-controls=site-details] .icon-available", match: :first).click
    wait_until_breadcrumb_updated_to_display(section_name)
    show_and_hide_available_locations

    # Click on campground plot for details
    plot_name = browser.find(:css, '.resource-name div', match: :first).text
    browser.find(:css, "[aria-controls=site-details] .icon-available", match: :first).click
    
    # Gather details
    text = browser.find(:css, '.view-details', match: :first).text
    
    image = browser.find(:css, '.site-image', match: :first)['src']
    i = 0
    details = {}
    more_details = browser.all(:css, '.more-details div div')
    while (i < more_details.size) do
      value = more_details[i].text 
      key = more_details[i+1].text
      value.gsub!(key, "")
      details[key] = value
      i+=2
    end
    item = { campground_name: "#{campground_name} > #{section_name} > #{plot_name}", description: text, image: image }.merge(details)

    save_to "results.json", item, format: :pretty_json
  end
end

Campground.crawl!
