# Challenge Chat App

## Local Setup

### Prerequisites

- Ruby 3.1+
- Rails 7.2+
- SQLite3

### Installation

1. **Clone and install**

```bash
bundle install
```

2. **Setup database**

```bash
rails db:create db:migrate
```

3. **Start the server**

```bash
rails server
```

4. **Open in browser**

```
http://localhost:3000
```

## Tech Stack

- **Backend**: Ruby on Rails 7.2 + ActionCable
- **Database**: SQLite3
- **Frontend**: Vanilla JavaScript + CSS
- **Real-time**: WebSocket connections (Action Cable)

## Project Structure

```
app/
├── channels/           # ActionCable channels for real-time features
├── controllers/        # Rails controllers
├── models/            # User and Message models
├── views/             # HTML templates (using shared layout)
├── assets/            # CSS and JavaScript files
config/
├── cable.yml          # ActionCable configuration
├── routes.rb          # Application routes
db/
├── migrate/           # Database migrations
```
