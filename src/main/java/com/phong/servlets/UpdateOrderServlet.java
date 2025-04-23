package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Set; // Use Set for unique vendor IDs
import java.util.HashSet; // Use HashSet
import java.util.stream.Collectors; // For stream processing

import com.phong.dao.OrderDao;
import com.phong.dao.UserDao;
import com.phong.dao.VendorDao; // ** NEW: Import VendorDao **
import com.phong.dao.OrderedProductDao; // ** NEW: Import OrderedProductDao **
import com.phong.entities.Admin; // ** NEW: Import Admin for security check **
import com.phong.entities.Message;
import com.phong.entities.Order;
import com.phong.entities.User;
import com.phong.entities.Vendor; // ** NEW: Import Vendor **
import com.phong.entities.OrderedProduct; // ** NEW: Import OrderedProduct **
import com.phong.helper.MailMessenger;

public class UpdateOrderServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession();
		Message message = null;
		String redirectPage = "display_orders.jsp"; // Default redirect target

		// --- Security Check: Ensure Admin is logged in ---
		Admin activeAdmin = (Admin) session.getAttribute("activeAdmin");
		if (activeAdmin == null) {
			message = new Message("Unauthorized access. Please log in as admin.", "error", "alert-danger");
			session.setAttribute("message", message);
			response.sendRedirect("adminlogin.jsp");
			return;
		}

		// --- Instantiate DAOs ---
		OrderDao orderDao = new OrderDao();
		UserDao userDao = new UserDao();
		OrderedProductDao orderedProductDao = new OrderedProductDao(); // Needed for vendor lookup
		VendorDao vendorDao = new VendorDao(); // Needed for vendor email

		try {
			// --- Get and Validate Parameters ---
			String oidParam = request.getParameter("oid"); // This is the 'order' table primary key 'id'
			String status = request.getParameter("status");

			if (oidParam == null || oidParam.trim().isEmpty() || status == null || status.trim().isEmpty() || "-- Change Status --".equals(status) ) {
				message = new Message("Order ID and a valid Status are required.", "error", "alert-warning");
				// Try to preserve oid in redirect if possible, otherwise just go back
				if (oidParam != null && !oidParam.trim().isEmpty()) redirectPage += "?highlight=" + oidParam.trim();
				session.setAttribute("message", message);
				response.sendRedirect(redirectPage);
				return;
			}

			int orderDbId = Integer.parseInt(oidParam.trim()); // The primary key from 'order' table
			status = status.trim();

			// --- Update Order Status in DB ---
			boolean updateSuccess = orderDao.updateOrderStatus(orderDbId, status);

			if (!updateSuccess) {
				message = new Message("Failed to update order status in database. Order might not exist or status was unchanged.", "error", "alert-danger");
				redirectPage += "?highlight=" + orderDbId;
				session.setAttribute("message", message);
				response.sendRedirect(redirectPage);
				return;
			}

			// Set base success message
			message = new Message("Order status updated successfully!", "success", "alert-success");

			// Notify customer and vendors if status indicates shipment/delivery progress
			if (status.equals("Shipped") || status.equals("Out For Delivery") || status.equals("Delivered")) {
				System.out.println("### UpdateOrderServlet: Status changed to " + status + ", attempting notifications for order DB ID: " + orderDbId);

				// 1. Get Order Details (needed for customer info and Order ID string)
				Order order = orderDao.getOrderById(orderDbId);

				if (order != null) {
					// 2. Get Customer Details
					User customer = userDao.getUserById(order.getUserId()); // Use new method

					// 3. Get Ordered Products to find Vendors involved
					List<OrderedProduct> itemsInOrder = orderedProductDao.getAllOrderedProduct(orderDbId);

					if (itemsInOrder != null && customer != null) {
						// Customer notification (similar to before, potentially new MailMessenger method)
						try {
							System.out.println("### UpdateOrderServlet: Notifying customer " + customer.getUserEmail());
							// MailMessenger.orderStatusUpdate(customer.getUserName(), customer.getUserEmail(), order.getOrderId(), status, order.getDate().toString());
							// Reusing existing shipped notification for simplicity for now:
							if (status.equals("Shipped") || status.equals("Out For Delivery")) {
								MailMessenger.orderShipped(customer.getUserName(), customer.getUserEmail(), order.getOrderId(), order.getDate().toString());
							} // Add specific method for 'Delivered' if needed
						} catch (Exception mailEx) {
							System.err.println("WARNING: Failed to send status update email to customer " + customer.getUserEmail() + " for order " + order.getOrderId() + ": " + mailEx.getMessage());
							// Don't stop, but maybe modify success message
							message = new Message(message.getMessage() + " (Customer email failed)", "warning", "alert-warning");
						}

						// 4. Find Unique Vendors and Notify Them
						Set<Integer> vendorIdsInOrder = itemsInOrder.stream()
								.filter(item -> item.getVendorId() > 0) // Filter out items with no vendor ID (maybe platform items)
								.map(OrderedProduct::getVendorId)
								.collect(Collectors.toSet()); // Get unique vendor IDs

						System.out.println("### UpdateOrderServlet: Found vendor IDs in order: " + vendorIdsInOrder);

						for (int vendorId : vendorIdsInOrder) {
							Vendor vendor = vendorDao.getVendorById(vendorId);
							if (vendor != null && vendor.getBusinessEmail() != null && !vendor.getBusinessEmail().isEmpty()) {
								try {
									System.out.println("### UpdateOrderServlet: Notifying vendor " + vendor.getBusinessEmail());
									// Create a new method in MailMessenger for vendor notifications
									final int currentVendorId = vendorId; // Need final variable for lambda
									List<OrderedProduct> itemsForThisVendor = itemsInOrder.stream()
											.filter(item -> item.getVendorId() == currentVendorId)
											.collect(Collectors.toList());
									MailMessenger.notifyVendorOfStatusUpdate(
											vendor.getShopName(),
											vendor.getBusinessEmail(),
											order.getOrderId(), // Customer facing Order ID
											status,             // The new status
											customer.getUserName(), // Customer name
											itemsForThisVendor  // Only items for this vendor
									);
								} catch (Exception mailEx) {
									System.err.println("WARNING: Failed to send status update email to vendor " + vendor.getBusinessEmail() + " (ID: " + vendorId + ") for order " + order.getOrderId() + ": " + mailEx.getMessage());
									message = new Message(message.getMessage() + " (Vendor email failed)", "warning", "alert-warning");
								}
							} else {
								System.err.println("WARNING: Could not find vendor details or email for vendor ID " + vendorId + " in order " + order.getOrderId());
							}
						} // End vendor loop

					} else {
						System.err.println("WARNING: Could not retrieve customer or items for order " + order.getOrderId() + " to send notifications.");
						message = new Message(message.getMessage() + " (Notification details missing)", "warning", "alert-warning");
					}
				} else {
					System.err.println("WARNING: Could not retrieve order details for ID " + orderDbId + " after status update.");
					message = new Message(message.getMessage() + " (Order details missing)", "warning", "alert-warning");
				}
			} // End notification check


			// --- Set final message and Redirect ---
			session.setAttribute("message", message);
			response.sendRedirect(redirectPage);


		} catch (NumberFormatException e) {
			message = new Message("Invalid Order ID format.", "error", "alert-danger");
			session.setAttribute("message", message);
			response.sendRedirect(redirectPage); // Redirect back to order list
		} catch (Exception e) {
			System.err.println("Error in UpdateOrderServlet: " + e.getMessage());
			e.printStackTrace();
			message = new Message("An unexpected error occurred while updating the order.", "error", "alert-danger");
			session.setAttribute("message", message);
			response.sendRedirect(redirectPage); // Redirect back to order list
		}
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// Updates should be POST
		HttpSession session = request.getSession();
		Message message = new Message("Invalid request method for order update.", "error", "alert-warning");
		session.setAttribute("message", message);
		response.sendRedirect("display_orders.jsp");
	}

}