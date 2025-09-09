require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index page" do
    get root_path
    assert_response :success
    assert_select "h1", "Challenge Chat App"
    assert_select "input#username"
    assert_select "button", "Join Chat Room"
  end

  test "should get chat page" do
    get chat_path
    assert_response :success
    assert_select ".chat-container"
    assert_select "#messageInput"
    assert_select "#sendButton"
    assert_select "#logoutButton"
  end

  test "should create message via POST" do
    assert_difference("Message.count") do
      post messages_path, params: { 
        message: { username: "testuser", content: "Test message" } 
      }
    end
    assert_response :success
  end

  test "should not create message with invalid params" do
    assert_no_difference("Message.count") do
      post messages_path, params: { 
        message: { username: "", content: "Test message" } 
      }
    end
    assert_response :unprocessable_entity
  end

  test "should get messages as JSON via AJAX" do
    get messages_path, xhr: true
    assert_response :success
  end

  test "should handle logout" do
    # Create a user first
    User.create!(username: "testuser", is_online: true)
    
    post logout_path, params: { username: "testuser" }
    assert_response :success
    
    # Verify user is marked offline
    user = User.find_by(username: "testuser")
    assert_not user.is_online
  end

  test "logout should handle non-existent user gracefully" do
    post logout_path, params: { username: "nonexistent" }
    assert_response :success
  end

  test "should render proper content types" do
    get root_path
    assert_match /text\/html/, response.content_type
  end
end
