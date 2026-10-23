require "minitest/autorun"
require "twilio-ruby"

module Webhookable
end

class ApplicationController
  def self.before_action(*args)
    (@before_actions ||= []) << args
  end
  def self.before_actions
    @before_actions || []
  end
  def self.after_action(*); end
  def self.skip_before_action(*); end

  attr_accessor :request
  attr_reader :rendered

  def render(**options)
    @rendered = options
  end
end

module Rails
  CredentialStub = Struct.new(:twilio_auth_token)
  ApplicationStub = Struct.new(:credentials)
  class << self
    attr_accessor :application
  end
end

load File.expand_path("../../app/controllers/twilio_controller.rb", __dir__)

class TwilioWebhookSecurityTest < Minitest::Test
  URL = "https://api.example.test/api/twilio/status?source=callback"
  FORM = { "MessageSid" => "SM1234", "MessageStatus" => "delivered" }
  TOKEN = "test-token-not-a-real-credential"
  RequestStub = Struct.new(:headers, :original_url, :request_parameters)

  def setup
    Rails.application = Rails::ApplicationStub.new(Rails::CredentialStub.new(TOKEN))
    @validator = Twilio::Security::RequestValidator.new(TOKEN)
  end

  def signature(url = URL, params = FORM)
    @validator.build_signature_for(url, params)
  end

  def verify(signature_value, url: URL, params: FORM)
    controller = TwilioController.new
    controller.request = RequestStub.new({ "X-Twilio-Signature" => signature_value }, url, params)
    controller.send(:validate_twilio_signature)
    controller.rendered
  end

  def assert_forbidden(result)
    assert_equal :forbidden, result[:status]
    assert_equal({ error: "Invalid Twilio signature" }, result[:json])
  end

  def test_valid_signed_twilio_form_is_accepted
    assert_nil verify(signature)
  end

  def test_missing_signature_is_rejected
    assert_forbidden verify(nil)
  end

  def test_empty_signature_is_rejected
    assert_forbidden verify("")
  end

  def test_forged_signature_is_rejected
    assert_forbidden verify("forged")
  end

  def test_modified_request_parameters_are_rejected
    assert_forbidden verify(signature, params: FORM.merge("MessageStatus" => "failed"))
  end

  def test_modified_callback_url_is_rejected
    assert_forbidden verify(signature, url: URL + "&spoof=true")
  end

  def test_missing_auth_token_fails_closed
    Rails.application.credentials.twilio_auth_token = nil
    assert_forbidden verify(signature)
  end

  def test_malformed_url_fails_closed
    assert_forbidden verify(signature, url: "not a valid URL")
  end

  def test_validation_is_required_for_both_twilio_actions
    assert_includes TwilioController.before_actions, [:validate_twilio_signature, { only: [:status, :voice] }]
  end
end
