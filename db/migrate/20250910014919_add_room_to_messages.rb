class AddRoomToMessages < ActiveRecord::Migration[7.2]
  def change
    # First add the column as nullable
    add_reference :messages, :room, null: true, foreign_key: true
    
    # Create the default room and assign all existing messages to it
    reversible do |dir|
      dir.up do
        default_room = Room.find_or_create_by(name: "general") do |room|
          room.description = "General chat room for everyone"
        end
        
        # Update all existing messages to belong to the default room
        Message.update_all(room_id: default_room.id)
        
        # Now make the column non-nullable
        change_column_null :messages, :room_id, false
      end
    end
  end
end
