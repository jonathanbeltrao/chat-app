require "test_helper"

class MessagesChannelTest < ActionCable::Channel::TestCase
  test "subscribes to messages channel" do
    room = Room.default_room
    subscribe(room_id: room.id)
    assert subscription.confirmed?
    assert_has_stream "room_#{room.id}_messages"
  end

  test "can send message through channel" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    assert_difference "Message.count", 1 do
      perform :speak, { 
        username: "testuser", 
        message: "Hello from channel test!" 
      }
    end
  end

  test "broadcasts message after creation" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    assert_broadcasts("room_#{room.id}_messages", 1) do
      perform :speak, { 
        username: "testuser", 
        message: "Test message" 
      }
    end
  end

  test "does not create message with invalid user / no user" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    assert_raises(ActiveRecord::RecordInvalid) do
      perform :speak, { 
        username: "", 
        message: "Test message" 
      }
    end
  end

  test "handles empty content" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    assert_raises(ActiveRecord::RecordInvalid) do
      perform :speak, { 
        username: "testuser", 
        message: "" 
      }
    end
  end
end
