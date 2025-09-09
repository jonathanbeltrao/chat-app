class UsernameApp {
  constructor() {
    this.usernameInput = document.getElementById('username');
    this.joinButton = document.getElementById('joinButton');
    
    this.bindEvents();
    this.loadUsernameFromStorage();
  }

  bindEvents() {
    this.joinButton.addEventListener('click', () => this.joinChat());
    
    this.usernameInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        this.joinChat();
      }
    });

    this.usernameInput.addEventListener('input', () => {
      const username = this.usernameInput.value.trim();
      this.joinButton.disabled = username.length === 0;
    });
  }

  loadUsernameFromStorage() {
    const savedUsername = localStorage.getItem('chatUsername');
    if (savedUsername) {
      this.usernameInput.value = savedUsername;
      this.joinButton.disabled = false;
    } else {
      this.joinButton.disabled = true;
    }
  }

  joinChat() {
    const username = this.usernameInput.value.trim();
    
    if (!username) {
      alert('Please enter a username');
      return;
    }

    if (username.length > 50) {
      alert('Username must be 50 characters or less');
      return;
    }

    // Save username to localStorage
    localStorage.setItem('chatUsername', username);
    
    // Redirect to chat room
    window.location.href = '/chat';
  }
}

// Initialize the username app when the page loads
document.addEventListener('DOMContentLoaded', () => {
  new UsernameApp();
});
