class Api::ReachoutsController < ApplicationController

  # Show all reachouts action
  def index
    @reachouts = Reachout.all
    render "index.json.jb"
  end

  # Create a new reachout action
  def create
    @reachout = Reachout.new(
      user_id: current_user.id,
      start_date: params[:start_date],
      last_reachout_sent: params[:last_reachout_sent],
      frequency: params[:frequency],
      contact_id: params[:contact_id],
      datetime: params[:datetime],
    )
    if @reachout.save
      render "show.json.jb"
      client = Twilio::REST::Client.new Rails.application.credentials.twilio_account_sid, Rails.application.credentials.twilio_auth_token
      message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "Congrats! You created a new ReachOutt for #{@reachout.contact.first_name} #{@reachout.contact.last_name} starting on #{@reachout.start_date}. 
      ReachOutt will remind you to reachout to #{@reachout.contact.first_name} every #{@reachout.frequency}."
      s = Rufus::Scheduler.singleton
      s.every @reachout.frequency do
        puts "Reachout to #{@reachout.contact_id}"
        client = Twilio::REST::Client.new Rails.application.credentials.twilio_account_sid, Rails.application.credentials.twilio_auth_token
        message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "Hey! It's been #{@reachout.frequency}. Time to reachout to #{@reachout.contact.first_name} #{@reachout.contact.last_name} at #{@reachout.contact.phone_number}"  
      end
    else
      render json: { errors: @reachout.errors.full_messages }, status: :bad_request
    end
  end

  # Show a spesfic reachout action
  def show
    @reachout = Reachout.find_by(id: params[:id])
    render "show.json.jb"
  end

  # Update a reachout action
  def update
    @reachout = Reachout.find_by(id: params[:id])
    @reachout.start_date = params[:start_date] || @reachout.start_date
    @reachout.last_reachout_sent = params[:last_reachout_sent] || @reachout.last_reachout_sent
    @reachout.frequency = params[:frequency] || @reachout.frequency
    @reachout.contact_id = params[:contact_id] || @reachout.contact_id
    @reachout.datetime = params[:datetime] || @reachout.datetime
    if @reachout.save
      render "show.json.jb"
    else
      render json: { errors: @reachout.errors.full_messages }, status: :bad_request
    end
  end

  # Destroy a reachout action
  def destroy
    reachout = Reachout.find_by(id: params[:id])
    reachout.destroy
    render json: { message: "Reachout successfully destroyed." }
  end
end
