package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

import com.phong.dao.AdminDao;
import com.phong.dao.UserDao;
import com.phong.entities.Admin;
import com.phong.entities.Message;
import com.phong.entities.User;
import com.phong.helper.PasswordUtil;
// ConnectionProvider import likely not needed directly here anymore
// import com.phong.helper.ConnectionProvider;

public class LoginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(); // Get session early
		Message message = null; // Initialize message object

		String login = request.getParameter("login");

		// Basic validation for login parameter
		if (login == null || login.trim().isEmpty()) {
			message = new Message("Login type (user/admin) not specified.", "error", "alert-warning");
			session.setAttribute("message", message);
			// Redirect to a default login page or an error page
			response.sendRedirect("login.jsp");
			return;
		}

		login = login.trim(); // Trim after null check

		UserDao userDao = new UserDao();
		AdminDao adminDao = new AdminDao();
		if (login.equals("user")) {
			// --- User Login ---
			try {
				String userEmail = request.getParameter("user_email");
				String userPassword = request.getParameter("user_password");

				User user = userDao.getUserByEmail(userEmail.trim());

				boolean passwordMatch = false;
				if (user != null) {
					// 2. Check password using BCrypt
					passwordMatch = PasswordUtil.checkPassword(userPassword, user.getUserPassword());
				}

				// Basic validation for user credentials
				if (userEmail == null || userPassword == null || userEmail.trim().isEmpty() || userPassword.trim().isEmpty()) {
					message = new Message("Email and Password are required for user login.", "error", "alert-warning");
					session.setAttribute("message", message);
					response.sendRedirect("login.jsp");
					return;
				}

				// Instantiate UserDao using default constructor

				if (user != null && passwordMatch) { // Check BOTH user exists AND password matches
					session.setAttribute("activeUser", user);
					response.sendRedirect("index.jsp");
				} else {
					message = new Message("Invalid user credentials! Please try again.", "error", "alert-danger");
					session.setAttribute("message", message);
					response.sendRedirect("login.jsp");
				}
				// No return needed here, flow continues to end if redirect happens

			} catch (Exception e) {
				// Catch potential exceptions during DAO interaction or other processing
				message = new Message("An error occurred during user login.", "error", "alert-danger");
				session.setAttribute("message", message);
				response.sendRedirect("login.jsp");
				System.err.println("Error during user login: " + e.getMessage());
				e.printStackTrace(); // Log the full error
			}

		} else if (login.equals("admin")) {
			// --- Admin Login ---
			try {
				String adminEmail = request.getParameter("email");
				String adminPassword = request.getParameter("password"); // Handle passwords securely!

				// Basic validation for admin credentials
				if (adminEmail == null || adminPassword == null || adminEmail.trim().isEmpty() || adminPassword.trim().isEmpty()) {
					message = new Message("Email and Password are required for admin login.", "error", "alert-warning");
					session.setAttribute("message", message);
					response.sendRedirect("adminlogin.jsp"); // Redirect back to admin login page
					return;
				}

				// Instantiate AdminDao using default constructor
				Admin admin = adminDao.getAdminByEmail(adminEmail.trim());
				boolean passwordMatch = false;

				if (admin != null) {
					// 2. Check password using BCrypt
					passwordMatch = PasswordUtil.checkPassword(adminPassword, admin.getPassword());
				}

				if (admin != null && passwordMatch) {
					session.setAttribute("activeAdmin", admin);
					response.sendRedirect("admin.jsp"); // Redirect to admin dashboard
				} else {
					message = new Message("Invalid admin credentials! Please try again.", "error", "alert-danger");
					session.setAttribute("message", message);
					response.sendRedirect("adminlogin.jsp"); // Redirect back to admin login page
				}
				// No return needed here, flow continues to end if redirect happens

			} catch (Exception e) {
				// Catch potential exceptions during DAO interaction or other processing
				message = new Message("An error occurred during admin login.", "error", "alert-danger");
				session.setAttribute("message", message);
				response.sendRedirect("adminlogin.jsp");
				System.err.println("Error during admin login: " + e.getMessage());
				e.printStackTrace(); // Log the full error
			}

		} else {
			// --- Invalid Login Type ---
			message = new Message("Invalid login type specified: " + login, "error", "alert-warning");
			session.setAttribute("message", message);
			// Redirect to a general login page or error page
			response.sendRedirect("login.jsp");
		}

		// Note: The redirects within the try/catch blocks handle the response.
		// If reach here without a redirect having happened (e.g., due to an error
		// before a redirect), might want a final fallback redirect, though the current
		// structure aims to redirect in all logical paths.
	}
}