package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

import com.phong.dao.UserDao;
import com.phong.entities.Admin;
import com.phong.entities.Message;
import com.phong.entities.User;
// ConnectionProvider import is no longer needed here
// import com.phong.helper.ConnectionProvider;

public class UpdateUserServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession();
		Message message = null; // Initialize message object

		// --- Instantiate DAO using default constructor ---
		UserDao userDao = new UserDao(); // DAO handles its own connections

		// Get operation parameter
		String op = request.getParameter("operation");

		// Basic validation for operation parameter
		if (op == null || op.trim().isEmpty()) {
			message = new Message("No operation specified.", "error", "alert-warning");
			session.setAttribute("message", message);
			// Redirect to a sensible default page, maybe user profile or home
			response.sendRedirect("profile.jsp"); // Adjust redirect as needed
			return;
		}
		op = op.trim(); // Trim after null check

		// --- Get active user from session (needed for most operations) ---
		User activeUser = (User) session.getAttribute("activeUser");

		// --- Process based on operation ---
		try { // Wrap operations in a try-catch block

			if (op.equals("changeAddress")) {
				// --- Change Address Operation ---

				// Check if user is logged in
				if (activeUser == null) {
					message = new Message("You must be logged in to change your address.", "error", "alert-danger");
					session.setAttribute("message", message);
					response.sendRedirect("login.jsp"); // Redirect to login
					return;
				}

				// Get address parameters
				String userAddress = request.getParameter("user_address");
				String userCity = request.getParameter("city");
				String userPostcode = request.getParameter("postcode");
				String userCounty = request.getParameter("county");

				// Basic validation for address fields (add more as needed)
				if (userAddress == null || userAddress.trim().isEmpty() ||
						userCity == null || userCity.trim().isEmpty() ||
						userPostcode == null || userPostcode.trim().isEmpty() ||
						userCounty == null || userCounty.trim().isEmpty()) {

					message = new Message("All address fields are required.", "error", "alert-warning");
					session.setAttribute("message", message);
					// Redirect back to the form, likely on the checkout page
					response.sendRedirect("checkout.jsp"); // Adjust if form is elsewhere
					return;
				}

				// Create a temporary user object with ONLY the ID and new address details
				// Alternatively, update the activeUser object directly
				activeUser.setUserAddress(userAddress.trim());
				activeUser.setUserCity(userCity.trim());
				activeUser.setUserPostcode(userPostcode.trim());
				activeUser.setUserCounty(userCounty.trim());

				// Call DAO method
				boolean success = userDao.updateUserAddresss(activeUser);

				if (success) {
					// Update the user object in the session IF the DB update was successful
					session.setAttribute("activeUser", activeUser);
					// Set a success message if desired (optional for checkout flow)
					// message = new Message("Address updated successfully.", "success", "alert-success");
					// session.setAttribute("message", message);
					response.sendRedirect("checkout.jsp"); // Proceed to checkout
				} else {
					message = new Message("Failed to update address. Please try again.", "error", "alert-danger");
					session.setAttribute("message", message);
					response.sendRedirect("checkout.jsp"); // Stay on checkout page
				}
				// Redirect handles response flow

			} else if (op.equals("updateUser")) {
				// --- Update User Profile Operation ---

				// Check if user is logged in
				if (activeUser == null) {
					message = new Message("You must be logged in to update your profile.", "error", "alert-danger");
					session.setAttribute("message", message);
					response.sendRedirect("login.jsp"); // Redirect to login
					return;
				}

				// Get profile parameters
				String userName = request.getParameter("name");
				String userEmail = request.getParameter("email");
				String userPhone = request.getParameter("mobile_no");
				String userGender = request.getParameter("gender");
				String userAddress = request.getParameter("address");
				String userCity = request.getParameter("city");
				String userPostcode = request.getParameter("postcode");
				String userCounty = request.getParameter("county");

				// Basic validation (add more as needed)
				if (userName == null || userName.trim().isEmpty() ||
						userEmail == null || userEmail.trim().isEmpty() ||
						userPhone == null || userPhone.trim().isEmpty()) {

					message = new Message("Name, Email, and Phone are required.", "error", "alert-warning");
					session.setAttribute("message", message);
					response.sendRedirect("profile.jsp"); // Redirect back to profile page
					return;
				}

				// Update the existing activeUser object from the session
				activeUser.setUserName(userName.trim());
				activeUser.setUserEmail(userEmail.trim()); // Consider validating email format
				activeUser.setUserPhone(userPhone.trim());
				activeUser.setUserGender((userGender != null) ? userGender.trim() : activeUser.getUserGender()); // Keep old if null
				activeUser.setUserAddress((userAddress != null) ? userAddress.trim() : activeUser.getUserAddress());
				activeUser.setUserCity((userCity != null) ? userCity.trim() : activeUser.getUserCity());
				activeUser.setUserPostcode((userPostcode != null) ? userPostcode.trim() : activeUser.getUserPostcode());
				activeUser.setUserCounty((userCounty != null) ? userCounty.trim() : activeUser.getUserCounty());
				// Keep existing Password and DateTime

				// Call DAO method
				boolean success = userDao.updateUser(activeUser);

				if (success) {
					message = new Message("Profile updated successfully!", "success", "alert-success");
					// Update the user object in the session
					session.setAttribute("activeUser", activeUser);
				} else {
					// Could fail due to DB error or maybe email constraint if email was changed
					message = new Message("Failed to update profile. The email might already be taken, or an error occurred.", "error", "alert-danger");
				}
				session.setAttribute("message", message);
				response.sendRedirect("profile.jsp"); // Redirect back to profile page
				// Redirect handles response flow


			} else if (op.equals("deleteUser")) {
				// --- Delete User Operation (Likely Admin Action) ---

				// !!! SECURITY WARNING: Add access control here! !!!
				// Check if an admin user is logged in before allowing deletion.
                Admin activeAdmin = (Admin) session.getAttribute("activeAdmin");
                if (activeAdmin == null) {
                    message = new Message("Unauthorized operation.", "error", "alert-danger");
                    session.setAttribute("message", message);
                    response.sendRedirect("adminlogin.jsp"); // Or appropriate access denied page
                    return;
                }


				String uidParam = request.getParameter("uid");
				if (uidParam == null || uidParam.trim().isEmpty()) {
					message = new Message("User ID is required for deletion.", "error", "alert-warning");
					session.setAttribute("message", message);
					return;
				}

				int uid = Integer.parseInt(uidParam.trim()); // Potential NumberFormatException

				// Call DAO method
				boolean success = userDao.deleteUser(uid);

				if (success) {
					message = new Message("User deleted successfully!", "success", "alert-success");
				} else {
					message = new Message("Failed to delete user. The user might not exist or an error occurred.", "error", "alert-danger");
				}
				session.setAttribute("message", message);
				// Redirect handles response flow

			} else {
				// --- Unknown Operation ---
				message = new Message("Unknown user operation specified: " + op, "error", "alert-warning");
				session.setAttribute("message", message);
				response.sendRedirect("profile.jsp"); // Redirect to a default page
			}

		} catch (NumberFormatException e) {
			// Specifically for parsing uid in delete operation
			message = new Message("Invalid User ID format.", "error", "alert-danger");
			session.setAttribute("message", message);
		} catch (Exception e) {
			// Catch any other unexpected errors
			System.err.println("Error in UpdateUserServlet (operation: " + op + "): " + e.getMessage());
			e.printStackTrace(); // Log the full error
			message = new Message("An unexpected error occurred. Please try again.", "error", "alert-danger");
			session.setAttribute("message", message);
			// Redirect based on likely context, or a generic error page
			if ("changeAddress".equals(op)) {
				response.sendRedirect("checkout.jsp");
			} else if ("updateUser".equals(op)) {
				response.sendRedirect("profile.jsp");
			} else if ("deleteUser".equals(op)) {
				response.sendRedirect("display_users.jsp");
			} else {
				response.sendRedirect("index.jsp"); // Fallback redirect
			}
		}
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		// Generally unsafe to perform updates/deletes via GET.
		// Forwarding GET to POST might be okay for simple cases, but consider
		// showing an error or redirecting to the relevant form page instead for GET requests.
		doPost(req, resp);
	}
}