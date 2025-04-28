package com.phong.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.util.stream.Collectors;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession; // Still needed for session check

import com.fasterxml.jackson.databind.ObjectMapper;
import com.phong.dao.OrderDao;
import com.phong.dao.UserDao;
import com.phong.dao.VendorDao;
import com.phong.dao.OrderedProductDao;
import com.phong.entities.Admin;
import com.phong.entities.Order;
import com.phong.entities.User;
import com.phong.entities.Vendor;
import com.phong.entities.OrderedProduct;
import com.phong.helper.MailMessenger;

@MultipartConfig
public class UpdateOrderServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private final ObjectMapper mapper = new ObjectMapper(); // Reuse ObjectMapper instance

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession();
		Map<String, Object> responseMap = new HashMap<>(); // Prepare response map

		// --- Security Check: Ensure Admin is logged in ---
		Admin activeAdmin = (Admin) session.getAttribute("activeAdmin");
		if (activeAdmin == null) {
			// For AJAX, it's better to send a 401/403 Unauthorized status
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 401
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			responseMap.put("status", "error");
			responseMap.put("message", "Unauthorized access. Please log in as admin.");
			try (PrintWriter out = response.getWriter()) {
				mapper.writeValue(out, responseMap);
				out.flush();
			}
			return; // Stop processing
		}

		// --- Instantiate DAOs ---
		OrderDao orderDao = new OrderDao();
		UserDao userDao = new UserDao();
		OrderedProductDao orderedProductDao = new OrderedProductDao();
		VendorDao vendorDao = new VendorDao();

		// --- Default response to error until success ---
		response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
		responseMap.put("status", "error");
		responseMap.put("message", "An internal error occurred."); // Default error

		try {
			// --- Get and Validate Parameters ---
			String oidParam = request.getParameter("oid");
			String status = request.getParameter("status");

			if (oidParam == null || oidParam.trim().isEmpty() || status == null || status.trim().isEmpty() || "-- Change Status --".equals(status)) {
				response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 400 Bad Request
				responseMap.put("message", "Order ID and a valid Status are required. Status:" + status + " OrderId:" + oidParam + "Request" + request);
				try (PrintWriter out = response.getWriter()) {
					mapper.writeValue(out, responseMap);
					out.flush();
				} catch (IOException ioEx) { /* log */ }
				return; // <--- EXIT HERE after sending error

			}

			int orderDbId = 0; // Initialize
			try {
				orderDbId = Integer.parseInt(oidParam.trim());
			} catch (NumberFormatException nfe) {
				response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 400 Bad Request
				responseMap.put("message", "Invalid Order ID format.");
				System.err.println("NumberFormatException in UpdateOrderServlet: " + nfe.getMessage());
				// Write JSON response and return immediately
				try (PrintWriter out = response.getWriter()) { mapper.writeValue(out, responseMap); out.flush(); } catch (IOException ioEx) { /* log */ }
				return; // <--- EXIT HERE
			}

			status = status.trim();

			// --- Update Order Status in DB ---
			boolean updateSuccess = orderDao.updateOrderStatus(orderDbId, status);

			if (updateSuccess) {
				// --- Prepare SUCCESS response data ---
				response.setStatus(HttpServletResponse.SC_OK); // 200 OK
				responseMap.put("status", "success");
				// Start with base success message, append warnings later if needed
				StringBuilder responseMessageBuilder = new StringBuilder("Order status updated successfully!");
				responseMap.put("orderId", orderDbId);
				responseMap.put("newStatus", status);

				// --- Trigger Notifications (Handle errors locally) ---
				boolean customerNotifyFailed = false;
				boolean vendorNotifyFailed = false;

				if (status.equals("Shipped") || status.equals("Out For Delivery") || status.equals("Delivered")) {
					System.out.println("### UpdateOrderServlet: Status changed, attempting notifications for order DB ID: " + orderDbId);
					Order order = orderDao.getOrderById(orderDbId);
					if (order != null) {
						User customer = userDao.getUserById(order.getUserId());
						List<OrderedProduct> itemsInOrder = orderedProductDao.getAllOrderedProduct(orderDbId);

						if (itemsInOrder != null && customer != null) {
							// Notify Customer
							try {
								System.out.println("### UpdateOrderServlet: Notifying customer " + customer.getUserEmail());
								if (status.equals("Shipped") || status.equals("Out For Delivery")) {
									MailMessenger.orderShipped(customer.getUserName(), customer.getUserEmail(), order.getOrderId(), order.getDate().toString());
								} // Add specific Delivered notification?
							} catch (Exception mailEx) {
								customerNotifyFailed = true;
								System.err.println("WARNING: Failed customer email for order " + order.getOrderId() + ": " + mailEx.getMessage());
							}

							// Notify Vendors
							Set<Integer> vendorIdsInOrder = itemsInOrder.stream()
									.filter(item -> item.getVendorId() > 0).map(OrderedProduct::getVendorId)
									.collect(Collectors.toSet());
							System.out.println("### UpdateOrderServlet: Found vendor IDs: " + vendorIdsInOrder);

							for (int vendorId : vendorIdsInOrder) {
								Vendor vendor = vendorDao.getVendorById(vendorId);
								if (vendor != null && vendor.getBusinessEmail() != null && !vendor.getBusinessEmail().isEmpty()) {
									try {
										System.out.println("### UpdateOrderServlet: Notifying vendor " + vendor.getBusinessEmail());
										final int currentVendorId = vendorId;
										List<OrderedProduct> itemsForThisVendor = itemsInOrder.stream()
												.filter(item -> item.getVendorId() == currentVendorId)
												.collect(Collectors.toList());
										MailMessenger.notifyVendorOfStatusUpdate(vendor.getShopName(), vendor.getBusinessEmail(), order.getOrderId(), status, customer.getUserName(), itemsForThisVendor);
									} catch (Exception mailEx) {
										vendorNotifyFailed = true;
										System.err.println("WARNING: Failed vendor email for vendor " + vendorId + " order " + order.getOrderId() + ": " + mailEx.getMessage());
									}
								}  else {
									System.err.println("WARNING: Could not find vendor details or email for vendor ID " + vendorId + " in order " + order.getOrderId());
								}
							} // End vendor loop

						} else {
							System.err.println("WARNING: Could not retrieve customer or items for order " + order.getOrderId() + " to send notifications.");
							response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR); // 500 or maybe 400 if it just means no rows affected?
							responseMap.put("message", "Failed to update order status in database (Notification details missing).");
						}
					} else {
						System.err.println("WARNING: Could not retrieve order details for ID " + orderDbId + " after status update.");
						response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR); // 500 or maybe 400 if it just means no rows affected?
						responseMap.put("message", "Failed to update order status in database (Order details missing).");
					}
				} // End notification check

				// Append warnings to success message if needed
				if (customerNotifyFailed && vendorNotifyFailed) {
					responseMessageBuilder.append(" (Warning: Customer and Vendor email notifications failed)");
				} else if (customerNotifyFailed) {
					responseMessageBuilder.append(" (Warning: Customer email notification failed)");
				} else if (vendorNotifyFailed) {
					responseMessageBuilder.append(" (Warning: Vendor email notification failed)");
				}
				responseMap.put("message", responseMessageBuilder.toString()); // Put final message in map

			} else { // updateSuccess was false
				response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR); // 500 or maybe 400 if it just means no rows affected?
				responseMap.put("message", "Failed to update order status in database (Order might not exist or status was unchanged).");
				// Keep status="error" from default
			}

		} catch (NumberFormatException e) {
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 400 Bad Request
			responseMap.put("message", "Invalid Order ID format.");
			System.err.println("NumberFormatException in UpdateOrderServlet: " + e.getMessage());
		} catch (Exception e) {
			// Status already set to 500 (default)
			responseMap.put("message", "An unexpected error occurred: " + e.getMessage());
			System.err.println("Error in UpdateOrderServlet: " + e.getMessage());
			e.printStackTrace();
		} finally { // Ensure JSON is always written
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			System.out.println("!!! UpdateOrderServlet: Writing JSON response: " + responseMap + " with Status: " + response.getStatus()); // Log final response
			try (PrintWriter out = response.getWriter()) {
				mapper.writeValue(out, responseMap);
				out.flush();
			} catch (IOException ioError) {
				// Log error if writing response fails itself
				System.err.println("!!! UpdateOrderServlet: FAILED to write final JSON response: " + ioError.getMessage());
			}
		}
	} // End doPost

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// Send proper error response for GET
		response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED); // 405 Method Not Allowed
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		Map<String, Object> errorMap = new HashMap<>();
		errorMap.put("status", "error");
		errorMap.put("message", "Invalid request method for order update.");
		try (PrintWriter out = response.getWriter()) {
			mapper.writeValue(out, errorMap);
			out.flush();
		}
	}
}