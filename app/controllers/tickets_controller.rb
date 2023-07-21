class TicketsController < ApplicationController

  def index
    @tickets = Ticket.all
  end

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(ticket_params)
    @ticket.user_id = current_user.id
    if @ticket.save
      flash[:notice] = "Ticket created successfully"
      redirect_to tickets_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @ticket = Ticket.find_by(id: params[:id])
  end

  def edit
    @ticket = Ticket.find_by(id: params[:id])
  end

  def update
    @ticket = Ticket.find_by(id: params[:id])
    if @ticket.update(ticket_params)
      flash[:notice] = "Ticket updated successfully"
      redirect_to @ticket
    else
      render :edit, status: unprocessable_entity
    end
  end

  def destroy
    @ticket = Ticket.find_by(id: params[:id])
    flash[:notice] = "Ticket deleted successfully"
    redirect_to tickets_path, status: :see_other
  end
  private

  def ticket_params
    params.require(:ticket).permit(:title, :description)
  end
end
