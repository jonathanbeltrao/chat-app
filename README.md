# Real-Time Chat App

A real-time chat application built with Ruby on Rails, ActionCable WebSockets, and vanilla JavaScript.

## Features

- 💬 **Real-time messaging** via ActionCable WebSockets
- 👥 **Online users list** with live status updates
- ⌨️ **Typing indicators** showing who's currently typing
- 🎨 **Modern, responsive UI** with smooth animations
- 💾 **Message persistence** with SQLite database
- 🚀 **Pure vanilla JavaScript** - no frontend frameworks
- 📱 **Mobile-responsive** design

## Architecture

- **Backend**: Ruby on Rails 7.2 with ActionCable for WebSocket connections
- **Database**: SQLite3 for message storage
- **Frontend**: Pure vanilla JavaScript with ActionCable integration
- **Real-time**: WebSocket connections for instant messaging, typing indicators, and user presence

## Project Structure

```
chat-app/
├── app/
│   ├── channels/
│   │   ├── messages_channel.rb      # Real-time messaging channel
│   │   ├── typing_channel.rb        # Typing indicators channel
│   │   └── users_channel.rb         # Online users channel
│   ├── controllers/
│   │   └── messages_controller.rb   # Username selection & chat views
│   ├── models/
│   │   └── message.rb               # Message model with validations
│   └── views/
│       └── messages/
│           ├── index.html.erb       # Username selection page
│           └── chat.html.erb        # Chat interface with ActionCable
├── config/
│   ├── cable.yml                    # ActionCable configuration
│   ├── database.yml                 # Database configuration
│   └── routes.rb                    # Application routes
├── db/
│   └── migrate/
│       └── create_messages.rb       # Database migration
└── storage/
    └── development.sqlite3          # SQLite database file
```

## Quick Start

```bash
# Install dependencies
bundle install

# Set up database
rails db:create db:migrate

# Start the Rails server
rails server
```

Then open your browser to: **http://localhost:3000**

## Usage

1. **Enter Username**: Start by entering your username on the welcome page
2. **Join Chat**: Click "Join Chat Room" to enter the main chat interface
3. **Send Messages**: Type messages and press Enter or click Send
4. **See Live Activity**:
   - View online users in the sidebar
   - See typing indicators when others are typing
   - Messages appear instantly via WebSocket connection
