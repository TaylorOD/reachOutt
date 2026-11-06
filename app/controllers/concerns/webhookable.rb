module Webhookable
  extend ActiveSupport::Concern

  def set_header
    response.headers['Content-Type'] = 'text/xml' if response.successful?
  end

  def render_twiml(message)
    render xml: message.to_s
  end
end
