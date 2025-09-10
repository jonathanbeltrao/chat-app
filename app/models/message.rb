class Message < ApplicationRecord
  belongs_to :room
  
  validates :content, presence: true
  validates :username, presence: true
  
  scope :recent, -> { order(created_at: :asc) }
end
