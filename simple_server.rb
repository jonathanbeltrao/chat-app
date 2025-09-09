#!/usr/bin/env ruby

# Simple HTTP server for the chat app
require 'webrick'
require 'json'
require 'sqlite3'

# Initialize database
db = SQLite3::Database.new('storage/development.sqlite3')
db.results_as_hash = true

# Username selection page
USERNAME_PAGE = <<~HTML
<!DOCTYPE html>
<html>
<head>
  <title>Join Chat</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="/css/username.css">
</head>
<body>
  <div class="join-container">
    <h1>Join Chat</h1>
    <input type="text" id="username" class="username-input" placeholder="Enter your username..." maxlength="50" autofocus>
    <button id="joinButton" class="join-button">Join Chat Room</button>
  </div>

  <script src="/js/username.js"></script>
</body>
</html>
HTML

# Chat room HTML page
CHAT_PAGE = <<~HTML
<!DOCTYPE html>
<html>
<head>
  <title>Chat App</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="/css/chat.css">
</head>
<body>
  <div class="chat-container">
    <div class="chat-header">
      Chat App
    </div>
    
    <div class="chat-body">
      <div class="users-sidebar">
        <div class="users-title">Online Users</div>
        <div id="usersList">
          <div class="no-messages">Loading users...</div>
        </div>
      </div>
      
      <div class="messages-container" id="messages">
        <div class="no-messages">Loading messages...</div>
      </div>
    </div>
    
    <div class="typing-indicator" id="typingIndicator" style="display: none;">
      <span id="typingText"></span>
    </div>
    
    <div class="chat-input-container">
      <div class="input-group">
        <input type="text" id="messageInput" class="message-input" placeholder="Type your message..." maxlength="500">
        <button id="sendButton" class="send-button">Send</button>
      </div>
    </div>
  </div>

  <script src="/js/chat.js"></script>
</body>
</html>
HTML

# Create a simple web server
server = WEBrick::HTTPServer.new(
  Port: 3000
)

# Handle GET requests to root (username selection)
server.mount_proc '/' do |req, res|
  res.content_type = 'text/html'
  res.body = USERNAME_PAGE
end

# Handle GET requests to chat room
server.mount_proc '/chat' do |req, res|
  res.content_type = 'text/html'
  res.body = CHAT_PAGE
end

# Handle static CSS files
server.mount_proc '/css' do |req, res|
  file_path = File.join('public', req.path)
  if File.exist?(file_path) && File.file?(file_path)
    res.content_type = 'text/css'
    res.body = File.read(file_path)
  else
    res.status = 404
    res.body = 'Not Found'
  end
end

# Handle static JS files
server.mount_proc '/js' do |req, res|
  file_path = File.join('public', req.path)
  if File.exist?(file_path) && File.file?(file_path)
    res.content_type = 'application/javascript'
    res.body = File.read(file_path)
  else
    res.status = 404
    res.body = 'Not Found'
  end
end

# Handle GET requests to /messages (fetch messages)
server.mount_proc '/messages' do |req, res|
  if req.request_method == 'GET'
    messages = db.execute("SELECT * FROM messages ORDER BY created_at ASC LIMIT 50")
    res.content_type = 'application/json'
    res.body = messages.to_json
  elsif req.request_method == 'POST'
    # Parse JSON body
    body = JSON.parse(req.body)
    content = body['content']
    username = body['username']
    
    if content && username
      db.execute(
        "INSERT INTO messages (content, username, created_at, updated_at) VALUES (?, ?, datetime('now'), datetime('now'))",
        [content, username]
      )
      res.status = 200
      res.body = 'OK'
    else
      res.status = 400
      res.body = 'Missing content or username'
    end
  end
end

# Handle user activity updates
server.mount_proc '/users/activity' do |req, res|
  if req.request_method == 'POST'
    body = JSON.parse(req.body)
    username = body['username']
    
    if username
      # Update or insert user activity
      db.execute(
        "INSERT OR REPLACE INTO active_users (username, last_seen) VALUES (?, datetime('now'))",
        [username]
      )
      res.status = 200
      res.body = 'OK'
    else
      res.status = 400
      res.body = 'Missing username'
    end
  end
end

# Handle GET requests to /users (fetch active users)
server.mount_proc '/users' do |req, res|
  if req.request_method == 'GET'
    # Get users active within last 10 seconds
    users = db.execute(
      "SELECT username FROM active_users WHERE last_seen > datetime('now', '-10 seconds') ORDER BY username"
    )
    res.content_type = 'application/json'
    res.body = users.to_json
  end
end

# Handle typing status updates
server.mount_proc '/typing' do |req, res|
  if req.request_method == 'POST'
    body = JSON.parse(req.body)
    username = body['username']
    is_typing = body['is_typing']
    
    if username
      if is_typing
        # User is typing
        db.execute(
          "INSERT OR REPLACE INTO typing_status (username, is_typing, last_typing) VALUES (?, 1, datetime('now'))",
          [username]
        )
      else
        # User stopped typing
        db.execute(
          "DELETE FROM typing_status WHERE username = ?",
          [username]
        )
      end
      res.status = 200
      res.body = 'OK'
    else
      res.status = 400
      res.body = 'Missing username'
    end
  elsif req.request_method == 'GET'
    # Get users currently typing (within last 5 seconds)
    typing_users = db.execute(
      "SELECT username FROM typing_status WHERE is_typing = 1 AND last_typing > datetime('now', '-5 seconds')"
    )
    res.content_type = 'application/json'
    res.body = typing_users.to_json
  end
end

# Start the server
puts "Starting chat app server on http://localhost:3000"
puts "Press Ctrl+C to stop"

trap('INT') { server.shutdown }
server.start
