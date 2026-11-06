class Api::ReachoutsController < ApplicationController
  before_action :authenticate_user

  def index
    @reachouts = current_user.reachouts.includes(:contact)
    render :index
  end

  def create
    contact = current_user.contacts.find_by(id: params[:contact_id])
    return render json: { error: "Contact not found" }, status: :not_found unless contact

    @reachout = Reachout.new(
      user_id: current_user.id,
      start_date: params[:start_date],
      frequency: params[:frequency],
      contact_id: params[:contact_id],
      datetime: params[:datetime],
      topic: params[:topic]
    )
    if @reachout.save
      render :show
    else
      render json: { errors: @reachout.errors.full_messages }, status: :bad_request
    end
  end

  def show
    @reachout = current_user.reachouts.find_by(id: params[:id])
    return render json: { error: "Reachout not found" }, status: :not_found unless @reachout

    render :show
  end

  def update
    @reachout = current_user.reachouts.find_by(id: params[:id])
    return render json: { error: "Reachout not found" }, status: :not_found unless @reachout

    if params[:contact_id] && !current_user.contacts.find_by(id: params[:contact_id])
      return render json: { error: "Contact not found" }, status: :not_found
    end

    @reachout.start_date = params[:start_date] || @reachout.start_date
    @reachout.frequency = params[:frequency] || @reachout.frequency
    @reachout.contact_id = params[:contact_id] || @reachout.contact_id
    @reachout.datetime = params[:datetime] || @reachout.datetime
    @reachout.topic = params[:topic] if params.key?(:topic)
    if @reachout.save
      render :show
    else
      render json: { errors: @reachout.errors.full_messages }, status: :bad_request
    end
  end

  def destroy
    reachout = current_user.reachouts.find_by(id: params[:id])
    return render json: { error: "Reachout not found" }, status: :not_found unless reachout

    reachout.destroy
    render json: { message: "Reachout successfully destroyed." }
  end

end
