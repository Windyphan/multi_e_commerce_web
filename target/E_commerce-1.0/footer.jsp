<%@page import="java.time.Year" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% int currentYear = Year.now().getValue(); %>
<div id="chat-widget" style="position: fixed; bottom: 20px; right: 20px; width: 300px; border: 1px solid #ccc; background-color: white; box-shadow: 0 4px 8px rgba(0,0,0,0.1); border-radius: 5px; display: none; /* Start hidden */">
    <div id="chat-header" style="background-color: #2c3e50; color: white; padding: 10px; font-weight: bold; cursor: pointer; border-top-left-radius: 5px; border-top-right-radius: 5px;">
        Chat with Us! <span style="float:right;">×</span> <%-- Close button --%>
    </div>
    <div id="chat-body" style="height: 300px; overflow-y: auto; padding: 10px; border-bottom: 1px solid #eee;">
        <!-- Messages will appear here -->
        <div class="bot-message">Hello! How can I assist you?</div>
    </div>
    <div id="chat-input-area" style="padding: 10px; display: flex;">
        <input type="text" id="chat-input" style="flex-grow: 1; border: 1px solid #ccc; padding: 5px; border-radius: 3px;" placeholder="Type your message...">
        <button id="chat-send-btn" style="margin-left: 5px; background-color: #0d6efd; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer;">Send</button>
    </div>
</div>

<button id="open-chat-btn" style="position: fixed; bottom: 20px; right: 20px; background-color: #0d6efd; color: white; border: none; border-radius: 50%; width: 60px; height: 60px; font-size: 24px; cursor: pointer; box-shadow: 0 4px 8px rgba(0,0,0,0.2);"><i class="fas fa-comment-dots"></i></button>

<style> /* Simple styles for chat messages */
.user-message { text-align: right; margin: 5px 0; padding: 5px 10px; background-color: #e7f1ff; border-radius: 10px; margin-left: 40px;}
.bot-message { text-align: left; margin: 5px 0; padding: 5px 10px; background-color: #f1f1f1; border-radius: 10px; margin-right: 40px;}
</style>
<footer class="footer mt-auto py-3 bg-dark text-white-50"> <%-- mt-auto is key --%>
    <div class="container text-center">
        <span>© <%= currentYear %> Phong Phan. All Rights Reserved.</span>
</footer>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        const chatWidget = document.getElementById('chat-widget');
        const openChatBtn = document.getElementById('open-chat-btn');
        const chatHeader = document.getElementById('chat-header'); // For closing
        const chatBody = document.getElementById('chat-body');
        const chatInput = document.getElementById('chat-input');
        const sendBtn = document.getElementById('chat-send-btn');

        const API_ENDPOINT = 'https://1s4yyf7g4i.execute-api.eu-north-1.amazonaws.com/chatbot'; // Append route path

        // --- Toggle Chat Widget ---
        openChatBtn.addEventListener('click', () => {
            chatWidget.style.display = 'block';
            openChatBtn.style.display = 'none';
        });

        chatHeader.addEventListener('click', (e) => {
            // Close if clicking header (or specifically a close button)
            if (e.target === chatHeader || e.target.tagName === 'SPAN') {
                chatWidget.style.display = 'none';
                openChatBtn.style.display = 'block';
            }
        });

        // --- Send Message Function ---
        const sendMessage = () => {
            const userMessage = chatInput.value.trim();
            if (!userMessage) return; // Don't send empty messages

            // Display user message
            appendMessage(userMessage, 'user');
            chatInput.value = ''; // Clear input

            // Show typing indicator (optional)
            // appendMessage("...", 'bot');

            // Send message to API Gateway -> Lambda
            fetch(API_ENDPOINT, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ message: userMessage }) // Send as JSON
            })
                .then(response => {
                    // Remove typing indicator (if used)
                    if (!response.ok) {
                        throw new Error(`HTTP error! status: ${response.status}`);
                    }
                    return response.json(); // Parse JSON response from Lambda
                })
                .then(data => {
                    if (data && data.reply) {
                        appendMessage(data.reply, 'bot');
                    } else {
                        appendMessage("Sorry, I received an unexpected response.", 'bot');
                    }
                })
                .catch(error => {
                    console.error('Error sending message:', error);
                    // Remove typing indicator (if used)
                    appendMessage("Sorry, I couldn't connect to the chat service.", 'bot');
                });
        };

        // --- Append Message to Chat Body ---
        const appendMessage = (text, sender) => {
            const messageDiv = document.createElement('div');
            messageDiv.classList.add(sender === 'user' ? 'user-message' : 'bot-message');
            messageDiv.textContent = text; // Use textContent to prevent HTML injection
            chatBody.appendChild(messageDiv);
            // Scroll to bottom
            chatBody.scrollTop = chatBody.scrollHeight;
        };

        // --- Event Listeners for Sending ---
        sendBtn.addEventListener('click', sendMessage);
        chatInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                sendMessage();
            }
        });
    });
</script>