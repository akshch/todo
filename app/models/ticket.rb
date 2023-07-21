class Ticket < ApplicationRecord
  belongs_to :user

  validates :title, :description, presence: true

  enum status: { in_progres: 0, completed: 2 }
end
