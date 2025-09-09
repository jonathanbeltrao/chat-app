require "test_helper"

class UsersChannelTest < ActionCable::Channel::TestCase
  test "subscribes to users channel" do
    subscribe
    assert subscription.confirmed?
    assert_has_stream "users"
  end

  test "can update user activity" do
    subscribe
    
    perform :update_activity, { username: "testuser" }
    
    user = User.find_by(username: "testuser")
    assert_not_nil user
    assert user.is_online
  end

  test "broadcasts users list update on subscribe" do
    assert_broadcasts("users", 1) do
      subscribe(username: "testuser")
    end
  end

  test "marks user offline on unsubscribe" do
    # First create and mark user online
    User.create!(username: "testuser", is_online: true)
    
    subscribe(username: "testuser")
    
    # Simulate unsubscribe
    unsubscribe
    
    user = User.find_by(username: "testuser")
    assert_not user.is_online
  end

  test "handles missing username gracefully" do
    subscribe
    
    assert_nothing_raised do
      perform :update_activity, {}
    end
  end

  test "creates user if not exists on activity update" do
    subscribe
    
    assert_difference "User.count", 1 do
      perform :update_activity, { username: "newuser" }
    end
    
    user = User.find_by(username: "newuser")
    assert user.is_online
  end
end
