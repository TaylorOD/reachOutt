class Api::ReachoutsController < ApplicationController
  def index
    @reachouts = Reachout.all
    render "index.json.jb"
  end

  def create
    @reachout = Reachout.new(
      first_name: params[:first_name],
      last_name: params[:last_name],
      phone_number: params[:phone_number],
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
    @reachout.name = params[:name] || @reachout.name
    @reachout.width = params[:width] || @reachout.width
    @reachout.height = params[:height] || @reachout.height
    @reachout.save
    render "show.json.jb"
  end

  def destroy
    reachout = Reachout.find_by(id: params[:id])
    reachout.destroy
    render json: { message: "Reachout successfully destroyed." }
  end
end
