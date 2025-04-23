package com.phong.servlets;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.phong.dao.UserDao;
import com.phong.dao.VendorDao;
import com.phong.entities.Message;
import com.phong.entities.User;
import com.phong.entities.Vendor;
import com.phong.helper.PasswordUtil;
// Import password hashing utility
// import com.phong.helper.PasswordUtil;


public class VendorLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Message message = null;
        String redirectPage = "vendor_login.jsp"; // Default redirect

        String userEmail = request.getParameter("user_email");
        String userPassword = request.getParameter("user_password"); // Plain text from form

        // Basic Validation
        if (userEmail == null || userPassword == null || userEmail.trim().isEmpty() || userPassword.isEmpty()) {
            message = new Message("Email and Password are required.", "error", "alert-warning");
            session.setAttribute("message", message);
            response.sendRedirect(redirectPage);
            return;
        }

        try {
            UserDao userDao = new UserDao();
            VendorDao vendorDao = new VendorDao();

            // 1. Authenticate as a regular user first
            //    Modify UserDao to fetch user by email only, then check password
            User user = userDao.getUserByEmail(userEmail.trim()); // Needs new method in UserDao!

            boolean passwordMatch = false;
            if (user != null) {
                // --- CHECK HASHED PASSWORD ---
                 passwordMatch = PasswordUtil.checkPassword(userPassword, user.getUserPassword());
            }

            if (user == null || !passwordMatch) {
                message = new Message("Invalid email or password.", "error", "alert-danger");
                session.setAttribute("message", message);
                response.sendRedirect(redirectPage);
                return;
            }

            // 2. Check if this user is linked to a vendor profile
            Vendor vendor = vendorDao.getVendorByOwnerUserId(user.getUserId());

            if (vendor == null) {
                message = new Message("This user account is not registered as a vendor.", "error", "alert-danger");
                session.setAttribute("message", message);
                response.sendRedirect(redirectPage); // Or maybe regular login?
                return;
            }

            // 3. Check if the vendor account is approved by admin
            if (!vendor.isApproved()) {
                message = new Message("Your vendor account is pending admin approval.", "warning", "alert-warning");
                session.setAttribute("message", message);
                response.sendRedirect(redirectPage);
                return;
            }

            // 4. Login Successful! Store Vendor (and maybe User) in session
            session.setAttribute("activeVendor", vendor); // Store vendor object

            // Redirect to vendor dashboard
            response.sendRedirect("vendor_dashboard.jsp");


        } catch (Exception e) {
            System.err.println("Error during vendor login: " + e.getMessage());
            e.printStackTrace();
            message = new Message("An unexpected error occurred during login.", "error", "alert-danger");
            session.setAttribute("message", message);
            response.sendRedirect(redirectPage);
        }
    }
}