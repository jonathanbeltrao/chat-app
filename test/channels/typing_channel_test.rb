require "test_helper"

class TypingChannelTest < ActionCable::Channel::TestCase
  test "subscribes to typing channel" do
    room = Room.default_room
    subscribe(room_id: room.id)
    assert subscription.confirmed?
    assert_has_stream "room_#{room.id}_typing"
  end

  test "can start typing" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    perform :start_typing, { username: "testuser" }
    
    user = User.find_by(username: "testuser")
    assert_not_nil user
    assert user.is_typing
  end

  test "can stop typing" do
    # Create user who is typing
    user = User.create!(username: "testuser", is_typing: true)
    room = Room.default_room
    
    subscribe(room_id: room.id)
    
    perform :stop_typing, { username: "testuser" }
    
    user.reload
    assert_not user.is_typing
  end

  test "broadcasts typing list update when starting typing" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    assert_broadcasts("room_#{room.id}_typing", 1) do
      perform :start_typing, { username: "testuser" }
    end
  end

  test "broadcasts typing list update when stopping typing" do
    User.create!(username: "testuser", is_typing: true)
    room = Room.default_room
    
    subscribe(room_id: room.id)
    
    assert_broadcasts("room_#{room.id}_typing", 1) do
      perform :stop_typing, { username: "testuser" }
    end
  end

  test "stops typing on unsubscribe" do
    # Create user who is typing
    User.create!(username: "testuser", is_typing: true)
    room = Room.default_room
    
    subscribe(username: "testuser", room_id: room.id)
    
    # Simulate unsubscribe
    unsubscribe
    
    user = User.find_by(username: "testuser")
    assert_not user.is_typing
  end

  test "handles missing username gracefully" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    assert_nothing_raised do
      perform :start_typing, {}
      perform :stop_typing, {}
    end
  end

  test "creates user if not exists when starting typing" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    assert_difference "User.count", 1 do
      perform :start_typing, { username: "newuser" }
    end
    
    user = User.find_by(username: "newuser")
    assert user.is_typing
  end
end
