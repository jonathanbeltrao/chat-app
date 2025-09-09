class User < ApplicationRecord
  validates :username, presence: true, uniqueness: true, length: { maximum: 50 }
  
  # Scopes for finding users
  scope :online, -> { where(is_online: true) }
  scope :typing, -> { where(is_typing: true) }
  scope :online_and_typing, -> { online.typing }
  
  # Class methods for user management
  def self.mark_user_online(username)
    user = find_or_create_by(username: username)
    user.update(is_online: true)
    user
  end
  
  def self.mark_user_offline(username)
    user = find_by(username: username)
    if user
      user.update(is_online: false, is_typing: false)
    end
    user
  end
  
  def self.mark_user_typing(username, typing = true)
    user = find_or_create_by(username: username)
    user.update(
      is_typing: typing,
      is_online: true # Ensure they're marked online when typing
    )
    user
  end
  
  
  def self.get_online_users
    online.order(:username).pluck(:username)
  end
  
  def self.get_typing_users
    online_and_typing.order(:username).pluck(:username)
  end
  
  # Instance methods
  def online?
    is_online
  end
  
  def mark_online!
    update(is_online: true)
  end
  
  def mark_offline!
    update(is_online: false, is_typing: false)
  end
  
  def start_typing!
    update(is_typing: true, is_online: true)
  end
  
  def stop_typing!
    update(is_typing: false)
  end
end
