module ApplicationHelper

  def ticket_count(user)
    total_count = user.tickets.count
    total_count.positive? ? total_count : ''
  end
end
