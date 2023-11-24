class Api::ContactsController < ApplicationController
  before_action :authenticate_user

  # Show all contacts action
  def index
    @contacts = current_user.contacts
    render "index.json.jb"
  end

  # Create a new contact action
  def create
    @contact = Contact.new(
      user_id: current_user.id,
      first_name: params[:first_name],
      last_name: params[:last_name],
      phone_number: params[:phone_number],
    )
    if @contact.save
      render "show.json.jb"
    else
      render json: { errors: @contact.errors.full_messages }, status: :bad_request
    end
  end

  # Show a specific contact action
  def show
    @contact = Contact.find_by(id: params[:id])
    render "show.json.jb"
  end

  # Update a contact action
  def update
    @contact = Contact.find_by(id: params[:id])
    @contact.first_name = params[:first_name] || @contact.first_name
    @contact.last_name = params[:last_name] || @contact.last_name
    @contact.phone_number = params[:phone_number] || @contact.phone_number
    if @contact.save
      render "show.json.jb"
    else
      render json: { errors: @contact.errors.full_messages }, status: :bad_request
    end
  end

  # Destroy a contact action
  def destroy
    contact = Contact.find_by(id: params[:id])
    contact.destroy
    render json: { message: "Contact successfully destroyed." }
  end
end
