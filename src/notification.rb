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
    if storage.already_sent_notification_for_guid?(result.guid)
      logger.debug "Notification already sent for #{result.guid}"
    else
      logger.info "Sending notification for #{result.guid}"
      send_notification
      storage.mark_guid_as_sent(result.guid)
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
    result.data.map { |key, value| "<b>#{key}</b>: #{value}" }.join('\n')
  end
end