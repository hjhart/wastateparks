# frozen_string_literal: true

class Notification
  include Logging
  include Storage
  attr_reader :result

  def initialize(result)
    @result = result
  end

  def self.from_result(result)
    new(result)
  end

  def send!
    guid = result.guid.join("-")
    if storage.already_sent_notification_for_guid?(guid)
      logger.debug "Notification already sent for #{guid}"
    else
      logger.info "Sending notification for #{guid}"
      send_notification
      storage.mark_guid_as_sent(guid)
    end
  end

  def send_notification
    client = Rushover::Client.new(ENV['PUSHOVER_TOKEN'])
    resp = client.notify(ENV['PUSHOVER_USER'], message, title: result.message, html: 1, url: result.url)
    if resp.ok?
      logger.info "Successfully notified user"
    end
  end

  private

  def message
    result.data.map { |key, value| "<b>#{key}</b>: #{value}" }.join('<br>')
  end
end