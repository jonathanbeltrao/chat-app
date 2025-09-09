require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should create valid user with username" do
    user = User.new(username: "testuser")
    assert user.valid?
    assert user.save
  end

  test "should require username" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "should require unique username" do
    User.create!(username: "testuser")
    duplicate_user = User.new(username: "testuser")
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:username], "has already been taken"
  end

  test "should default to offline and not typing" do
    user = User.create!(username: "newuser")
    assert_not user.is_online
    assert_not user.is_typing
  end

  test "should be able to mark user online" do
    user = users(:offline_user)
    assert_not user.online?
    
    user.mark_online!
    assert user.online?
    assert user.is_online
  end

  test "should be able to mark user offline" do
    user = users(:alice)
    assert user.online?
    
    user.mark_offline!
    assert_not user.online?
    assert_not user.is_online
  end

  test "should be able to start typing" do
    user = users(:alice)
    assert_not user.is_typing
    
    user.start_typing!
    assert user.is_typing
  end

  test "should be able to stop typing" do
    user = users(:typing_user)
    assert user.is_typing
    
    user.stop_typing!
    assert_not user.is_typing
  end

  test "online scope should return only online users" do
    online_users = User.online
    online_users.each do |user|
      assert user.is_online
    end
  end

  test "typing scope should return only typing users" do
    typing_users = User.typing
    typing_users.each do |user|
      assert user.is_typing
    end
  end

  test "should mark user online class method" do
    username = "class_method_test"
    User.mark_user_online(username)
    
    user = User.find_by(username: username)
    assert_not_nil user
    assert user.is_online
  end

  test "should mark user offline class method" do
    user = users(:alice)
    User.mark_user_offline(user.username)
    
    user.reload
    assert_not user.is_online
  end

  test "should get online users list" do
    online_users = User.get_online_users
    expected_count = User.where(is_online: true).count
    assert_equal expected_count, online_users.count
  end

  test "should get typing users list" do
    typing_users = User.get_typing_users
    expected_count = User.where(is_typing: true).count
    assert_equal expected_count, typing_users.count
  end
end
