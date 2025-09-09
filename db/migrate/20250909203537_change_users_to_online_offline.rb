class ChangeUsersToOnlineOffline < ActiveRecord::Migration[7.2]
  def change
    # Remove last_seen_at and its index
    remove_index :users, :last_seen_at
    remove_column :users, :last_seen_at, :datetime
    
    # Add is_online boolean column
    add_column :users, :is_online, :boolean, default: false
    add_index :users, :is_online
    
    # Update existing users to be offline by default
    User.update_all(is_online: false) if User.table_exists?
  end
end