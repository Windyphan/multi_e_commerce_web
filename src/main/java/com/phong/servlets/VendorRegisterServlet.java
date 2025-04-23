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
// Import your password hashing utility
// import com.phong.helper.PasswordUtil;

public class VendorRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Message message = null;
        String redirectPage = "vendor_register.jsp"; // Redirect back on error/success

        // --- Get Vendor Registration Parameters ---
        // User details
        String userName = request.getParameter("user_name");
        String userEmail = request.getParameter("user_email"); // Use this for vendor owner link
        String userPassword = request.getParameter("user_password"); // Needs Hashing!
        String userPhone = request.getParameter("user_mobile_no");
        // Vendor details
        String shopName = request.getParameter("shop_name");
        String businessEmail = request.getParameter("business_email"); // Optional?
        String businessPhone = request.getParameter("business_phone"); // Optional?
        // Add other vendor fields if needed (address, etc.)

        // --- Basic Input Validation ---
        if (userName == null || userName.trim().isEmpty() ||
                userEmail == null || userEmail.trim().isEmpty() ||
                userPassword == null || userPassword.isEmpty() ||
                userPhone == null || userPhone.trim().isEmpty() ||
                shopName == null || shopName.trim().isEmpty()
            /* Add checks for other required vendor fields */) {

            message = new Message("Required fields cannot be empty.", "error", "alert-warning");
            session.setAttribute("message", message);
            response.sendRedirect(redirectPage);
            return;
        }

        // Trim values
        userName = userName.trim();
        userEmail = userEmail.trim();
        userPhone = userPhone.trim();
        shopName = shopName.trim();
        businessEmail = (businessEmail != null) ? businessEmail.trim() : null;
        businessPhone = (businessPhone != null) ? businessPhone.trim() : null;

        UserDao userDao = new UserDao();
        VendorDao vendorDao = new VendorDao();

        // 1. Check if email already exists as a user OR vendor owner
        //    (Requires modifications to UserDao/VendorDao or a dedicated UserService)
        //    if (userDao.getUserByEmail(userEmail) != null || vendorDao.getVendorByBusinessEmail(userEmail) != null) { ... error ... }

        // 2. Create User Record
        User newUser = new User();
        newUser.setUserName(userName);
        newUser.setUserEmail(userEmail);
        // --- HASH PASSWORD ---
        String hashedPassword = PasswordUtil.hashPassword(userPassword);
        newUser.setUserPassword(hashedPassword);
        newUser.setUserPhone(userPhone);
        // Set default address/gender etc. if needed for User table, might be null initially
        newUser.setUserGender(""); // Or have a specific role system
        newUser.setUserAddress("");
        newUser.setUserCity("");
        newUser.setUserPostcode("");
        newUser.setUserCounty("");

        boolean userSaved = userDao.saveUser(newUser);

        if (!userSaved) {
            // Could fail due to duplicate email/phone constraint if check above missed it
            // con.rollback(); // Rollback transaction
            message = new Message("Failed to create user account. Email or Phone might already exist.", "error", "alert-danger");
            session.setAttribute("message", message);
            response.sendRedirect(redirectPage);
            return;
        }

        // 3. Get the newly created User's ID (UserDao.saveUser needs to return it!)
        User createdUser = userDao.getUserByEmail(userEmail);
        if (createdUser == null) {
            // This shouldn't happen if saveUser succeeded, but handle defensively
            // con.rollback(); // Rollback transaction
            message = new Message("Internal error creating user account.", "error", "alert-danger");
            session.setAttribute("message", message);
            response.sendRedirect(redirectPage);
            return;
        }
        int ownerUserId = createdUser.getUserId();


        // 4. Create Vendor Record (initially not approved)
        Vendor newVendor = new Vendor();
        newVendor.setShopName(shopName);
        newVendor.setOwnerUserId(ownerUserId);
        newVendor.setBusinessEmail(businessEmail);
        newVendor.setBusinessPhone(businessPhone);
        newVendor.setApproved(false); // Admin needs to approve

        int vendorId = vendorDao.saveVendor(newVendor);

        if (vendorId <= 0) {
            // Failed to save vendor (maybe duplicate shop name?)
            // con.rollback(); // Rollback transaction (also need to delete the user created!) - Complex!
            System.err.println("Failed to save vendor after user creation (User ID: " + ownerUserId + ")");
            message = new Message("Failed to create vendor profile. Shop name might be taken.", "error", "alert-danger");
            session.setAttribute("message", message);
            response.sendRedirect(redirectPage);
            return;
        }

        // 5. If all succeeded
        // con.commit(); // Commit transaction
        message = new Message("Vendor registration submitted! Your account requires admin approval.", "success", "alert-info"); // Use info class
        session.setAttribute("message", message);
        response.sendRedirect("vendor_login.jsp"); // Redirect to vendor login

        // } catch (Exception e) { // Catch exceptions from DAO calls or validation
        //     if (con != null) try { con.rollback(); } catch (SQLException se) { /* log rollback error */ }
        //     System.err.println("Error during vendor registration: " + e.getMessage());
        //     e.printStackTrace();
        //     message = new Message("An unexpected error occurred during registration.", "error", "alert-danger");
        //     session.setAttribute("message", message);
        //     response.sendRedirect(redirectPage);
        // } finally {
        //      // Close connection if using manual transaction management
        //      if (con != null) try { con.setAutoCommit(true); con.close(); } catch (SQLException se) {}
        // }
        // --- Transaction Block End (Conceptual) ---

        // Note: The above try/catch/finally wrapping the whole process is needed
        // for proper transaction management. Without it, the code below runs
        // without transaction safety. Simpler version below assumes no transactions:

        // --- Simplified Version (No Transaction Handling) ---
        // try { // Still use try-catch for general errors
        // ... (Validation as above) ...
        // ... (Hashing password) ...
        // ... (Create User object newUser) ...
        // boolean userSaved = userDao.saveUser(newUser);
        // if (!userSaved) { /* Set error message, redirect */ return; }
        // User createdUser = userDao.getUserByEmailPassword(...); // Fetch back user
        // if (createdUser == null) { /* Set error message, redirect */ return; }
        // int ownerUserId = createdUser.getUserId();
        // Vendor newVendor = new Vendor(...);
        // newVendor.setOwnerUserId(ownerUserId);
        // int vendorId = vendorDao.saveVendor(newVendor);
        // if (vendorId <= 0) { /* Set error message, redirect */ return; }
        // message = new Message("Vendor registration submitted...", "success", "alert-info");
        // session.setAttribute("message", message);
        // response.sendRedirect("vendor_login.jsp");
        // } catch (Exception e) { /* Handle exceptions, set error message, redirect */ }

    }
}