require 'csv'

class FeedTicketWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find_by(id: user_id)
    csv_data = user.documents.last.download
    CSV.parse(csv_data, headers: true) do |row|
      Ticket.create!(
        title: row['title'],
        description: row['description'],
        status: row['status'].to_i,
        user_id: user.id
      )
    end
  end
end
