class NotificationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def notify
    # Use this code to send a text - can post it anywhere
    client = Twilio::REST::Client.new Rails.application.credentials.twilio_account_sid, Rails.application.credentials.twilio_auth_token
    message = client.messages.create from: '12014236603', to: '18025228145', body: 'Learning to send SMS you are.', media_url: 'https://cdn.wikimg.net/strategywiki/images/d/d6/Zelda_ALttP_Link.gif'
    # to is params and needs to be verfied
    # body params
    # to be added to the line above once the app is live and that url exists
    # , status_callback: request.base_url + '/twilio/status'
    # render plain: message.status
  end

end
