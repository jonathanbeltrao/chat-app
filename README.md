# Simple Chat App

A real-time chat application built with Ruby on Rails, Action Cable, and vanilla JavaScript.

## Features

- 💬 Real-time messaging
- 👥 Multiple users support
- 🎨 Modern, responsive UI
- 💾 Message persistence with SQLite
- 🚀 No external dependencies for frontend

## Architecture

- **Backend**: Ruby on Rails 7.2 with Action Cable for WebSocket connections
- **Database**: SQLite3 for message storage
- **Frontend**: Pure vanilla JavaScript with WebSocket integration

## Project Structure

```
chat-app/
├── app/
│   ├── channels/
│   │   └── messages_channel.rb      # Action Cable channel for real-time messaging
│   ├── controllers/
│   │   └── messages_controller.rb   # HTTP API for message CRUD
│   ├── models/
│   │   └── message.rb               # Message model with validations
│   └── views/
│       └── messages/
│           └── index.html.erb       # Chat interface with vanilla JS
├── config/
│   ├── cable.yml                    # Action Cable configuration
│   ├── database.yml                 # Database configuration
│   └── routes.rb                    # Application routes
├── db/
│   └── migrate/
│       └── create_messages.rb       # Database migration
├── simple_server.rb                 # Alternative simple HTTP server
└── storage/
    └── development.sqlite3          # SQLite database file
```

## Quick Start (Alternative Simple Server)

Due to some gem conflicts with the Rails environment, I've created a simple HTTP server that works independently:

```bash
# Install required gems (if not already installed)
gem install webrick sqlite3

# Start the simple server
ruby simple_server.rb
```

Then open your browser to: **http://localhost:3000**
