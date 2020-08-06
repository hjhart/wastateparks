require 'twilio-ruby'

class Notifier
  def self.send(campground)
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    client = Twilio::REST::Client.new(account_sid, auth_token)
    
    from = ENV['TWILIO_FROM_NUMBER'] # Your Twilio number
    to = '+12063690978' # Your mobile phone number
    
    message = campground.slice(:campground_name, :campground_url, :booking_url, "privacy", "fee_level", "pets_allowed", "tent_areas", "site_length", "site_width", "conditions")
    media_hash = campground[:image].present? ? {media_url: campground[:image] } : {}
    client.messages.create({
      from: from,
      to: to,
      body: JSON.pretty_generate(message)
    }.merge(media_hash))
  end

  def self.failure(error)
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    client = Twilio::REST::Client.new(account_sid, auth_token)
    
    from = ENV['TWILIO_FROM_NUMBER'] # Your Twilio number
    to = '+12063690978' # Your mobile phone number
    
    client.messages.create(
      from: from,
      to: to,
      body: "Your scraper is broken! #{error.message}",
    )
  end
end
