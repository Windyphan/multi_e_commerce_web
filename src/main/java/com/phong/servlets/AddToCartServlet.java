package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

import com.phong.dao.CartDao;
import com.phong.dao.ProductDao;
import com.phong.entities.Cart;
import com.phong.entities.Message;
import com.phong.entities.Product; // Import Product entity
import com.phong.entities.User;    // Import User entity
// ConnectionProvider import no longer needed
// import com.phong.helper.ConnectionProvider;

public class AddToCartServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		Message message = null;
		String redirectPage = "index.jsp"; // Default redirect

		// --- Instantiate DAOs (Refactored) ---
		CartDao cartDao = new CartDao();
		ProductDao productDao = new ProductDao();

		try {
			// --- Get User ID from Session (Security) ---
			User activeUser = (User) session.getAttribute("activeUser");
			if (activeUser == null) {
				message = new Message("You must be logged in to add items to the cart.", "error", "alert-danger");
				session.setAttribute("message", message);
				response.sendRedirect("login.jsp");
				return;
			}
			int userId = activeUser.getUserId(); // Use ID from logged-in user

			// --- Get and Validate Product ID ---
			String pidParam = request.getParameter("pid");
			if (pidParam == null || pidParam.trim().isEmpty()) {
				message = new Message("Product ID is missing.", "error", "alert-warning");
				session.setAttribute("message", message);
				response.sendRedirect(redirectPage); // Redirect back (e.g., index or previous page)
				return;
			}
			int productId = Integer.parseInt(pidParam.trim()); // Potential NumberFormatException

			// Set redirectPage to the product page for context
			redirectPage = "viewProduct.jsp?pid=" + productId;

			// --- Check Product Existence and Stock ---
			Product product = productDao.getProductsByProductId(productId);
			if (product == null) {
				message = new Message("Product not found.", "error", "alert-danger");
				session.setAttribute("message", message);
				response.sendRedirect("index.jsp"); // Product doesn't exist, redirect to index
				return;
			}

			int currentStock = product.getProductQuantity(); // Use getter from Product entity
			if (currentStock <= 0) {
				message = new Message("Sorry, this product is currently out of stock.", "error", "alert-warning");
				session.setAttribute("message", message);
				response.sendRedirect(redirectPage); // Stay on product page, show out of stock
				return;
			}


			// --- Add or Update Cart Logic ---
			int currentCartQty = cartDao.getQuantity(userId, productId);
			boolean cartUpdateSuccess = false;

			if (currentCartQty == 0) {
				// Add new item to cart
				Cart cart = new Cart(userId, productId, 1); // Always add quantity 1 initially
				cartUpdateSuccess = cartDao.addToCart(cart);
				if (cartUpdateSuccess) {
					message = new Message("Product added to cart successfully!", "success", "alert-success");
				} else {
					message = new Message("Failed to add product to cart. Please try again.", "error", "alert-danger");
				}
			} else {
				// Increase quantity in existing cart item
				int cartId = cartDao.getIdByUserIdAndProductId(userId, productId);
				if (cartId > 0) { // Check if we found the cart item id
					// Check if adding one more exceeds stock? Optional, depends on requirements.
					// if (currentCartQty + 1 > currentStock) { ... handle ... }

					cartUpdateSuccess = cartDao.updateQuantity(cartId, currentCartQty + 1);
					if (cartUpdateSuccess) {
						message = new Message("Product quantity increased in your cart!", "success", "alert-success");
					} else {
						message = new Message("Failed to update product quantity in cart.", "error", "alert-danger");
					}
				} else {
					// This case shouldn't happen if currentCartQty > 0, but handle defensively
					message = new Message("Could not find existing cart item to update.", "error", "alert-danger");
					System.err.println("Cart inconsistency: getQuantity > 0 but getIdByUserIdAndProductId <= 0 for user " + userId + ", product " + productId);
				}
			}

			// --- Update Product Inventory (only if cart operation succeeded) ---
			// !! WARNING: This still lacks transaction safety !!
			if (cartUpdateSuccess) {
				boolean inventoryUpdateSuccess = productDao.updateQuantity(productId, currentStock - 1); // Use stock fetched earlier
				if (!inventoryUpdateSuccess) {
					// Log this error, it's important! Order might be inconsistent.
					System.err.println("CRITICAL WARNING: Failed to decrease product quantity for PID " + productId + " after successful cart update for user " + userId);
					// Optionally inform user, though it might be confusing
					message = new Message(message.getMessage() + " (Inventory update warning)", "warning", "alert-warning"); // Append warning
				}
			}


		} catch (NumberFormatException e) {
			message = new Message("Invalid Product ID format.", "error", "alert-danger");
			// Don't have pid here reliably, redirect to index
			redirectPage = "index.jsp";
		} catch (Exception e) {
			System.err.println("Error in AddToCartServlet: " + e.getMessage());
			e.printStackTrace(); // Log full error
			message = new Message("An unexpected error occurred. Please try again.", "error", "alert-danger");
			// Redirect to index as context might be lost
			redirectPage = "index.jsp";
		}

		// --- Set Message and Redirect ---
		session.setAttribute("message", message);
		response.sendRedirect(redirectPage); // Redirect back to product page or index on error
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		// Adding items to cart via GET is not recommended.
		HttpSession session = req.getSession();
		Message message = new Message("Invalid request method to add item to cart.", "error", "alert-danger");
		session.setAttribute("message", message);
		// Redirect to index or referrer if available and safe
		resp.sendRedirect("index.jsp");
	}
}