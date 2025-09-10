class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.boolean :is_online, default: false

      t.timestamps
    end
    
    add_index :users, :username, unique: true
    add_index :users, :is_online
  end
end
