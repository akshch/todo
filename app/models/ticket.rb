class Ticket < ApplicationRecord
  belongs_to :user
  has_many :comments

  validates :title, :description, presence: true

  enum status: { in_progres: 0, completed: 2 }
end
