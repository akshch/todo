require 'csv'

class TicketsController < ApplicationController

  def index
    if request.format.csv?
      send_data to_csv, filename: "Tickets_#{Time.now.strftime('%d-%b-%Y_%I-%M')}.csv"
    else
      @tickets = Ticket.all
    end
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

  def process_csv
    current_user.documents.attach(params[:document])
    csv_data = current_user.documents.last.download
      CSV.parse(csv_data, headers: true) do |row|
        Ticket.create!(
          title: row['title'],
          description: row['description'],
          status: row['status'].to_i,
          user_id: current_user.id
        )
      end
      redirect_to tickets_path, notice: 'CSV data was successfully processed and inserted.'
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
    CSV.generate(headers: true) do |csv|
      csv << columns_caption
      Ticket.all.find_each do |item|
        csv << [item.id, item.title, item.description, item.status.titlecase, item.created_at.strftime('%Y/%m/%d')]
      end
    end
  end

  def ticket_params
    params.require(:ticket).permit(:title, :description)
  end
end
