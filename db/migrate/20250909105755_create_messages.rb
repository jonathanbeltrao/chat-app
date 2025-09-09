class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.text :content, null: false
      t.string :username, null: false
      
      t.timestamps
    end
    
    add_index :messages, :created_at
  end
end
