class Api::ContactsController < ApplicationController
  before_action :authenticate_user

  # Show all contacts action
  def index
    @contacts = current_user.contacts
    render :index
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
      render :show
    else
      render json: { errors: @contact.errors.full_messages }, status: :bad_request
    end
  end

  # Show a specific contact action
  def show
    @contact = current_user.contacts.find_by(id: params[:id])
    return render json: { error: "Contact not found" }, status: :not_found unless @contact

    render :show
  end

  # Update a contact action
  def update
    @contact = current_user.contacts.find_by(id: params[:id])
    return render json: { error: "Contact not found" }, status: :not_found unless @contact

    @contact.first_name = params[:first_name] || @contact.first_name
    @contact.last_name = params[:last_name] || @contact.last_name
    @contact.phone_number = params[:phone_number] || @contact.phone_number
    if @contact.save
      render :show
    else
      render json: { errors: @contact.errors.full_messages }, status: :bad_request
    end
  end

  # Destroy a contact action
  def destroy
    contact = current_user.contacts.find_by(id: params[:id])
    return render json: { error: "Contact not found" }, status: :not_found unless contact

    contact.destroy
    render json: { message: "Contact successfully destroyed." }
  end
end
