class User < ApplicationRecord
  # Include default devise modules. Others available are:
  #:lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :tickets
  has_many :comments
  has_many_attached :documents

  enum role: { developer: 0, sprint_master: 1, admin: 2 }
end
