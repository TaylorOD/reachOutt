class NotificationsController < ApplicationController

  skip_before_action :verify_authenticity_token

  def notify
    client = Twilio::REST::Client.new Rails.application.credentials.twilio_account_sid, Rails.application.credentials.twilio_auth_token
    message = client.messages.create from: '12014236603', to: '18025228145', body: 'Learning to send SMS you are.', media_url: 'https://cdn.wikimg.net/strategywiki/images/d/d6/Zelda_ALttP_Link.gif'
    # render plain: message.status
  end

end