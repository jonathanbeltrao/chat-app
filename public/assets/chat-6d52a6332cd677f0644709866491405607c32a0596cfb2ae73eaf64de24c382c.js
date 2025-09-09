class ChatApp {
  constructor() {
    // Check if username is set, redirect if not
    this.username = localStorage.getItem("chatUsername");
    if (!this.username) {
      window.location.href = "/";
      return;
    }

    this.messagesContainer = document.getElementById("messages");
    this.messageInput = document.getElementById("messageInput");
    this.sendButton = document.getElementById("sendButton");
    this.logoutButton = document.getElementById("logoutButton");
    this.usersList = document.getElementById("usersList");
    this.typingIndicator = document.getElementById("typingIndicator");
    this.typingText = document.getElementById("typingText");

    this.isTyping = false;
    this.typingTimeout = null;
    this.onlineUsers = new Set();
    this.typingUsers = new Set();

    this.initializeActionCable();
    this.bindEvents();
    this.scrollToBottom();
  }

  initializeActionCable() {
    const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
    const wsUrl = `${protocol}//${window.location.host}/cable`;

    this.cable = ActionCable.createConsumer(wsUrl);

    // Subscribe to messages channel
    this.messagesChannel = this.cable.subscriptions.create("MessagesChannel", {
      connected: () => {
        console.log("Connected to MessagesChannel");
      },

      disconnected: () => {
        console.log("Disconnected from MessagesChannel");
      },

      received: (data) => {
        this.addMessageToDOM(data);
      },
    });

    // Subscribe to users channel
    this.usersChannel = this.cable.subscriptions.create(
      {
        channel: "UsersChannel",
        username: this.username,
      },
      {
        connected: () => {
          console.log("Connected to UsersChannel");
        },

        disconnected: () => {
          console.log("Disconnected from UsersChannel");
        },

        received: (data) => {
          this.handleUsersUpdate(data);
        },
      }
    );

    // Subscribe to typing channel
    this.typingChannel = this.cable.subscriptions.create(
      {
        channel: "TypingChannel",
        username: this.username,
      },
      {
        connected: () => {
          console.log("Connected to TypingChannel");
        },

        disconnected: () => {
          console.log("Disconnected from TypingChannel");
        },

        received: (data) => {
          this.handleTypingUpdate(data);
        },
      }
    );
  }

  bindEvents() {
    this.sendButton.addEventListener("click", () => this.sendMessage());

    this.logoutButton.addEventListener("click", () => this.logout());

    this.messageInput.addEventListener("keypress", (e) => {
      if (e.key === "Enter") {
        this.sendMessage();
      }
    });

    this.messageInput.addEventListener("input", () => {
      this.handleTyping();
    });

    this.messageInput.addEventListener("keyup", () => {
      this.handleTyping();
    });

    // Send periodic activity updates
    setInterval(() => {
      this.usersChannel.perform("update_activity", {
        username: this.username,
      });
    }, 30000); // Every 30 seconds
  }

  sendMessage() {
    const content = this.messageInput.value.trim();

    if (!content) {
      alert("Please enter a message");
      return;
    }

    // Send via ActionCable
    this.messagesChannel.perform("speak", {
      message: content,
      username: this.username,
    });

    this.messageInput.value = "";

    // Stop typing when message is sent
    if (this.isTyping) {
      this.isTyping = false;
      this.typingChannel.perform("stop_typing", {
        username: this.username,
      });
    }
  }

  addMessageToDOM(message) {
    const noMessagesDiv = this.messagesContainer.querySelector(".no-messages");
    if (noMessagesDiv) {
      noMessagesDiv.remove();
    }

    const messageDiv = document.createElement("div");
    messageDiv.className = "message";
    messageDiv.innerHTML = `
      <div class="message-header">
        <span class="message-username">${this.escapeHtml(
          message.username
        )}</span>
        <span class="message-time">${message.created_at}</span>
      </div>
      <div class="message-content">${this.escapeHtml(message.content)}</div>
    `;

    this.messagesContainer.appendChild(messageDiv);
    this.scrollToBottom();
  }

  handleUsersUpdate(data) {
    switch (data.action) {
      case "users_list_updated":
        // Replace entire user list with fresh data from database
        this.onlineUsers = new Set(data.users);
        break;
      // Keep legacy support for old message types
      case "user_joined":
        this.onlineUsers.add(data.username);
        break;
      case "user_left":
        this.onlineUsers.delete(data.username);
        break;
      case "user_activity":
        this.onlineUsers.add(data.username);
        break;
    }
    this.updateUsersList();
  }

  updateUsersList() {
    this.usersList.innerHTML = "";

    if (this.onlineUsers.size === 0) {
      this.usersList.innerHTML =
        '<div class="no-messages">No users online</div>';
      return;
    }

    Array.from(this.onlineUsers)
      .sort()
      .forEach((username) => {
        const userDiv = document.createElement("div");
        userDiv.className = "user-item";
        userDiv.innerHTML = `
        <div class="user-status"></div>
        ${this.escapeHtml(username)}
      `;
        this.usersList.appendChild(userDiv);
      });
  }

  handleTyping() {
    const hasText = this.messageInput.value.trim().length > 0;

    if (hasText && !this.isTyping) {
      this.isTyping = true;
      this.typingChannel.perform("start_typing", {
        username: this.username,
      });
    }

    // Clear previous timeout
    clearTimeout(this.typingTimeout);

    // Set timeout to stop typing after 2 seconds of inactivity
    this.typingTimeout = setTimeout(() => {
      if (this.isTyping) {
        this.isTyping = false;
        this.typingChannel.perform("stop_typing", {
          username: this.username,
        });
      }
    }, 2000);
  }

  handleTypingUpdate(data) {
    switch (data.action) {
      case "typing_list_updated":
        // Replace entire typing list with fresh data from database
        this.typingUsers = new Set(
          data.typing_users.filter((username) => username !== this.username)
        );
        break;
      // Keep legacy support for old message types
      case "start_typing":
        if (data.username !== this.username) {
          this.typingUsers.add(data.username);
        }
        break;
      case "stop_typing":
        this.typingUsers.delete(data.username);
        break;
    }
    this.updateTypingIndicator();
  }

  updateTypingIndicator() {
    if (this.typingUsers.size === 0) {
      this.typingIndicator.style.display = "none";
      return;
    }

    const typingArray = Array.from(this.typingUsers);
    let typingText = "";

    if (typingArray.length === 1) {
      typingText = `${typingArray[0]} is typing`;
    } else if (typingArray.length === 2) {
      typingText = `${typingArray[0]} and ${typingArray[1]} are typing`;
    } else {
      typingText = `${typingArray.length} people are typing`;
    }

    this.typingText.innerHTML = `${typingText} <span class="typing-dots"></span>`;
    this.typingIndicator.style.display = "block";
  }

  escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }

  scrollToBottom() {
    setTimeout(() => {
      this.messagesContainer.scrollTop = this.messagesContainer.scrollHeight;
    }, 100);
  }

  logout() {
    // Confirm logout
    if (!confirm("Are you sure you want to logout?")) {
      return;
    }

    // Send logout request to server
    const csrfToken = document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute("content");

    fetch("/logout", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
      },
      body: JSON.stringify({
        username: this.username,
      }),
    })
      .then((response) => {
        if (response.ok) {
          // Clear username from localStorage
          localStorage.removeItem("chatUsername");

          // Disconnect from ActionCable
          this.destroy();

          // Redirect to username selection page
          window.location.href = "/";
        } else {
          throw new Error("Failed to logout");
        }
      })
      .catch((error) => {
        console.error("Error during logout:", error);
        alert("Failed to logout. Please try again.");
      });
  }

  // Cleanup method
  destroy() {
    if (this.cable) {
      this.cable.disconnect();
    }
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout);
    }
  }
}

// Initialize the chat app when the page loads
document.addEventListener("DOMContentLoaded", () => {
  window.chatApp = new ChatApp();
});

// Cleanup on page unload
window.addEventListener("beforeunload", () => {
  if (window.chatApp) {
    window.chatApp.destroy();
  }
});
