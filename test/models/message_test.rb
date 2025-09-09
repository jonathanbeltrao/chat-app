require "test_helper"

class MessageTest < ActiveSupport::TestCase
  test "should create valid message with username and content" do
    message = Message.new(username: "testuser", content: "Hello world!")
    assert message.valid?
    assert message.save
  end

  test "should require username" do
    message = Message.new(content: "Hello world!")
    assert_not message.valid?
    assert_includes message.errors[:username], "can't be blank"
  end

  test "should require content" do
    message = Message.new(username: "testuser")
    assert_not message.valid?
    assert_includes message.errors[:content], "can't be blank"
  end

  test "should not save message with blank username" do
    message = Message.new(username: "", content: "Hello world!")
    assert_not message.valid?
    assert_not message.save
  end

  test "should not save message with blank content" do
    message = Message.new(username: "testuser", content: "")
    assert_not message.valid?
    assert_not message.save
  end

  test "should order messages by creation time" do
    # Create messages with explicit timing
    first = Message.create!(username: "alice", content: "First message")
    sleep(0.01) # Small delay to ensure different timestamps
    second = Message.create!(username: "bob", content: "Second message")
    
    ordered_messages = Message.all.order(:created_at)
    assert_equal first, ordered_messages[-2] # second to last
    assert_equal second, ordered_messages.last
  end

  test "should have created_at timestamp" do
    message = Message.create!(username: "testuser", content: "Test message")
    assert_not_nil message.created_at
  end
end
