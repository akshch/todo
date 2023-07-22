class Ticket < ApplicationRecord
  belongs_to :user
  has_many :comments

  validates :title, :description, presence: true

  enum status: { in_progress: 0, completed: 1 }
end
