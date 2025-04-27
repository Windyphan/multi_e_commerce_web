package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap; // Import HashMap
import java.util.Map;     // Import Map

// --- IMPORT Jackson ObjectMapper ---
import com.fasterxml.jackson.databind.ObjectMapper;

import com.phong.dao.AdminDao;
import com.phong.entities.Admin;

public class AdminServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	// --- Instantiate ObjectMapper ---
	private final ObjectMapper objectMapper = new ObjectMapper(); // Create an ObjectMapper instance

	protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		// --- Set response type to JSON ---
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		PrintWriter out = response.getWriter();

		Map<String, Object> jsonResponse = new HashMap<>();
		String status = "error";
		String message = "An unexpected error occurred.";

		String operation = request.getParameter("operation");

		if (operation == null || operation.trim().isEmpty()) {
			status = "error";
			message = "No operation specified.";
			jsonResponse.put("status", status);
			jsonResponse.put("message", message);
			// --- Use ObjectMapper to write JSON ---
			out.print(objectMapper.writeValueAsString(jsonResponse));
			out.flush();
			return;
		}

		operation = operation.trim();
		AdminDao adminDao = new AdminDao();

		try {
			if (operation.equals("save")) {
				String name = request.getParameter("name");
				String email = request.getParameter("email");
				String password = request.getParameter("password");
				String phone = request.getParameter("phone");

				if (name == null || email == null || password == null || phone == null ||
						name.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty() || phone.trim().isEmpty()) {
					status = "error";
					message = "All fields (name, email, password, phone) are required.";
				} else {
					Admin admin = new Admin(name, email, phone, password);
					boolean flag = adminDao.saveAdmin(admin); // Call DAO method

					if (flag) {
						status = "success";
						message = "New admin registered successfully!";
						jsonResponse.put("newAdmin", admin);
					} else {
						status = "error";
						message = "Sorry! Could not save the admin. Email might be taken or DB error.";
					}
				}

			} else if (operation.equals("delete")) {
				// ... (Delete logic remains the same) ...
				String idParam = request.getParameter("id");
				if (idParam == null || idParam.trim().isEmpty()) {
					status = "error";
					message = "Admin ID is required for deletion.";
				} else {
					try {
						int id = Integer.parseInt(idParam);
						boolean flag = adminDao.deleteAdmin(id);

						if (flag) {
							status = "success";
							message = "Admin deleted successfully!";
							jsonResponse.put("deletedId", id);
						} else {
							status = "error";
							message = "Sorry! Could not delete the admin. It might not exist.";
						}
					} catch (NumberFormatException e) {
						status = "error";
						message = "Invalid Admin ID format provided.";
					}
				}

			} else {
				status = "error";
				message = "Unknown operation specified: " + operation;
			}
		} catch (Exception e) {
			status = "error";
			message = "Server error during operation: " + e.getMessage();
			System.err.println("Error during admin " + operation + " processing: " + e.getMessage());
			e.printStackTrace();
		}

		jsonResponse.put("status", status);
		jsonResponse.put("message", message);
		// --- Use ObjectMapper to write JSON ---
		// writeValueAsString converts the Java object (Map) to a JSON String
		out.print(objectMapper.writeValueAsString(jsonResponse));
		out.flush();
	}


	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		processRequest(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		processRequest(request, response);
	}
}