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
      topic: params[:topic]
    )
    if @reachout.save
      render "show.json.jb"
      # Creates our Twilio request via their API and Rails
      client = Twilio::REST::Client.new Rails.application.credentials.twilio_account_sid, Rails.application.credentials.twilio_auth_token

      # Sends text to user who created a new ReachOutt to let them know their creation was sucsessful 
      message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "#{@reachout.user.first_name} - You created a new ReachOutt for #{@reachout.contact.first_name} #{@reachout.contact.last_name} which starts on #{@reachout.start_date}.
ReachOutt will remind you to get in touch with #{@reachout.contact.first_name} #{@reachout.friendly_frequency(@reachout.frequency)}."
      
      # Checks if reachout has a topic and if so gives a topic based reachout sudgestion - testing code. Only sent on reachout frequency texts
#       topic_response = @reachout.get_topic_data
#       if topic_response
#         message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "Hey #{@reachout.user.first_name}! You and #{@reachout.contact.first_name} both like #{@reachout.topic}.
# #{@reachout.get_topic_data}"
#       end

      # Create Rufus (cron) job to send a reminder text to reachout every frequency
      s = Rufus::Scheduler.singleton

      # Sets reminder text to the fequency that the user inputed
      s.every @reachout.frequency do
        # Twilio call with their API and Rails
        client = Twilio::REST::Client.new Rails.application.credentials.twilio_account_sid, Rails.application.credentials.twilio_auth_token
        # ReachOutt reminder text code
        message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "Hey #{@reachout.user.first_name}! ReachOutt here. Time to reachout to #{@reachout.contact.first_name} #{@reachout.contact.last_name} at #{@reachout.contact.phone_number}"

        # Checks if reachout has a topic and if so gives a topic based reachout sudgestion
        topic_response = @reachout.get_topic_data
        if topic_response
          message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "Hey #{@reachout.user.first_name}! You and #{@reachout.contact.first_name} both like #{@reachout.topic}.
#{@reachout.get_topic_data}"
        end
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
      # Creates our Twilio request via their API and Rails
      client = Twilio::REST::Client.new Rails.application.credentials.twilio_account_sid, Rails.application.credentials.twilio_auth_token
      # Sends text to user who created a new ReachOutt to let them know their creation was sucsessful 
      message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "You updated your ReachOutt for #{@reachout.contact.first_name} #{@reachout.contact.last_name}. 
ReachOutt will remind you to reachout to #{@reachout.contact.first_name} #{@reachout.friendly_frequency(@reachout.frequency)}."
      # Create Rufus (cron) job to send a reminder text to reachout every frequency
      s = Rufus::Scheduler.singleton
      # Sets reminder text to the fequency that the user inputed
      s.every @reachout.frequency do

        # Twilio call with their API and Rails
        client = Twilio::REST::Client.new Rails.application.credentials.twilio_account_sid, Rails.application.credentials.twilio_auth_token
        # ReachOutt reminder text code
        message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "Hey! It's been #{@reachout.friendly_frequency(@reachout.frequency)}. Time to reachout to #{@reachout.contact.first_name} #{@reachout.contact.last_name} at #{@reachout.contact.phone_number}"  
        # Checks if reachout has a topic and if so gives a topic based reachout sudgestion
        topic_response = @reachout.get_topic_data
        if topic_response
          message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "Hey #{@reachout.user.first_name}! You and #{@reachout.contact.first_name} both like #{@reachout.topic}.
#{@reachout.get_topic_data}"
        end
      end
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
