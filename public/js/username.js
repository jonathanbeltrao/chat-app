const usernameInput = document.getElementById("username");
const joinButton = document.getElementById("joinButton");

function joinChat() {
  const username = usernameInput.value.trim();
  if (!username) {
    alert("Please enter a username");
    return;
  }

  localStorage.setItem("chatUsername", username);
  window.location.href = "/chat";
}

joinButton.addEventListener("click", joinChat);
usernameInput.addEventListener("keypress", (e) => {
  if (e.key === "Enter") {
    joinChat();
  }
});
