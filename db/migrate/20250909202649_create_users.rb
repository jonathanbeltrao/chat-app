class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.datetime :last_seen_at
      t.boolean :is_typing, default: false

      t.timestamps
    end
    
    add_index :users, :username, unique: true
    add_index :users, :last_seen_at
    add_index :users, :is_typing
  end
end
