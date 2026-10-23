require "minitest/autorun"

class DisabledTestSmsEndpointTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)

  def test_unprotected_sms_route_has_been_removed
    routes = File.read(File.join(ROOT, "config/routes.rb"))
    refute_match(/notifications\/notify/, routes)
    refute_match(/notifications#notify/, routes)
  end

  def test_legacy_controller_cannot_send_sms
    refute File.exist?(File.join(ROOT, "app/controllers/notifications_controller.rb"))
  end

  def test_signed_twilio_callbacks_remain_available
    routes = File.read(File.join(ROOT, "config/routes.rb"))
    assert_includes routes, "'twilio/status' => 'twilio#status'"
    controller = File.read(File.join(ROOT, "app/controllers/twilio_controller.rb"))
    assert_includes controller, "before_action :validate_twilio_signature"
  end
end
