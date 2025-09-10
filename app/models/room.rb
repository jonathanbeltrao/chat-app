class Room < ApplicationRecord
  has_many :messages, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  
  # Get or create the default general room
  def self.default_room
    find_or_create_by(name: "general") do |room|
      room.description = "General chat room for everyone"
    end
  end
end
