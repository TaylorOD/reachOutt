require 'twilio-ruby'

class TwilioController < ApplicationController
  include Webhookable
  after_action :set_header
  skip_before_action :verify_authenticity_token

  def status
    # the status can be found in params['MessageStatus']
    # send back an empty response
    render_twiml Twilio::TwiML::MessagingResponse.new
  end
end
