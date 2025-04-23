package com.phong.servlets;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.phong.dao.VendorDao;
import com.phong.entities.Message;
import com.phong.entities.Vendor;

public class VendorProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Message message = null;
        String redirectPage = "vendor_profile.jsp"; // Redirect back to profile page

        // --- Security Check: Ensure VENDOR is logged in and approved ---
        Vendor activeVendor = (Vendor) session.getAttribute("activeVendor");
        if (activeVendor == null || !activeVendor.isApproved()) {
            message = new Message("Access Denied. Please log in as an approved vendor.", "error", "alert-danger");
            session.setAttribute("message", message);
            response.sendRedirect("vendor_login.jsp");
            return;
        }

        // --- Get Operation ---
        String operation = request.getParameter("operation");

        // --- Process Operation ---
        if ("updateShopDetails".equals(operation)) {
            try {
                // --- Get Parameters ---
                // Get vendorId from hidden field FOR VERIFICATION, use ID from session for safety
                int formVendorId = Integer.parseInt(request.getParameter("vendorId"));
                String shopName = request.getParameter("shop_name");
                String businessEmail = request.getParameter("business_email");
                String businessPhone = request.getParameter("business_phone");
                // Get other editable fields if you added them (e.g., description)

                // --- Validation ---
                if (shopName == null || shopName.trim().isEmpty()) {
                    throw new ServletException("Shop Name cannot be empty.");
                }
                // Optional: Add validation for email format, phone format etc.

                // --- Ownership Verification ---
                if (formVendorId != activeVendor.getVendorId()) {
                    throw new SecurityException("Attempt to update profile for a different vendor.");
                }

                // --- Update Vendor Object (using data from the session object as base) ---
                Vendor vendorToUpdate = activeVendor; // Update the object from session directly
                vendorToUpdate.setShopName(shopName.trim());
                vendorToUpdate.setBusinessEmail(businessEmail != null ? businessEmail.trim() : null); // Allow null/empty
                vendorToUpdate.setBusinessPhone(businessPhone != null ? businessPhone.trim() : null); // Allow null/empty
                // Set other updated fields here...

                // --- Call DAO ---
                VendorDao vendorDao = new VendorDao();
                boolean success = vendorDao.updateVendor(vendorToUpdate);

                if (success) {
                    // *** IMPORTANT: Update the vendor object in the session ***
                    session.setAttribute("activeVendor", vendorToUpdate); // Store updated object
                    message = new Message("Shop details updated successfully!", "success", "alert-success");
                } else {
                    message = new Message("Failed to update shop details. The shop name might be taken or an error occurred.", "error", "alert-danger");
                }

            } catch (NumberFormatException e) {
                message = new Message("Invalid vendor ID format.", "error", "alert-danger");
                System.err.println("NumberFormatException in VendorProfileServlet: " + e.getMessage());
            } catch (SecurityException e) {
                message = new Message("Unauthorized action.", "error", "alert-danger");
                System.err.println("SecurityException in VendorProfileServlet: " + e.getMessage());
            } catch (Exception e) {
                message = new Message("An unexpected error occurred: " + e.getMessage(), "error", "alert-danger");
                System.err.println("Error in VendorProfileServlet: " + e.getMessage());
                e.printStackTrace();
            }

        } else {
            message = new Message("Unknown profile operation specified.", "error", "alert-warning");
        }

        // --- Set Message and Redirect ---
        if (message != null) {
            session.setAttribute("message", message);
        }
        response.sendRedirect(redirectPage);
    }

    // GET requests are invalid for profile updates
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Message message = new Message("Invalid request method.", "error", "alert-warning");
        session.setAttribute("message", message);
        response.sendRedirect("vendor_dashboard.jsp"); // Redirect vendor to dashboard
    }
}