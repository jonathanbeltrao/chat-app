class User < ApplicationRecord
  validates :username, presence: true, uniqueness: true, length: { maximum: 50 }
  
  # Scopes for finding users by online status
  scope :online, -> { where(is_online: true) }
  
  def self.mark_user_online(username)
    user = find_or_create_by(username: username)
    user.update(is_online: true)
    user
  end
  
  def self.mark_user_offline(username)
    user = find_by(username: username)
    if user
      user.update(is_online: false)
    end
    user
  end
  
  def self.get_online_users
    online.order(:username).pluck(:username)
  end
  
  def online?
    is_online
  end
  
  def mark_online!
    update(is_online: true)
  end
  
  def mark_offline!
    update(is_online: false)
  end
end

