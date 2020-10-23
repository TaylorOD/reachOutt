class Api::ContactsController < ApplicationController
  def index
    @contacts = Contact.all
    render "index.json.jb"
  end

  def create
    @contact = Contact.new(
      first_name: params[:first_name],
      last_name: params[:last_name],
      phone_number: params[:phone_number],
      # user_id: params[:user_id],
    )
    @contact.save
    render "show.json.jb"
  end

  def show
    @contact = Contact.find_by(id: params[:id])
    render "show.json.jb"
  end

  def update
  end

  def destroy
    contact = Contact.find_by(id: params[:id])
    contact.destroy
    render json: { message: "Contact successfully destroyed." }
  end
end
