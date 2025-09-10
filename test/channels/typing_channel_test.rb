require "test_helper"

class TypingChannelTest < ActionCable::Channel::TestCase
  test "subscribes to typing channel" do
    room = Room.default_room
    subscribe(room_id: room.id)
    assert subscription.confirmed?
    assert_has_stream "room_#{room.id}_typing"
  end

  test "broadcasts start typing event" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    assert_broadcasts("room_#{room.id}_typing", 1) do
      perform :start_typing, { username: "testuser" }
    end
  end

  test "broadcasts stop typing event" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    assert_broadcasts("room_#{room.id}_typing", 1) do
      perform :stop_typing, { username: "testuser" }
    end
  end

  test "broadcasts stop typing on unsubscribe" do
    room = Room.default_room
    
    assert_broadcasts("room_#{room.id}_typing", 1) do
      subscribe(username: "testuser", room_id: room.id)
      unsubscribe
    end
  end

  test "handles missing username gracefully" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    assert_nothing_raised do
      perform :start_typing, {}
      perform :stop_typing, {}
    end
  end

  test "typing events work without creating users" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    # No database changes should occur
    assert_no_difference "User.count" do
      perform :start_typing, { username: "newuser" }
      perform :stop_typing, { username: "newuser" }
    end
  end
end
