require 'twilio-ruby'

class TwilioController < ApplicationController
  include Webhookable
  after_action :set_header
  skip_before_action :verify_authenticity_token
  before_action :validate_twilio_signature, only: [:status, :voice]

  def status
    # the status can be found in params['MessageStatus']
    # send back an empty response
    render_twiml Twilio::TwiML::MessagingResponse.new
  end

  private

  def validate_twilio_signature
    signature = request.headers["X-Twilio-Signature"]
    auth_token = Rails.application.credentials.twilio_auth_token

    valid = signature.is_a?(String) && !signature.empty? &&
      auth_token.is_a?(String) && !auth_token.empty? &&
      Twilio::Security::RequestValidator.new(auth_token).validate(
        request.original_url,
        request.request_parameters,
        signature
      )

    render json: { error: "Invalid Twilio signature" }, status: :forbidden unless valid
  rescue URI::InvalidURIError, ArgumentError, TypeError
    render json: { error: "Invalid Twilio signature" }, status: :forbidden
  end
end
