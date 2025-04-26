package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import com.phong.dao.AdminDao;
import com.phong.entities.Admin;
import com.phong.entities.Message;
// ConnectionProvider import is no longer strictly necessary here,
// as AdminDao now handles getting the connection internally.
// import com.phong.helper.ConnectionProvider;

public class AdminServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		HttpSession session = request.getSession();
		Message message = null; // Initialize message object

		// --- Instantiate DAO using the default constructor ---
		// The DAO will get its own connection when its methods are called.
		AdminDao adminDao = new AdminDao();

		// --- Get operation parameter ---
		String operation = request.getParameter("operation");

		// --- Basic validation for operation parameter ---
		if (operation == null || operation.trim().isEmpty()) {
			message = new Message("No operation specified.", "error", "alert-warning");
			session.setAttribute("message", message);
			response.sendRedirect("admin.jsp"); // Redirect even if operation is invalid
			return; // Stop further processing
		}

		// Trim operation here
		operation = operation.trim();

		// --- Process based on operation ---
		if (operation.equals("save")) {
			// --- Save Operation ---
			try {
				String name = request.getParameter("name");
				String email = request.getParameter("email");
				String password = request.getParameter("password"); // Remember to handle passwords securely!
				String phone = request.getParameter("phone");

				// Add basic validation for parameters
				if (name == null || email == null || password == null || phone == null ||
						name.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty() || phone.trim().isEmpty()) {
					message = new Message("All fields (name, email, password, phone) are required for saving.", "error", "alert-warning");
				} else {
					Admin admin = new Admin(name, email, phone, password);
					boolean flag = adminDao.saveAdmin(admin); // Call DAO method

					if (flag) {
						message = new Message("New admin registered successfully!", "success", "alert-success");
					} else {
						// Failure likely indicates a database issue caught within the DAO
						message = new Message("Sorry! Could not save the admin. Please check server logs.", "error", "alert-danger");
					}
				}
			} catch (Exception e) {
				// Catch potential errors during parameter retrieval or unexpected issues
				message = new Message("An unexpected error occurred during the save operation.", "error", "alert-danger");
				System.err.println("Error during admin save processing: " + e.getMessage());
				e.printStackTrace(); // Log the full error
			}

		} else if (operation.equals("delete")) {
			// --- Delete Operation ---
			try {
				// Validate and parse the ID
				String idParam = request.getParameter("id");
				if (idParam == null || idParam.trim().isEmpty()) {
					message = new Message("Admin ID is required for deletion.", "error", "alert-warning");
				} else {
					int id = Integer.parseInt(idParam); // Potential NumberFormatException
					boolean flag = adminDao.deleteAdmin(id); // Call DAO method

					if (flag) {
						message = new Message("Admin deleted successfully!", "success", "alert-success");
					} else {
						// Failure could mean ID not found or DB error
						message = new Message("Sorry! Could not delete the admin. It might not exist or an error occurred.", "error", "alert-danger");
					}
				}
			} catch (NumberFormatException e) {
				message = new Message("Invalid Admin ID format provided.", "error", "alert-warning");
			} catch (Exception e) {
				// Catch potential errors during parameter retrieval or unexpected issues
				message = new Message("An unexpected error occurred during the delete operation.", "error", "alert-danger");
				System.err.println("Error during admin delete processing: " + e.getMessage());
				e.printStackTrace(); // Log the full error
			}

		} else {
			// --- Unknown Operation ---
			message = new Message("Unknown operation specified: " + operation, "error", "alert-warning");
		}

		// --- Set message (if generated) and redirect ---
		if (message != null) {
			session.setAttribute("message", message);
		} else {
			// This case should ideally not happen if logic above is sound, but good to be aware
			System.err.println("Warning: No message was generated for operation: " + operation);
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// Simply delegate POST requests to the doGet method for this servlet's logic
		doGet(request, response);
	}
}