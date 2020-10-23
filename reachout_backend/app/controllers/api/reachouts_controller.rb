class Api::ReachoutsController < ApplicationController
  def index
    @reachouts = Reachout.all
    render "index.json.jb"
  end

  def create
    @reachout = Reachout.new(
      start_date: params[:start_date],
      last_reachout_sent: params[:last_reachout_sent],
      frequency: params[:frequency],
      contact_id: params[:contact_id],
      datetime: params[:datetime],
    )
    @reachout.save
    render "show.json.jb"
  end

  def show
    @reachout = Reachout.find_by(id: params[:id])
    render "show.json.jb"
  end

  def update
    @reachout = Reachout.find_by(id: params[:id])
    @reachout.start_date = params[:start_date] || @reachout.start_date
    @reachout.last_reachout_sent = params[:last_reachout_sent] || @reachout.last_reachout_sent
    @reachout.frequency = params[:frequency] || @reachout.frequency
    @reachout.contact_id = params[:contact_id] || @reachout.contact_id
    @reachout.datetime = params[:datetime] || @reachout.datetime
    @reachout.save
    render "show.json.jb"
  end

  def destroy
    reachout = Reachout.find_by(id: params[:id])
    reachout.destroy
    render json: { message: "Reachout successfully destroyed." }
  end
end
