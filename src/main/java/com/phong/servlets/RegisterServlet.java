package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import com.phong.dao.UserDao;
import com.phong.entities.Message;
import com.phong.entities.User;
import com.phong.helper.MailMessenger;

public class RegisterServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession();
		Message message = null; // Initialize message

		// --- Instantiate UserDao using the default constructor ---
		UserDao userDao = new UserDao(); // DAO handles its own connections now

		try {
			// --- Retrieve Registration Parameters ---
			String userName = request.getParameter("user_name");
			String userEmail = request.getParameter("user_email");
			String userPassword = request.getParameter("user_password"); // Needs Hashing!
			String userPhone = request.getParameter("user_mobile_no");
			String userGender = request.getParameter("gender");
			String userAddress = request.getParameter("user_address");
			String userCity = request.getParameter("city");
			String userPostcode = request.getParameter("postcode");
			String userCounty = request.getParameter("county");

			// --- Basic Input Validation (Add more robust validation as needed) ---
			if (userName == null || userName.trim().isEmpty() ||
					userEmail == null || userEmail.trim().isEmpty() ||
					userPassword == null || userPassword.isEmpty() || // Don't trim password initially
					userPhone == null || userPhone.trim().isEmpty())
			// Add checks for other fields if they are mandatory
			{

				message = new Message("Required fields (Name, Email, Password, Phone) cannot be empty.", "error", "alert-warning");
				session.setAttribute("message", message);
				response.sendRedirect("register.jsp");
				return; // Stop processing if validation fails
			}

			// Trim values after null/empty check (except password initially)
			userName = userName.trim();
			userEmail = userEmail.trim();
			userPhone = userPhone.trim();
			// Trim other optional fields if needed
			userGender = (userGender != null) ? userGender.trim() : null;
			userAddress = (userAddress != null) ? userAddress.trim() : null;
			userCity = (userCity != null) ? userCity.trim() : null;
			userPostcode = (userPostcode != null) ? userPostcode.trim() : null;
			userCounty = (userCounty != null) ? userCounty.trim() : null;


			// --- TODO: Check if user email already exists ---
			// List<String> existingEmails = userDao.getAllEmail();
			// if (existingEmails != null && existingEmails.contains(userEmail)) {
			//     message = new Message("Email address already registered.", "error", "alert-warning");
			//     session.setAttribute("message", message);
			//     response.sendRedirect("register.jsp");
			//     return;
			// }

			// --- IMPORTANT: Hash the password before storing ---
			// String hashedPassword = YourPasswordHashingUtil.hash(userPassword);
			// User user = new User(userName, userEmail, hashedPassword, userPhone, userGender, userAddress, userCity, userPostcode, userCounty);

			// Creating user with plain text password (NOT RECOMMENDED FOR PRODUCTION)
			User user = new User(userName, userEmail, userPassword, userPhone, userGender, userAddress, userCity, userPostcode, userCounty);


			// --- Save User using DAO ---
			boolean flag = userDao.saveUser(user); // Call DAO method

			// --- Set Session Message and Send Mail ---
			if (flag) {
				message = new Message("Registration Successful!", "success", "alert-success"); // Simplified message
				try {
					// Send registration email (handle potential errors in MailMessenger)
					MailMessenger.successfullyRegister(userName, userEmail);
				} catch (Exception mailEx) {
					System.err.println("Warning: Failed to send registration email to " + userEmail + ": " + mailEx.getMessage());
					// Don't necessarily fail the whole registration, but log the mail error
				}
			} else {
				// Failure likely indicates a database issue (e.g., duplicate email if constraint exists)
				message = new Message("Registration failed. The email might already be registered, or an error occurred.", "error", "alert-danger");
			}

			session.setAttribute("message", message);
			response.sendRedirect("register.jsp"); // Redirect back to registration page (which should display the message)
			// No return needed here, redirect handles response flow


		} catch (Exception e) {
			// Catch any unexpected errors during processing
			System.err.println("Error in RegisterServlet: " + e.getMessage());
			e.printStackTrace(); // Log the full error
			message = new Message("An unexpected error occurred during registration. Please try again.", "error", "alert-danger");
			session.setAttribute("message", message);
			response.sendRedirect("register.jsp"); // Redirect back on error
		}
	}
}