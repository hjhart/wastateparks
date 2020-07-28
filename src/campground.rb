# campground.rb
require 'kimurai'

class Campground < Kimurai::Base
  @name = "campground"
  @engine = :selenium_chrome
  @start_urls = ["https://washington.goingtocamp.com/create-booking/results?mapId=-2147483346&searchTabGroupId=0&bookingCategoryId=0&startDate=2020-08-01T00:00:00.000Z&endDate=2020-08-02T00:00:00.000Z&nights=1&isReserving=true&equipmentId=-32768&subEquipmentId=-32768&partySize=2&searchTime=Mon%20Jul%2027%202020%2017:36:28%20GMT-0700%20(Pacific%20Daylight%20Time)&resourceLocationId=-2147483538"]

  def parse(response, url:, data: {})
    browser.click_on 'I Consent'
    response = browser.current_response
    # available_campgrounds = browser.find(:css, '.available', match: :first)
    # available_campgrounds.map { |camp| camp['id'] }
    # available_campgrounds.each do |campground|
    #   campground.click
    # end

    # require 'pry'
    # binding.pry
    browser.click_on 'LIST View'
    # browser.find(:css, 'div#map .available', match: :first).click

    name = browser.find(:css, '.resource-name div', match: :first).text
    browser.find(:css, "[aria-controls=site-details] .icon-available", match: :first).click

    # Click on campground section
    browser.find(:css, "[aria-controls=site-details] .icon-available", match: :first).click
  
    # Click on campground plot for details
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
    item = { name: name, description: text, image: image }.merge(details)

    save_to "results.json", item, format: :pretty_json
  end
end

Campground.crawl!
