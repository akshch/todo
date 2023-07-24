require 'csv'
class TicketsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]

  def index
    @tickets = Ticket.includes(:user, :comments).order('tickets.created_at desc')
  end

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(ticket_params)
    if @ticket.save
      flash[:notice] = "Ticket created successfully"
      redirect_to tickets_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @ticket.update(ticket_params)
      flash[:notice] = "Ticket updated successfully"
      redirect_to @ticket
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ticket.destroy
    flash[:notice] = "Ticket deleted successfully"
    redirect_to tickets_path, status: :see_other
  end

  def process_csv
    document = current_user.documents.attach(params[:document])
    if document
      FeedTicketWorker.perform_async(current_user.id)
      redirect_to tickets_path, notice: 'Pushed to sidekiq will take some time. Refresh after interval-base on no of Tickets'
    else
      render :index
    end
  end

  def set_status
    @ticket = Ticket.find_by(id: params[:id])
    if params[:remove].present?
      @ticket.in_progress!
    else
      @ticket.completed!
    end
  end

  def generate_csv_data
    columns_caption = ['Id', 'Title', 'Description', 'Status', 'Created At']
    csv_data = CSV.generate(headers: true) do |csv|
      csv << columns_caption
      Ticket.all.find_each do |item|
        csv << [item.id, item.title, item.description, item.status.titlecase, item.created_at.strftime('%Y/%m/%d')]
      end
    end
    current_user.documents.attach(io: StringIO.new(csv_data), filename: 'data.csv', content_type: 'text/csv')
    UserMailer.send_data_as_csv(current_user.id).deliver_now
    redirect_to tickets_path, notice: 'Attchement has been sent to you email'
  end

  private

  def ticket_params
    params.require(:ticket).permit(:title, :description, :user_id)
  end

  def set_ticket
    @ticket = Ticket.find_by(id: params[:id])
  end
end
