require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "readiness checks the database without authentication" do
    get "/health/ready"
    assert_response :ok
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_equal({ "status" => "ok" }, response.parsed_body)
  end

  test "database failures return an unavailable response without private details" do
    pool = ActiveRecord::Base.connection_pool
    pool.stub(:with_connection, ->(*) { raise ActiveRecord::ConnectionNotEstablished, "private connection details" }) do
      get "/health/ready"
    end
    assert_response :service_unavailable
    assert_equal({ "status" => "unavailable" }, response.parsed_body)
  end
end
