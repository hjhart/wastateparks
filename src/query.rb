# frozen_string_literal: true

# campground.rb
require 'fileutils'
require_relative './notifier'
require 'byebug'
require 'dotenv/load'

class Campground < Kimurai::Base
  DEFAULT_WAIT_TIME = 10
  attr_accessor :filtered_campground_names, :visited_section_names, :visited_plot_names

  @name = 'campground'
  @engine = :selenium_chrome
  @start_date = '2020-08-29T00:00:00.000Z'
  @end_date = '2020-08-30T00:00:00.000Z'
  party_size = 2

  params = {
    'mapId' => -2_147_483_346,
    'searchTabGroupId' => 0,
    'bookingCategoryId' => 0,
    'startDate' => @start_date,
    'endDate' => @end_date,
    'isReserving' => true,
    'equipmentId' => -32_768,
    'subEquipmentId' => -32_768, # 1 tent
    # "subEquipmentId" => -32767, # 2 tent
    'partySize' => party_size,
    'resourceLocationId' => '-2147483538'
  }
  start_url = URI::HTTPS.build(host: 'washington.goingtocamp.com', path: '/create-booking/results',
                               query: params.to_query)
  @start_urls = [start_url.to_s]

  def parse(_response, url:, data: {})
    time = Time.now.iso8601
    filename = "results/results-#{time}.json"
    browser.click_on 'I Consent'
    response = browser.current_response

    campgrounds_too_far_away = ['Camano Island​', 'Kitsap Memorial​', 'Larrabee​', 'South Whidbey​', 'Twanoh',
                                'Deception Pass', 'Retreat Center - Cornet Bay​', 'Potlatch​', 'Rasar​', 'Fort Ebey​', 'Schafer', 'Rockport​', 'Birch Bay', 'Fort Townsend', 'Lake Wenatchee​', 'Peace Arch', 'Sequim Bay​', 'Retreat Center - Ramblewood​', 'Fort Casey​', 'Fort Worden​', 'Dosewallups', 'Ocean City​', 'Retreat Center - Fort Flagler​', 'Jarrel Cove', 'Pacific Beach​', 'Spencer Spit​', 'Griffiths-Priday​', 'Jones Island​', 'Moran​', 'Retreat Center - Camp Moran​', 'Bogachiel', 'Sucia Island​', 'Posey Island​', 'Blake Island']
    filtered_campground_names = []
    visited_section_names = []
    visited_plot_names = []

    items = []
    select_list_view
    while browser.all(:css, '.resource-name div', text: none_of_these_words_regexp(filtered_campground_names),
                                                  wait: DEFAULT_WAIT_TIME).present?
      # Click on campground
      campground_selection_url = browser.current_url
      campground_element = browser.all(:css, '.resource-name div',
                                       text: none_of_these_words_regexp(filtered_campground_names)).first
      logger.info "Found element with html #{campground_element['innerHTML']}"
      campground_name = campground_element.text
      break if campground_name.blank?

      if campgrounds_too_far_away.include? campground_name.strip
        logger.info "Skipping '#{campground_name}', too far away..."
        filtered_campground_names << campground_name
        break
      end
      filtered_campground_names << campground_name
      campground_element.click

      wait_until_breadcrumb_updated_to_display(campground_name)
      show_and_hide_available_locations

      while browser.all(:css, '.resource-name div', text: none_of_these_words_regexp(visited_section_names),
                                                    wait: DEFAULT_WAIT_TIME).present?
        # Click on campground section
        section_selection_url = browser.current_url
        section_element = browser.all(:css, '.resource-name div',
                                      text: none_of_these_words_regexp(visited_section_names)).first
        logger.info "Found element with html #{section_element['innerHTML']}"
        section_name = section_element.text
        break if section_name.blank?

        visited_section_names << section_name
        section_element.click

        wait_until_breadcrumb_updated_to_display(section_name)
        show_and_hide_available_locations

        while browser.all(:css, '.resource-name div', text: none_of_these_words_regexp(visited_plot_names),
                                                      wait: DEFAULT_WAIT_TIME).present?
          # Click on campground plot for details
          plot_selection_url = browser.current_url
          plot_element = browser.all(:css, '.resource-name div',
                                     text: none_of_these_words_regexp(visited_plot_names)).first
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
          logger.debug 'Grabbing details'
          text = browser.find(:css, '.view-details', match: :first).text

          logger.debug 'Grabbing image'
          image = browser.find(:css, '.site-image', match: :first)['src']
          i = 0
          details = {}
          logger.debug 'Grabbing more details...'
          more_details = browser.all(:css, '.more-details div div')
          while i < more_details.size
            value = more_details[i].text
            key = more_details[i + 1].text
            value.gsub!(key, '')
            details[key.underscore] = value.strip
            i += 2
          end
          directions_url = URI::HTTPS.build(host: 'maps.google.com', path: '/maps',
                                            query: { saddr: '1911 18th ave s 98144', daddr: "#{campground_name} state park" }.to_query)
          item_name = "#{campground_name} > #{section_name} > #{plot_name}"
          item = {
            campground_name: item_name,
            directions_url: directions_url,
            campground_url: section_selection_url,
            booking_url: plot_selection_url,
            description: text,
            image: image
          }.merge(details)

          if details['ada_only'] == 'Yes'
            logger.info "Skipping #{item_name}, ADA only."
          else
            # End adding unique item
            logger.debug "Saving item #{item_name}..."
            begin
              Notifier.send(item)
            rescue Twilio::REST::RestError => e
              Notifier.failure(e)
              byebug if ENV.fetch('HEADLESS', true) == 'false'
            end
            save_to filename, item, format: :pretty_json
            items << item
          end

          browser.visit plot_selection_url
          select_list_view
        end
        visited_plot_names = []
        browser.visit section_selection_url.gsub(/&searchTime=.*$/, '')
        select_list_view
      end
      visited_section_names = []
      browser.visit campground_selection_url
      select_list_view
    end
    if items.size.positive?
      logger.info "Saved file successfully #{filename}"
      FileUtils.ln_sf(filename, 'results.json')
    else
      logger.warn 'No campgrounds available. Saving no file.'
    end
  end

  private

  def none_of_these_words_regexp(visited_names)
    return nil if visited_names.empty?

    logger.debug "Filtering out #{visited_names.join(', ')}"
    Regexp.new("^(?!.*(#{visited_names.join('|')})).*$")
  end

  def wait_until_breadcrumb_updated_to_display(name)
    # Wait until the deepest breadcrumb equals name

    browser.find(:css, "ol[aria-label='Search Result Breadcrumbs'] li button[disabled]", text: name, match: :first,
                                                                                         wait: 3)
  rescue Capybara::ElementNotFound => e
    Notifier.failure(e)
    byebug if ENV.fetch('HEADLESS', true) == 'false'
  end

  def show_and_hide_available_locations
    unavailable_items = browser.all(:css, '.resource-availability', text: /Unavailable|Non-Reservable/, wait: 0.5)
    while unavailable_items.present?
      checkbox = browser.find(:css, '.mat-checkbox-label', text: /Show available .* only/, match: :first)
      checkbox.click
      sleep 0.5
      unavailable_items = browser.all(:css, '.resource-availability', text: /Unavailable|Non-Reservable/, wait: 0.5)
    end
  end

  def hide_covid_notice
    covid_notice = browser.all(:css, '.mat-checkbox-label',
                               text: 'I have read and acknowledge all of the park alerts listed.', wait: 0.5)
    if covid_notice.present?
      checkbox = browser.find(:css, '.mat-checkbox-label',
                              text: 'I have read and acknowledge all of the park alerts listed.')
      checkbox.click
    end
  end

  def select_list_view
    list_view_button = browser.all(:css, '.mat-button-toggle-button', text: 'LIST View', wait: 1.5)
    browser.click_on 'LIST View'
  rescue Capybara::ElementNotFound => e
    logger.warn "Unable to find 'List View' button"
  end
end

class String
  def underscore
    gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .tr(' ', '_')
      .downcase
  end
end

Campground.crawl!
