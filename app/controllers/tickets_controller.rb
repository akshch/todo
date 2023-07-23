class TicketsController < ApplicationController

  before_action :authenticate_user!

  def index
    if request.format.csv?
      send_data to_csv
    else
      @tickets = Ticket.all
    end
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
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ticket = Ticket.find_by(id: params[:id])
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

  private

  def to_csv
    columns_caption = ['Id', 'Title', 'Description', 'Status', 'Created At']
    csv_data = CSV.generate(headers: true) do |csv|
      csv << columns_caption
      Ticket.all.find_each do |item|
        csv << [item.id, item.title, item.description, item.status.titlecase, item.created_at.strftime('%Y/%m/%d')]
      end
    end
    current_user.documents.attach(io: StringIO.new(csv_data), filename: 'data.csv', content_type: 'text/csv')
    UserMailer.send_data_as_csv(current_user.id).deliver_now
  end

  def ticket_params
    params.require(:ticket).permit(:title, :description, :user_id)
  end
end
