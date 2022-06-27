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
    Pushover::Message.new(token: ENV['PUSHOVER_TOKEN'], user: ENV['PUSHOVER_USER'], message: result.message).push
  end
end