package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

import com.phong.dao.CartDao;
import com.phong.dao.ProductDao;
import com.phong.entities.*;
// ConnectionProvider import no longer needed
// import com.phong.helper.ConnectionProvider;

public class CartOperationServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	// Consider using POST for these operations in a real application
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		Message message = null;
		String redirectPage = "cart.jsp"; // Default redirect target

		// --- Instantiate DAOs (Refactored) ---
		CartDao cartDao = new CartDao();
		ProductDao productDao = new ProductDao();

		try {
			// --- Get User ID from Session (Security) ---
			User activeUser = (User) session.getAttribute("activeUser");
			Vendor activeVendor = (Vendor) session.getAttribute("activeVendor"); // Check for vendor
			if (activeUser == null) {
				message = new Message("Please log in to modify your cart.", "error", "alert-danger");
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
			int userId = activeUser.getUserId();

			// --- Get and Validate Parameters ---
			String cidParam = request.getParameter("cid");
			String optParam = request.getParameter("opt");

			if (cidParam == null || cidParam.trim().isEmpty() || optParam == null || optParam.trim().isEmpty()) {
				message = new Message("Missing required parameters for cart operation.", "error", "alert-warning");
				session.setAttribute("message", message);
				response.sendRedirect(redirectPage);
				return;
			}

			int cartId = Integer.parseInt(cidParam.trim()); // Potential NumberFormatException
			int operation = Integer.parseInt(optParam.trim()); // Potential NumberFormatException


			// --- Verify Cart Item Ownership and Get Details ---

			// Fetch the quantity and product ID first (more efficient if ownership check fails)
			int currentCartQty = cartDao.getQuantityById(cartId);
			int productId = cartDao.getProductId(cartId);

			// Check if the cart item exists and belongs to the logged-in user
			if (productId <= 0 || currentCartQty <= 0 || cartDao.getIdByUserIdAndProductId(userId, productId) != cartId) {
				// Either cid was invalid, or pid couldn't be found, or the cid doesn't match the user/pid combo
				message = new Message("Invalid cart item specified or it doesn't belong to you.", "error", "alert-danger");
				session.setAttribute("message", message);
				response.sendRedirect(redirectPage);
				return;
			}


			// --- Get Product Details (for stock check and inventory update) ---
			Product product = productDao.getProductsByProductId(productId);
			if (product == null) {
				// Product associated with cart item doesn't exist anymore? Data inconsistency.
				message = new Message("Associated product not found. Removing invalid cart item.", "error", "alert-danger");
				cartDao.removeProduct(cartId); // Attempt to clean up inconsistent cart item
				session.setAttribute("message", message);
				response.sendRedirect(redirectPage);
				return;
			}
			int currentStock = product.getProductQuantity();


			// --- Perform Operation ---
			boolean cartOpSuccess = false;
			boolean inventoryOpSuccess = false;
			String successMessageContent = "";


			// !! WARNING: Lack of transaction safety between cart and product updates !!
			if (operation == 1) { // Increase Quantity
				if (currentStock <= 0) {
					message = new Message("Cannot increase quantity, product is out of stock.", "error", "alert-warning");
				} else {
					cartOpSuccess = cartDao.updateQuantity(cartId, currentCartQty + 1);
					if (cartOpSuccess) {
						inventoryOpSuccess = productDao.updateQuantity(productId, currentStock - 1); // Decrease stock
						successMessageContent = "Item quantity increased.";
						if (!inventoryOpSuccess) {
							System.err.println("CRITICAL WARNING: Failed to decrease product quantity for PID " + productId + " after increasing cart qty for CID " + cartId);
							successMessageContent += " (Inventory update warning)"; // Append warning
						}
					} else {
						message = new Message("Failed to update cart quantity.", "error", "alert-danger");
					}
				}

			} else if (operation == 2) { // Decrease Quantity
				if (currentCartQty > 1) {
					// Decrease quantity in cart
					cartOpSuccess = cartDao.updateQuantity(cartId, currentCartQty - 1);
					if (cartOpSuccess) {
						inventoryOpSuccess = productDao.updateQuantity(productId, currentStock + 1); // Increase stock
						successMessageContent = "Item quantity decreased.";
						if (!inventoryOpSuccess) {
							System.err.println("CRITICAL WARNING: Failed to increase product quantity for PID " + productId + " after decreasing cart qty for CID " + cartId);
							successMessageContent += " (Inventory update warning)";
						}
					} else {
						message = new Message("Failed to update cart quantity.", "error", "alert-danger");
					}
				} else if (currentCartQty == 1) {
					// Remove item from cart instead of setting quantity to 0
					cartOpSuccess = cartDao.removeProduct(cartId);
					if (cartOpSuccess) {
						inventoryOpSuccess = productDao.updateQuantity(productId, currentStock + 1); // Increase stock (add the one item back)
						successMessageContent = "Item removed from cart.";
						if (!inventoryOpSuccess) {
							System.err.println("CRITICAL WARNING: Failed to increase product quantity for PID " + productId + " after removing cart item CID " + cartId);
							successMessageContent += " (Inventory update warning)";
						}
					} else {
						message = new Message("Failed to remove item from cart.", "error", "alert-danger");
					}
				} else {
					// currentCartQty is 0 or less - data inconsistency
					message = new Message("Invalid cart item quantity detected.", "error", "alert-danger");
					System.err.println("Error: Attempted to decrease quantity for cart item CID " + cartId + " with non-positive quantity: " + currentCartQty);
				}

			} else if (operation == 3) { // Remove Item
				cartOpSuccess = cartDao.removeProduct(cartId);
				if (cartOpSuccess) {
					// Add the quantity that *was* in the cart back to stock
					inventoryOpSuccess = productDao.updateQuantity(productId, currentStock + currentCartQty);
					successMessageContent = "Item removed from cart.";
					if (!inventoryOpSuccess) {
						System.err.println("CRITICAL WARNING: Failed to increase product quantity for PID " + productId + " after removing cart item CID " + cartId + " with quantity " + currentCartQty);
						successMessageContent += " (Inventory update warning)";
					}
				} else {
					message = new Message("Failed to remove item from cart.", "error", "alert-danger");
				}

			} else {
				// Invalid operation code
				message = new Message("Invalid cart operation specified.", "error", "alert-warning");
			}

			// Set final success/warning message if no error message was set
			if (message == null && cartOpSuccess) {
				message = new Message(successMessageContent, inventoryOpSuccess ? "success" : "warning", inventoryOpSuccess ? "alert-success" : "alert-warning");
			}


		} catch (NumberFormatException e) {
			message = new Message("Invalid ID or operation format provided.", "error", "alert-danger");
		} catch (Exception e) {
			System.err.println("Error in CartOperationServlet: " + e.getMessage());
			e.printStackTrace(); // Log full error
			message = new Message("An unexpected error occurred while updating your cart.", "error", "alert-danger");
		}

		// --- Set Message and Redirect ---
		// Ensure message is not null before setting
		if (message == null) {
			message = new Message("Cart operation completed.", "info", "alert-info"); // Fallback message
		}
		session.setAttribute("message", message);
		response.sendRedirect(redirectPage);
	}


	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
}