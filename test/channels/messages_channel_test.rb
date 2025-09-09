require "test_helper"

class MessagesChannelTest < ActionCable::Channel::TestCase
  test "subscribes to messages channel" do
    subscribe
    assert subscription.confirmed?
    assert_has_stream "messages"
  end

  test "can send message through channel" do
    subscribe
    
    assert_difference "Message.count", 1 do
      perform :speak, { 
        username: "testuser", 
        message: "Hello from channel test!" 
      }
    end
  end

  test "broadcasts message after creation" do
    subscribe
    
    assert_broadcasts("messages", 1) do
      perform :speak, { 
        username: "testuser", 
        message: "Test message" 
      }
    end
  end

  test "does not create message with invalid user / no user" do
    subscribe
    
    assert_raises(ActiveRecord::RecordInvalid) do
      perform :speak, { 
        username: "", 
        message: "Test message" 
      }
    end
  end

  test "handles empty content" do
    subscribe
    
    assert_raises(ActiveRecord::RecordInvalid) do
      perform :speak, { 
        username: "testuser", 
        message: "" 
      }
    end
  end
end
