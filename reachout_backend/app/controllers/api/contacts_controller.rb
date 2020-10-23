class Api::ContactsController < ApplicationController
  def index
    # @message = "hello!"
    # render json: { message: @message }
    @contacts = Contact.all
    render "index.json.jb"
  end

  def create
  end

  def show
    @contact = Contact.find_by(id: params[:id])
    render "show.json.jb"
  end

  def update
  end

  def destroy
  end
end
