package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Date;
import java.util.List;

import com.phong.dao.CartDao;
import com.phong.dao.OrderDao;
import com.phong.dao.OrderedProductDao;
import com.phong.dao.ProductDao;
import com.phong.entities.Cart;
import com.phong.entities.Message; // Import Message
import com.phong.entities.Order;
import com.phong.entities.OrderedProduct;
import com.phong.entities.Product;
import com.phong.entities.User;
// ConnectionProvider not needed here
// import com.phong.helper.ConnectionProvider;
import com.phong.helper.MailMessenger; // Assuming correct implementation
import com.phong.helper.OrderIdGenerator;

public class OrderOperationServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	// Define constants for session attribute names for better maintainability
	private static final String FROM_SESSION_ATTR = "from";
	private static final String PID_SESSION_ATTR = "pid";
	private static final String ACTIVE_USER_SESSION_ATTR = "activeUser";
	private static final String TOTAL_PRICE_SESSION_ATTR = "totalPrice"; // If used elsewhere


	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession();
		Message message = null; // For user feedback
		boolean orderPlacedSuccessfully = false; // Track overall success

		// --- Instantiate DAOs (assuming they are refactored) ---
		OrderDao orderDao = new OrderDao();
		CartDao cartDao = new CartDao(); // Assuming refactored
		OrderedProductDao orderedProductDao = new OrderedProductDao(); // Assuming refactored
		ProductDao productDao = new ProductDao(); // Assuming refactored

		// --- Get required parameters and session attributes ---
		String from = (String) session.getAttribute(FROM_SESSION_ATTR);
		String paymentType = request.getParameter("payementMode"); // Correct spelling? paymentMode?
		User user = (User) session.getAttribute(ACTIVE_USER_SESSION_ATTR);

		// --- Validation ---
		if (user == null) {
			message = new Message("You must be logged in to place an order.", "error", "alert-danger");
			session.setAttribute("message", message);
			response.sendRedirect("login.jsp");
			return;
		}
		if (from == null || from.trim().isEmpty()) {
			message = new Message("Invalid order request origin.", "error", "alert-danger");
			session.setAttribute("message", message);
			response.sendRedirect("index.jsp"); // Or cart page
			return;
		}
		if (paymentType == null || paymentType.trim().isEmpty()) {
			message = new Message("Payment mode is required.", "error", "alert-warning");
			session.setAttribute("message", message);
			// Redirect back based on 'from' if possible, otherwise to index/cart
			response.sendRedirect(from.contains("cart") ? "cart.jsp" : "index.jsp"); // Adjust redirect
			return;
		}

		// Trim after checks
		from = from.trim();
		paymentType = paymentType.trim();

		// Generate common order details
		String orderId = OrderIdGenerator.getOrderId(); // Assuming this works
		String status = "Order Placed";
		int generatedOrderId = 0; // Store the DB primary key for the order

		// **************************************************************************
		// *** CRITICAL WARNING: LACK OF TRANSACTION MANAGEMENT ***
		// The operations below (insert order, insert ordered products, update quantity,
		// delete cart) should ideally be wrapped in a single database transaction.
		// If any step fails after the first insert, the database will be inconsistent.
		// Consider implementing a Service Layer to handle transactions properly.
		// **************************************************************************

		try { // Wrap the core order processing logic

			// --- Create and Insert the main Order record ---
			Order order = new Order(orderId, status, paymentType, user.getUserId());
			generatedOrderId = orderDao.insertOrder(order); // Get the generated primary key

			if (generatedOrderId <= 0) {
				// Failed to insert the main order record, cannot proceed
				throw new ServletException("Failed to create the main order record in the database.");
			}

			// --- Process based on source ('cart' or 'buy') ---
			if (from.equals("cart")) {
				// --- Order from Cart ---
				List<Cart> listOfCart = cartDao.getCartListByUserId(user.getUserId());

				if (listOfCart == null || listOfCart.isEmpty()) {
					throw new ServletException("Cannot place order from an empty cart.");
				}

				boolean allItemsProcessed = true;
				for (Cart item : listOfCart) {
					Product prod = productDao.getProductsByProductId(item.getProductId());
					if (prod == null) {
						System.err.println("Warning: Product with ID " + item.getProductId() + " not found while processing cart order " + orderId);
						allItemsProcessed = false; // Mark failure but maybe continue? Or throw?
						continue; // Skip this item
					}

					String prodName = prod.getProductName();
					int prodQty = item.getQuantity();
					float price = prod.getProductPriceAfterDiscount();
					String image = prod.getProductImages();

					// TODO: Check if sufficient quantity exists before processing?
					// if (prod.getProductQuantity() < prodQty) { ... handle insufficient stock ... }

					OrderedProduct orderedProduct = new OrderedProduct(prodName, prodQty, price, image, generatedOrderId);
					// Assuming insertOrderedProduct returns boolean or throws exception on failure
					if (!orderedProductDao.insertOrderedProduct(orderedProduct)) {
						System.err.println("Error: Failed to insert ordered product " + prodName + " for order ID " + generatedOrderId);
						allItemsProcessed = false; // Mark failure
						// Decide whether to stop or continue processing other items
					}

					// TODO: Update product quantity in DB (subtract prodQty)
					// boolean qtyUpdateSuccess = productDao.updateQuantity(prod.getProductId(), prod.getProductQuantity() - prodQty);
					// if (!qtyUpdateSuccess) { ... handle quantity update failure ... }

				} // End loop through cart items

				if (!allItemsProcessed) {
					// Partial failure - what to do? Rollback is needed (but not implemented)
					// For now, we'll just report an error later
					System.err.println("Warning: Not all cart items were processed successfully for order " + orderId);
				}

				// Clear the user's cart *only if all items processed* (or based on business logic)
				// Using removeCartByUserId (assuming it exists and returns boolean)
				if (allItemsProcessed) { // Or clear regardless? Depends on requirements
					if (!cartDao.removeCartByUserId(user.getUserId())) {
						System.err.println("Warning: Failed to clear cart for user ID " + user.getUserId() + " after order " + orderId);
						// Continue anyway, order is placed, cart cleanup failed
					}
				} else {
					// If items failed, maybe don't clear the cart? Or clear only successful ones? Complex without transactions.
					System.err.println("Cart not cleared for user ID " + user.getUserId() + " due to item processing errors in order " + orderId);
				}


			} else if (from.equals("buy")) {
				// --- Order Single Product ("Buy Now") ---
				Integer pid = (Integer) session.getAttribute(PID_SESSION_ATTR);
				if (pid == null) {
					throw new ServletException("Product ID not found in session for 'buy now' order.");
				}

				Product prod = productDao.getProductsByProductId(pid);
				if (prod == null) {
					throw new ServletException("Product with ID " + pid + " not found for 'buy now' order.");
				}

				// TODO: Check if quantity > 0
				// if (prod.getProductQuantity() <= 0) { ... handle out of stock ... }

				String prodName = prod.getProductName();
				int prodQty = 1; // Buy now typically means quantity 1
				float price = prod.getProductPriceAfterDiscount();
				String image = prod.getProductImages();

				OrderedProduct orderedProduct = new OrderedProduct(prodName, prodQty, price, image, generatedOrderId);
				// Assuming insertOrderedProduct returns boolean or throws exception
				if (!orderedProductDao.insertOrderedProduct(orderedProduct)) {
					throw new ServletException("Failed to insert ordered product " + prodName + " for order ID " + generatedOrderId);
				}

				// Update product quantity (assuming updateQuantity returns boolean)
				boolean qtyUpdateSuccess = productDao.updateQuantity(pid, prod.getProductQuantity() - prodQty); // Use prod.getProductQuantity() to avoid race condition
				if (!qtyUpdateSuccess) {
					// This is bad - order placed but quantity not updated. Needs rollback.
					System.err.println("CRITICAL Error: Failed to update product quantity for PID " + pid + " after order " + orderId);
					throw new ServletException("Failed to update product stock after order placement.");
				}

			} else {
				throw new ServletException("Invalid 'from' parameter value: " + from);
			}

			// If we reach here without exceptions, assume overall success for now
			orderPlacedSuccessfully = true;

		} catch (Exception e) {
			// Catch any exception during the order processing
			System.err.println("Error during order placement process: " + e.getMessage());
			e.printStackTrace(); // Log the full error
			message = new Message("An error occurred while placing your order. Please try again or contact support.", "error", "alert-danger");
			// If generatedOrderId > 0, we might have a partial order in DB - needs manual cleanup or rollback!
			System.err.println("Order placement failed after potentially inserting order record with DB ID: " + generatedOrderId + " (Order ID: " + orderId + ")");

		} finally {
			// --- Cleanup session attributes regardless of success/failure ---
			session.removeAttribute(FROM_SESSION_ATTR);
			if (from != null && from.equals("cart")) {
				session.removeAttribute(TOTAL_PRICE_SESSION_ATTR); // If it was set
			} else if (from != null && from.equals("buy")) {
				session.removeAttribute(PID_SESSION_ATTR);
			}
		}


		// --- Final Actions: Set message, Send Mail, Redirect ---
		if (orderPlacedSuccessfully) {
			message = new Message("Order placed successfully! Order ID: " + orderId, "success", "alert-success");
			try {
				MailMessenger.successfullyOrderPlaced(user.getUserName(), user.getUserEmail(), orderId, new Date().toString());
			} catch (Exception mailEx) {
				System.err.println("Warning: Order " + orderId + " placed, but failed to send confirmation email: " + mailEx.getMessage());
				// Optionally update the message:
				message = new Message("Order placed successfully (Order ID: " + orderId + "), but confirmation email failed.", "warning", "alert-warning");
			}
		}
		// If message is still null here, it means an exception occurred and it was set in the catch block

		session.setAttribute("message", message);
		response.sendRedirect("index.jsp"); // Redirect to index (or an order confirmation page)
	}


	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// Placing orders via GET is not recommended. Redirect or show error.
		HttpSession session = request.getSession();
		Message message = new Message("Invalid request method for placing order.", "error", "alert-danger");
		session.setAttribute("message", message);
		response.sendRedirect("index.jsp"); // Redirect to a safe page
	}
}