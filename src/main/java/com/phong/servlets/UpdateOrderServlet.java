package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession; // Import HttpSession for messages
import java.io.IOException;

import com.phong.dao.OrderDao;
import com.phong.dao.UserDao;
import com.phong.entities.Message; // Import Message for feedback
import com.phong.entities.Order;
// ConnectionProvider import no longer needed here
// import com.phong.helper.ConnectionProvider;
import com.phong.helper.MailMessenger;

public class UpdateOrderServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession();
		Message message = null; // Initialize message object

		// --- Instantiate DAOs using default constructors ---
		// DAOs will manage their own connections internally
		OrderDao orderDao = new OrderDao(); // Assumes OrderDao is refactored
		UserDao userDao = new UserDao();   // Assumes UserDao is refactored

		try {
			// --- Get and Validate Parameters ---
			String oidParam = request.getParameter("oid");
			String status = request.getParameter("status");

			if (oidParam == null || oidParam.trim().isEmpty() || status == null || status.trim().isEmpty()) {
				message = new Message("Order ID and Status are required.", "error", "alert-warning");
				session.setAttribute("message", message);
				response.sendRedirect("display_orders.jsp"); // Redirect back
				return;
			}

			int oid = Integer.parseInt(oidParam.trim()); // Potential NumberFormatException
			status = status.trim(); // Use trimmed status

			// --- Update Order Status ---
			// Assuming updateOrderStatus returns boolean for success/failure
			boolean updateSuccess = orderDao.updateOrderStatus(oid, status);

			if (!updateSuccess) {
				message = new Message("Failed to update order status. Please try again.", "error", "alert-danger");
				session.setAttribute("message", message);
				response.sendRedirect("display_orders.jsp");
				return;
			}

			// Set a default success message
			message = new Message("Order status updated successfully!", "success", "alert-success");


			// --- Send Notification Email if applicable ---
			if (status.equals("Shipped") || status.equals("Out For Delivery")) {
				Order order = orderDao.getOrderById(oid); // Get order details

				if (order != null) {
					// Get user details - handle potential null returns from DAO methods
					String userName = userDao.getUserName(order.getUserId());
					String userEmail = userDao.getUserEmail(order.getUserId());

					if (userName != null && userEmail != null && order.getDate() != null) {
						try {
							MailMessenger.orderShipped(userName, userEmail,
									order.getOrderId(), order.getDate().toString());
							// Optionally add to the success message: " Notification sent."
						} catch (Exception mailEx) {
							System.err.println("Warning: Failed to send order update email for Order ID "
									+ order.getOrderId() + ": " + mailEx.getMessage());
							// Don't fail the whole operation, but maybe add a note to the message?
							message = new Message("Order status updated, but failed to send notification email.", "warning", "alert-warning");
						}
					} else {
						System.err.println("Warning: Could not retrieve user details or order date for Order ID "
								+ order.getOrderId() + " to send notification.");
						message = new Message("Order status updated, but could not retrieve details to send notification.", "warning", "alert-warning");
					}
				} else {
					System.err.println("Warning: Could not retrieve order details for Order ID "
							+ oid + " after status update.");
					message = new Message("Order status updated, but could not retrieve order details for notification.", "warning", "alert-warning");
				}
			}

			// --- Set final message and Redirect ---
			session.setAttribute("message", message);
			response.sendRedirect("display_orders.jsp");


		} catch (NumberFormatException e) {
			message = new Message("Invalid Order ID format.", "error", "alert-danger");
			session.setAttribute("message", message);
			response.sendRedirect("display_orders.jsp");
		} catch (Exception e) {
			// Catch any other unexpected errors
			System.err.println("Error in UpdateOrderServlet: " + e.getMessage());
			e.printStackTrace(); // Log the full error
			message = new Message("An unexpected error occurred while updating the order.", "error", "alert-danger");
			session.setAttribute("message", message);
			response.sendRedirect("display_orders.jsp");
		}
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// Typically, status updates should be POST, but redirecting GET to POST if needed.
		// Consider if GET should show an error or a specific view instead.
		doPost(request, response);
	}
}