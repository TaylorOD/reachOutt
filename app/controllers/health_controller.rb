class HealthController < ActionController::API
  def ready
    response.headers["Cache-Control"] = "no-store"
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      connection.select_value("SELECT 1")
    end
    render json: { status: "ok" }
  rescue ActiveRecord::ActiveRecordError, PG::Error
    render json: { status: "unavailable" }, status: :service_unavailable
  end
end
