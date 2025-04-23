package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Random;

import com.phong.dao.UserDao;
import com.phong.entities.Message;
// ConnectionProvider import is no longer needed here
// import com.phong.helper.ConnectionProvider;
import com.phong.helper.MailMessenger;
import com.phong.helper.PasswordUtil;

public class ChangePasswordServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		Message message = null; // Initialize message

		// --- Instantiate UserDao using the default constructor ---
		UserDao userDao = new UserDao(); // DAO handles its own connections now

		// Get the referrer header to determine the flow stage
		String referrer = request.getHeader("referer");

		// It's safer to check if referrer is null before calling contains
		if (referrer == null) {
			// Handle cases where referrer is missing (e.g., direct access, some proxies/browsers)
			message = new Message("Invalid request origin.", "error", "alert-danger");
			session.setAttribute("message", message);
			response.sendRedirect("login.jsp"); // Redirect to a safe default
			return;
		}


		try { // Add a general try-catch block for robustness

			if (referrer.contains("forgot_password.jsp")) { // Be more specific with page names if possible
				// --- Stage 1: Forgot Password - Send OTP ---
				String email = request.getParameter("email");

				// Basic email validation
				if (email == null || email.trim().isEmpty()) {
					message = new Message("Email address is required.", "error", "alert-warning");
					session.setAttribute("message", message);
					response.sendRedirect("forgot_password.jsp");
					return;
				}
				email = email.trim(); // Trim after null/empty check

				List<String> list = userDao.getAllEmail(); // Call DAO method

				if (list != null && list.contains(email)) { // Check if list is not null
					Random rand = new Random();
					int max = 99999, min = 10000;
					int otp = rand.nextInt(max - min + 1) + min;

					session.setAttribute("otp", otp);
					session.setAttribute("email", email); // Store email needed for password update stage

					MailMessenger.sendOtp(email, otp);

					message = new Message("We've sent a password reset code to " + email, "success", "alert-success");
					session.setAttribute("message", message);
					response.sendRedirect("otp_code.jsp"); // Redirect to OTP entry page

				} else {
					message = new Message("Email not found! Please try again.", "error", "alert-danger");
					session.setAttribute("message", message);
					response.sendRedirect("forgot_password.jsp"); // Redirect back
				}
				// No return needed, redirect handles response

			} else if (referrer.contains("otp_code.jsp")) { // Be more specific
				// --- Stage 2: Verify OTP ---
				String codeParam = request.getParameter("code");
				Integer otpFromSession = (Integer) session.getAttribute("otp"); // Get OTP as Integer

				// Validate input and session attribute
				if (codeParam == null || codeParam.trim().isEmpty()) {
					message = new Message("Verification code is required.", "error", "alert-warning");
				} else if (otpFromSession == null) {
					message = new Message("OTP session expired or invalid request. Please start over.", "error", "alert-danger");
					session.removeAttribute("otp"); // Clean up potentially stale attribute
					session.removeAttribute("email");
					response.sendRedirect("forgot_password.jsp"); // Send back to start
					return;
				} else {
					try {
						int enteredCode = Integer.parseInt(codeParam.trim()); // Potential NumberFormatException

						if (enteredCode == otpFromSession) {
							session.removeAttribute("otp"); // Valid code, remove OTP from session
							// Keep email in session for the next step
							// Redirect to the password change form
							response.sendRedirect("change_password.jsp");
							return; // Explicit return after successful redirect
						} else {
							message = new Message("Invalid verification code entered!", "error", "alert-danger");
						}
					} catch (NumberFormatException e) {
						message = new Message("Invalid code format. Please enter numbers only.", "error", "alert-warning");
					}
				}
				session.setAttribute("message", message);
				response.sendRedirect("otp_code.jsp"); // Redirect back to OTP entry page


			} else if (referrer.contains("change_password.jsp")) { // Be more specific
				// --- Stage 3: Change Password ---
				String password = request.getParameter("password");
				String confirmPassword = request.getParameter("confirm_password");
				String emailFromSession = (String) session.getAttribute("email");

				// Validate input and session attribute
				if (password == null || password.isEmpty() || confirmPassword == null || confirmPassword.isEmpty()) {
					message = new Message("Both password fields are required.", "error", "alert-warning");
				} else if (!password.equals(confirmPassword)) {
					message = new Message("Passwords do not match.", "error", "alert-warning");
				} else if (emailFromSession == null) {
					message = new Message("Session expired or invalid request. Please start over.", "error", "alert-danger");
					session.removeAttribute("otp"); // Clean up
					session.removeAttribute("email");
					response.sendRedirect("forgot_password.jsp"); // Send back to start
					return;
				} else {
					// Passwords match and email is in session
					// --- HASH the new password ---
					String hashedNewPassword = PasswordUtil.hashPassword(password);

					boolean success = userDao.updateUserPasswordByEmail(hashedNewPassword, emailFromSession); // Call DAO method


					if (success) {
						message = new Message("Password updated successfully!", "success", "alert-success"); // Corrected type to success
						session.removeAttribute("email"); // Clean up session
						session.removeAttribute("otp"); // Just in case
						session.setAttribute("message", message);
						response.sendRedirect("login.jsp"); // Redirect to login
						return; // Explicit return after successful redirect
					} else {
						message = new Message("Failed to update password. Please try again later.", "error", "alert-danger");
					}
				}
				session.setAttribute("message", message);
				response.sendRedirect("change_password.jsp"); // Redirect back to password change page

			} else {
				// Referrer didn't match expected pages
				message = new Message("Invalid request sequence.", "error", "alert-danger");
				session.setAttribute("message", message);
				response.sendRedirect("login.jsp"); // Redirect to a safe default
			}

		} catch (Exception e) {
			// Catch any unexpected errors during processing
			System.err.println("Error in ChangePasswordServlet: " + e.getMessage());
			e.printStackTrace(); // Log the full error
			message = new Message("An unexpected error occurred. Please try again.", "error", "alert-danger");
			session.setAttribute("message", message);
			// Redirect to a safe place, like the initial forgot password page or login
			response.sendRedirect("forgot_password.jsp");
		}
	}
}