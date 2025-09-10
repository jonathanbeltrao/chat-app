require "test_helper"

class UsersChannelTest < ActionCable::Channel::TestCase
  test "subscribes to users channel" do
    room = Room.default_room
    subscribe(room_id: room.id)
    assert subscription.confirmed?
    assert_has_stream "room_#{room.id}_users"
  end

  test "can update user activity" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    perform :update_activity, { username: "testuser" }
    
    user = User.find_by(username: "testuser")
    assert_not_nil user
    assert user.is_online
  end

  test "broadcasts users list update on subscribe" do
    room = Room.default_room
    assert_broadcasts("room_#{room.id}_users", 1) do
      subscribe(username: "testuser", room_id: room.id)
    end
  end

  test "marks user offline on unsubscribe" do
    # First create and mark user online
    User.create!(username: "testuser", is_online: true)
    room = Room.default_room
    
    subscribe(username: "testuser", room_id: room.id)
    
    # Simulate unsubscribe
    unsubscribe
    
    user = User.find_by(username: "testuser")
    assert_not user.is_online
  end

  test "handles missing username gracefully" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    assert_nothing_raised do
      perform :update_activity, {}
    end
  end

  test "creates user if not exists on activity update" do
    room = Room.default_room
    subscribe(room_id: room.id)
    
    assert_difference "User.count", 1 do
      perform :update_activity, { username: "newuser" }
    end
    
    user = User.find_by(username: "newuser")
    assert user.is_online
  end
end
