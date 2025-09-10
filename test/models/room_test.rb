require "test_helper"

class RoomTest < ActiveSupport::TestCase
  test "should create valid room with name" do
    room = Room.new(name: "test-room", description: "Test room")
    assert room.valid?
    assert room.save
  end

  test "should require name" do
    room = Room.new(description: "Test room")
    assert_not room.valid?
    assert_includes room.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    Room.create!(name: "duplicate", description: "First room")
    duplicate_room = Room.new(name: "duplicate", description: "Second room")
    assert_not duplicate_room.valid?
    assert_includes duplicate_room.errors[:name], "has already been taken"
  end

  test "should have many messages" do
    room = rooms(:general)
    assert_respond_to room, :messages
    assert room.messages.count > 0
  end

  test "should get default room" do
    default_room = Room.default_room
    assert_equal "general", default_room.name
    assert_not_nil default_room.description
  end

  test "should create default room if it doesn't exist" do
    Room.where(name: "general").destroy_all
    default_room = Room.default_room
    assert_equal "general", default_room.name
    assert default_room.persisted?
  end
end
