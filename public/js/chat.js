class ChatApp {
  constructor() {
    // Check if username is set, redirect if not
    this.username = localStorage.getItem("chatUsername");
    if (!this.username) {
      // Instead of redirecting, just return without initializing
      console.log("No username found, chat not initialized");
      return;
    }

    this.messagesContainer = document.getElementById("messages");
    this.messageInput = document.getElementById("messageInput");
    this.sendButton = document.getElementById("sendButton");
    this.usersList = document.getElementById("usersList");
    this.typingIndicator = document.getElementById("typingIndicator");
    this.typingText = document.getElementById("typingText");

    this.isTyping = false;
    this.typingTimeout = null;

    this.bindEvents();
    this.updateUserActivity();
    this.loadMessages();
    this.loadUsers();

    this.startPolling();
    this.handleVisibilityChange();
  }

  bindEvents() {
    this.sendButton.addEventListener("click", () => this.sendMessage());

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
  }

  loadMessages() {
    fetch("/messages")
      .then((response) => response.json())
      .then((messages) => {
        this.displayMessages(messages);
      })
      .catch((error) => {
        console.error("Error loading messages:", error);
      });
  }

  sendMessage() {
    const content = this.messageInput.value.trim();

    if (!content) {
      alert("Please enter a message");
      return;
    }

    fetch("/messages", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        content: content,
        username: this.username,
      }),
    })
      .then((response) => {
        if (response.ok) {
          this.messageInput.value = "";
          // Stop typing when message is sent
          if (this.isTyping) {
            this.isTyping = false;
            this.updateTypingStatus(false);
          }
          this.loadMessages();
        } else {
          throw new Error("Failed to send message");
        }
      })
      .catch((error) => {
        console.error("Error sending message:", error);
        alert("Failed to send message. Please try again.");
      });
  }

  displayMessages(messages) {
    // Only update if the number of messages has changed to avoid flicker
    const currentMessages =
      this.messagesContainer.querySelectorAll(".message").length;
    const noMessagesDiv = this.messagesContainer.querySelector(".no-messages");

    if (messages.length === 0) {
      if (!noMessagesDiv) {
        this.messagesContainer.innerHTML =
          '<div class="no-messages">No messages yet. Start the conversation!</div>';
      }
      return;
    }

    // Only rebuild if message count changed
    if (
      currentMessages !== messages.length ||
      (currentMessages === 0 && noMessagesDiv)
    ) {
      this.messagesContainer.innerHTML = "";

      messages.forEach((message) => {
        const messageDiv = document.createElement("div");
        messageDiv.className = "message";
        messageDiv.innerHTML = `
          <div class="message-header">
            <span class="message-username">${this.escapeHtml(
              message.username
            )}</span>
            <span class="message-time">${this.formatTime(
              message.created_at
            )}</span>
          </div>
          <div class="message-content">${this.escapeHtml(message.content)}</div>
        `;
        this.messagesContainer.appendChild(messageDiv);
      });

      this.scrollToBottom();
    }
  }

  formatTime(timestamp) {
    const date = new Date(timestamp);
    return date.toLocaleTimeString("en-US", {
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
    });
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

  updateUserActivity() {
    fetch("/users/activity", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        username: this.username,
      }),
    });
  }

  loadUsers() {
    fetch("/users")
      .then((response) => response.json())
      .then((users) => {
        this.displayUsers(users);
      })
      .catch((error) => {
        console.error("Error loading users:", error);
      });
  }

  displayUsers(users) {
    // Only update if the user count has changed to avoid flicker
    const currentUsers = this.usersList.querySelectorAll(".user-item").length;
    const noUsersDiv = this.usersList.querySelector(".no-messages");

    if (users.length === 0) {
      if (!noUsersDiv) {
        this.usersList.innerHTML =
          '<div class="no-messages">No users online</div>';
      }
      return;
    }

    // Only rebuild if user count changed
    if (currentUsers !== users.length || (currentUsers === 0 && noUsersDiv)) {
      this.usersList.innerHTML = "";

      users.forEach((user) => {
        const userDiv = document.createElement("div");
        userDiv.className = "user-item";
        userDiv.innerHTML = `
          <div class="user-status"></div>
          ${this.escapeHtml(user.username)}
        `;
        this.usersList.appendChild(userDiv);
      });
    }
  }

  handleTyping() {
    const hasText = this.messageInput.value.trim().length > 0;

    if (hasText && !this.isTyping) {
      this.isTyping = true;
      this.updateTypingStatus(true);
    }

    // Clear previous timeout
    clearTimeout(this.typingTimeout);

    // Set timeout to stop typing after 2 seconds of inactivity
    this.typingTimeout = setTimeout(() => {
      if (this.isTyping) {
        this.isTyping = false;
        this.updateTypingStatus(false);
      }
    }, 2000);
  }

  updateTypingStatus(isTyping) {
    fetch("/typing", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        username: this.username,
        is_typing: isTyping,
      }),
    });
  }

  loadTypingStatus() {
    fetch("/typing")
      .then((response) => response.json())
      .then((typingUsers) => {
        this.displayTypingIndicator(typingUsers);
      })
      .catch((error) => {
        console.error("Error loading typing status:", error);
      });
  }

  displayTypingIndicator(typingUsers) {
    // Filter out current user
    const otherUsersTyping = typingUsers.filter(
      (user) => user.username !== this.username
    );

    if (otherUsersTyping.length === 0) {
      this.typingIndicator.style.display = "none";
      return;
    }

    let typingText = "";
    if (otherUsersTyping.length === 1) {
      typingText = `${otherUsersTyping[0].username} is typing`;
    } else if (otherUsersTyping.length === 2) {
      typingText = `${otherUsersTyping[0].username} and ${otherUsersTyping[1].username} are typing`;
    } else {
      typingText = `${otherUsersTyping.length} people are typing`;
    }

    this.typingText.innerHTML = `${typingText} <span class="typing-dots"></span>`;
    this.typingIndicator.style.display = "block";
  }

  startPolling() {
    // Poll for new messages, users, and typing status every 3 seconds (less aggressive)
    this.pollInterval = setInterval(() => {
      try {
        // Only poll if page is visible
        if (!document.hidden) {
          this.loadMessages();
          this.loadUsers();
          this.updateUserActivity();
          this.loadTypingStatus();
        }
      } catch (error) {
        console.error("Error during polling:", error);
      }
    }, 3000);
  }

  stopPolling() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval);
      this.pollInterval = null;
    }
  }

  handleVisibilityChange() {
    document.addEventListener("visibilitychange", () => {
      if (document.hidden) {
        // Page is hidden, stop polling to save resources
        this.stopPolling();
      } else {
        // Page is visible again, resume polling
        if (!this.pollInterval) {
          this.startPolling();
          // Immediately update when coming back
          this.loadMessages();
          this.loadUsers();
          this.updateUserActivity();
          this.loadTypingStatus();
        }
      }
    });
  }

  // Cleanup method to stop polling when needed
  destroy() {
    this.stopPolling();
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout);
    }
  }
}

// Initialize the chat app when the page loads
document.addEventListener("DOMContentLoaded", () => {
  new ChatApp();
});
