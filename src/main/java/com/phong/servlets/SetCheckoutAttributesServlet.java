package com.phong.servlets;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.phong.entities.Message; // For potential error messages
import com.phong.entities.User; // To check if user is logged in

/**
 * Servlet implementation class SetCheckoutAttributesServlet
 *
 * This servlet handles the POST request from the "Proceed to Checkout" button
 * on the cart page. Its sole purpose is to set necessary attributes
 * ('from' and 'totalPrice') into the session before redirecting to the
 * actual checkout page.
 */
public class SetCheckoutAttributesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Message message = null;
        String redirectOnError = "index.jsp"; // Default redirect on error

        // Security Check
        User activeUser = (User) session.getAttribute("activeUser");
        if (activeUser == null) {
            message = new Message("Please log in to proceed.", "error", "alert-danger");
            session.setAttribute("message", message);
            response.sendRedirect("login.jsp");
            return;
        }

        // Get 'from' parameter
        String from = request.getParameter("from");

        if (from == null || from.trim().isEmpty()) {
            message = new Message("Invalid request origin.", "error", "alert-warning");
            session.setAttribute("message", message);
            response.sendRedirect(redirectOnError);
            return;
        }
        from = from.trim(); // Use trimmed value

        try {
            // --- Handle based on 'from' parameter ---
            if ("cart".equals(from)) {
                redirectOnError = "cart.jsp"; // Redirect to cart on cart-related errors
                String totalPriceStr = request.getParameter("totalPrice");
                if (totalPriceStr == null) {
                    throw new ServletException("Missing total price for cart checkout.");
                }
                float totalPrice = Float.parseFloat(totalPriceStr);

                // Set session attributes for cart flow
                session.setAttribute("from", "cart");
                session.setAttribute("totalPrice", totalPrice);

                // Clear buy now attributes if they exist
                session.removeAttribute("pid");
                session.removeAttribute("buyNowPrice");

            } else if ("buy".equals(from)) {
                redirectOnError = "products.jsp"; // Redirect to products on buy-related errors
                String pidStr = request.getParameter("pid");
                String buyNowPriceStr = request.getParameter("buyNowPrice");

                if (pidStr == null || buyNowPriceStr == null) {
                    throw new ServletException("Missing product ID or price for 'buy now' checkout.");
                }
                int productId = Integer.parseInt(pidStr);
                float buyNowPrice = Float.parseFloat(buyNowPriceStr);

                // Set session attributes for buy now flow
                session.setAttribute("from", "buy");
                session.setAttribute("pid", productId);
                session.setAttribute("buyNowPrice", buyNowPrice); // Store the calculated price

                // Clear cart attributes if they exist
                session.removeAttribute("totalPrice");

            } else {
                // Unknown 'from' value
                throw new ServletException("Invalid 'from' parameter value: " + from);
            }

            // --- Redirect to Checkout Page on Success ---
            response.sendRedirect("checkout.jsp");

        } catch (NumberFormatException e) {
            System.err.println("Error parsing number in SetCheckoutAttributesServlet: " + e.getMessage());
            message = new Message("Invalid numeric value received.", "error", "alert-danger");
            session.setAttribute("message", message);
            response.sendRedirect(redirectOnError); // Redirect back based on context
        } catch (Exception e) { // Catch ServletException or other errors
            System.err.println("Error in SetCheckoutAttributesServlet: " + e.getMessage());
            e.printStackTrace();
            message = new Message("An unexpected error occurred while preparing checkout: " + e.getMessage(), "error", "alert-danger");
            session.setAttribute("message", message);
            response.sendRedirect(redirectOnError); // Redirect back based on context
        }
    }

    /**
     * Handles GET requests - typically should not happen for this action.
     * Redirect back to cart with a warning.
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Message message = new Message("Invalid request method for checkout setup.", "error", "alert-warning");
        session.setAttribute("message", message);
        response.sendRedirect("cart.jsp");
    }

}