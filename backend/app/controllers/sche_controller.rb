class ScheController < ApplicationController
   # GET /sche/
  #
  def index

    job_id =
      Rufus::Scheduler.singleton.in '5s' do
        Rails.logger.info "time flies, it's now #{Time.now}"
      end

    render :text => "scheduled job #{job_id}"
  end
end
