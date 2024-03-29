class Api::ReachoutsController < ApplicationController
  # Retrieves all reachouts associated with the current user.
  #
  # Returns:
  # - @reachouts: An array of reachouts belonging to the current user.
  def index
    @reachouts = current_user.reachouts
    render :index
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
        render :show
        # Creates our Twilio request via their API and Rails
        client = Twilio::REST::Client.new Rails.application.credentials.twilio_account_sid, Rails.application.credentials.twilio_auth_token

        # Sends text to user who created a new ReachOutt to let them know their creation was successful
        message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "#{@reachout.user.first_name} - You created a new ReachOutt for #{@reachout.contact.first_name} #{@reachout.contact.last_name} which starts on #{@reachout.start_date}.
        ReachOutt will remind you to get in touch with #{@reachout.contact.first_name} #{@reachout.friendly_frequency(@reachout.frequency)}."

        # Checks if reachout has a topic and if so gives a topic-based reachout suggestion - testing code. Only sent on reachout frequency texts
        topic_response = @reachout.get_topic_data
        if topic_response
          message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "Hey #{@reachout.user.first_name}! You and #{@reachout.contact.first_name} both like #{@reachout.topic}.
      #{@reachout.get_topic_data}"
        end

        # Create Rufus (cron) job to send a reminder text to reach out every frequency
        s = Rufus::Scheduler.singleton

        # Sets reminder text to the frequency that the user inputted
        s.every @reachout.frequency do
          # Twilio call with their API and Rails
          client = Twilio::REST::Client.new Rails.application.credentials.twilio_account_sid, Rails.application.credentials.twilio_auth_token
          # ReachOutt reminder text code
          message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "Hey #{@reachout.user.first_name}! ReachOutt here. Time to reachout to #{@reachout.contact.first_name} #{@reachout.contact.last_name}  at #{@reachout.contact.phone_number}."

          # Checks if reachout has a topic and if so gives a topic based reachout suggestion
          topic_response = @reachout.get_topic_data
          if topic_response
            message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "Hey #{@reachout.user.first_name}! You and #{@reachout.contact.first_name} both like #{@reachout.topic}.#{@reachout.get_topic_data}."
          end
        end
    else
      render json: { errors: @reachout.errors.full_messages }, status: :bad_request
    end
  end

  # Show a specific reachout action
  def show
    @reachout = Reachout.find_by(id: params[:id])
    render :show
  end

  # Updates a reachout record with the provided parameters
  #
  # Params:
  # - id: The ID of the reachout record to update
  # - start_date: The new start date for the reachout
  # - last_reachout_sent: The new last reachout sent date for the reachout
  # - frequency: The new frequency for the reachout
  # - contact_id: The new contact ID for the reachout
  # - datetime: The new datetime for the reachout
  #
  # Returns:
  # - If the reachout is successfully updated, renders the updated reachout as JSON
  # - If there are errors in updating the reachout, renders the error messages as JSON with a bad request status
  def update
    @reachout = Reachout.find_by(id: params[:id])
    @reachout.start_date = params[:start_date] || @reachout.start_date
    @reachout.last_reachout_sent = params[:last_reachout_sent] || @reachout.last_reachout_sent
    @reachout.frequency = params[:frequency] || @reachout.frequency
    @reachout.contact_id = params[:contact_id] || @reachout.contact_id
    @reachout.datetime = params[:datetime] || @reachout.datetime
    if @reachout.save
      render :show
      # Creates our Twilio request via their API and Rails
      client = Twilio::REST::Client.new Rails.application.credentials.twilio_account_sid, Rails.application.credentials.twilio_auth_token
      # Sends text to user who created a new ReachOutt to let them know their creation was successful 
      message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "You updated your ReachOutt for #{@reachout.contact.first_name} #{@reachout.contact.last_name}. ReachOutt will remind you to reach out to #{@reachout.contact.first_name} #{@reachout.friendly_frequency(@reachout.frequency)}."

      # Create Rufus (cron) job to send a reminder text to reach out every frequency
      s = Rufus::Scheduler.singleton
      # Sets reminder text to the frequency that the user inputted
      s.every @reachout.frequency do

        # Twilio call with their API and Rails
        client = Twilio::REST::Client.new Rails.application.credentials.twilio_account_sid, Rails.application.credentials.twilio_auth_token
        # ReachOutt reminder text code
        message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "Hey! It's been #{@reachout.friendly_frequency(@reachout.frequency)}. Time to reach out to #{@reachout.contact.first_name} #{@reachout.contact.last_name}"

        # Checks if reachout has a topic and if so gives a topic based reachout suggestion
        topic_response = @reachout.get_topic_data
        if topic_response
          message = client.messages.create from: '12014236603', to: "#{@reachout.user.phone_number}", body: "Hey #{@reachout.user.first_name}! You and #{@reachout.contact.first_name} both like #{@reachout.topic}.#{@reachout.get_topic_data}"
        end
      end
    else
      render json: { errors: @reachout.errors.full_messages }, status: :bad_request
    end
  end

  # Deletes a reachout record from the database.
  #
  # Parameters:
  #   - id: The ID of the reachout record to be deleted.
  #
  # Returns:
  #   A JSON response with a success message indicating that the reachout record has been successfully destroyed.
  def destroy
    reachout = Reachout.find_by(id: params[:id])
    reachout.destroy
    render json: { message: "Reachout successfully destroyed." }
  end

end
