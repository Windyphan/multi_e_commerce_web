package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession; // Import HttpSession
import java.io.IOException;

import com.phong.dao.WishlistDao;
import com.phong.entities.Message;   // Import Message
import com.phong.entities.User;      // Import User
import com.phong.entities.Vendor;
import com.phong.entities.Wishlist;
// ConnectionProvider import no longer needed
// import com.phong.helper.ConnectionProvider;

public class WishlistServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	// Using GET for add/remove is not ideal, POST is preferred for state changes.
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession();
		Message message = null;
		String redirectPage = request.getHeader("referer"); // Try to redirect back to previous page
		if (redirectPage == null || redirectPage.isEmpty() || redirectPage.contains("WishlistServlet")) {
			// Fallback if referrer is missing or points to this servlet itself
			redirectPage = "index.jsp";
		}

		// --- Instantiate DAO (Refactored) ---
		WishlistDao wishlistDao = new WishlistDao();

		try {
			// --- Security Check: Get User from Session ---
			User activeUser = (User) session.getAttribute("activeUser");
			Vendor activeVendor = (Vendor) session.getAttribute("activeVendor"); // Check for vendor
			if (activeUser == null) {
				message = new Message("Please log in to manage your wishlist.", "error", "alert-danger");
				session.setAttribute("message", message);
				response.sendRedirect("login.jsp");
				return;
			}
			// Block Vendors from Customer Actions
			if (activeVendor != null) {
				message = new Message("Vendor accounts cannot perform customer actions.", "error", "alert-warning");
				session.setAttribute("message", message);
				response.sendRedirect("vendor_dashboard.jsp"); // Send vendor back to their dashboard
				return; // Stop processing customer action
			}
			// !! Use user ID from session, NOT from request parameter !!
			int userId = activeUser.getUserId();

			// --- Get and Validate Parameters ---
			String pidParam = request.getParameter("pid");
			String op = request.getParameter("op"); // Operation: add, remove, delete

			if (pidParam == null || pidParam.trim().isEmpty() || op == null || op.trim().isEmpty()) {
				message = new Message("Missing required parameters (product id or operation).", "error", "alert-warning");
				session.setAttribute("message", message);
				response.sendRedirect(redirectPage);
				return;
			}

			int productId = Integer.parseInt(pidParam.trim()); // Potential NumberFormatException
			op = op.trim();

			// Set specific redirect pages based on operation context if needed
			if (op.equals("delete")) { // 'delete' operation likely comes from profile page
				redirectPage = "profile.jsp";
			}
			// For 'add'/'remove', redirecting back to the referrer (product list/details) is often desired.


			// --- Perform Operation ---
			boolean success = false;
			String successMessage = "";
			String failureMessage = "";

			if (op.equals("add")) {
				// Check if already exists before adding? Optional, DB might have constrained
				if (wishlistDao.getWishlist(userId, productId)) {
					message = new Message("Item is already in your wishlist.", "info", "alert-info");
					// No need to call DAO again
					success = true; // Treat "already exists" as success in this context
					successMessage = message.getMessage(); // Reuse existing message
				} else {
					Wishlist wishlist = new Wishlist(userId, productId);
					success = wishlistDao.addToWishlist(wishlist);
					successMessage = "Item added to wishlist!";
					failureMessage = "Failed to add item to wishlist.";
				}

			} else if (op.equals("remove") || op.equals("delete")) {
				// Both 'remove' (from product page) and 'delete' (from profile page) do the same DB operation
				success = wishlistDao.deleteWishlist(userId, productId);
				successMessage = "Item removed from wishlist.";
				failureMessage = "Failed to remove item from wishlist.";

			} else {
				message = new Message("Unknown wishlist operation specified.", "error", "alert-warning");
			}

			// Set final message based on success/failure, unless already set (e.g., already exists)
			if (message == null) {
				if (success) {
					message = new Message(successMessage, "success", "alert-success");
				} else {
					message = new Message(failureMessage, "error", "alert-danger");
				}
			}

		} catch (NumberFormatException e) {
			message = new Message("Invalid Product ID format.", "error", "alert-danger");
			redirectPage = "index.jsp"; // Redirect to safe page on bad ID
		} catch (Exception e) {
			System.err.println("Error in WishlistServlet: " + e.getMessage());
			e.printStackTrace(); // Log full error
			message = new Message("An unexpected error occurred. Please try again.", "error", "alert-danger");
			redirectPage = "index.jsp"; // Redirect to safe page on general error
		}

		// --- Set Message and Redirect ---
		session.setAttribute("message", message);
		response.sendRedirect(redirectPage);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// Forward POST to GET, but recommend using POST directly for modifications.
		doGet(request, response);
	}
}