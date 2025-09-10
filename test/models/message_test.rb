require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "should create valid message with username, content and room" do
    room = rooms(:general)
    message = Message.new(username: "testuser", content: "Hello world!", room: room)
    assert message.valid?
    assert message.save
  end

  test "should require username" do
    room = rooms(:general)
    message = Message.new(content: "Hello world!", room: room)
    assert_not message.valid?
    assert_includes message.errors[:username], "can't be blank"
  end

  test "should require content" do
    room = rooms(:general)
    message = Message.new(username: "testuser", room: room)
    assert_not message.valid?
    assert_includes message.errors[:content], "can't be blank"
  end

  test "should require room" do
    message = Message.new(username: "testuser", content: "Hello world!")
    assert_not message.valid?
    assert_includes message.errors[:room], "must exist"
  end

  test "should not save message with blank username" do
    room = rooms(:general)
    message = Message.new(username: "", content: "Hello world!", room: room)
    assert_not message.valid?
    assert_not message.save
  end

  test "should not save message with blank content" do
    room = rooms(:general)
    message = Message.new(username: "testuser", content: "", room: room)
    assert_not message.valid?
    assert_not message.save
  end

  test "should order messages by creation time" do
    room = rooms(:general)
    # Create messages with explicit timing
    first = Message.create!(username: "alice", content: "First message", room: room)
    sleep(0.01) # Small delay to ensure different timestamps
    second = Message.create!(username: "bob", content: "Second message", room: room)
    
    ordered_messages = Message.all.order(:created_at)
    assert_equal first, ordered_messages[-2] # second to last
    assert_equal second, ordered_messages.last
  end

  test "should have created_at timestamp" do
    room = rooms(:general)
    message = Message.create!(username: "testuser", content: "Test message", room: room)
    assert_not_nil message.created_at
  end

  test "should belong to room" do
    message = messages(:first_message)
    assert_equal rooms(:general), message.room
  end
end
