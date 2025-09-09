class User < ApplicationRecord
  validates :username, presence: true, uniqueness: true, length: { maximum: 50 }
  
  # Scopes for finding active users
  scope :active, -> { where('last_seen_at > ?', 30.seconds.ago) }
  scope :typing, -> { where(is_typing: true) }
  scope :online_and_typing, -> { active.typing }
  
  # Class methods for user management
  def self.mark_user_active(username)
    user = find_or_create_by(username: username)
    user.update(last_seen_at: Time.current)
    user
  end
  
  def self.mark_user_typing(username, typing = true)
    user = find_or_create_by(username: username)
    user.update(
      is_typing: typing,
      last_seen_at: Time.current
    )
    user
  end
  
  def self.cleanup_inactive_users
    where('last_seen_at < ?', 1.minute.ago).delete_all
  end
  
  def self.get_active_users
    active.order(:username).pluck(:username)
  end
  
  def self.get_typing_users
    online_and_typing.order(:username).pluck(:username)
  end
  
  # Instance methods
  def active?
    last_seen_at && last_seen_at > 30.seconds.ago
  end
  
  def mark_active!
    update(last_seen_at: Time.current)
  end
  
  def start_typing!
    update(is_typing: true, last_seen_at: Time.current)
  end
  
  def stop_typing!
    update(is_typing: false, last_seen_at: Time.current)
  end
end
