package com.phong.servlets;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.phong.dao.ReviewDao;
import com.phong.entities.Message;
import com.phong.entities.Review;
import com.phong.entities.User;

public class ReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Message message = null;
        String redirectPage = null; // Will be set based on product ID
        String operation = request.getParameter("operation"); // Add operation parameter

        // --- Security Check ---
        User activeUser = (User) session.getAttribute("activeUser");
        if (activeUser == null) {
            message = new Message("Please log in to submit a review.", "error", "alert-danger");
            session.setAttribute("message", message);
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            redirectPage = "viewProduct.jsp?pid=" + productId; // Default redirect

            if ("add".equals(operation) || "update".equals(operation)) { // Handle add and update
                int rating = Integer.parseInt(request.getParameter("rating"));
                String comment = request.getParameter("comment");

                // --- Validation ---
            if (rating < 1 || rating > 5) {
                throw new ServletException("Invalid rating value provided.");
            }
            if (comment == null) { // Allow empty comments, but not null
                comment = "";
            }
            if (comment.length() > 1000) { // Example max length
                comment = comment.substring(0, 1000);
            }

                Review review = new Review();
                review.setProductId(productId);
                review.setUserId(activeUser.getUserId());
                review.setRating(rating);
                review.setComment(comment != null ? comment.trim() : "");

                ReviewDao reviewDao = new ReviewDao();
                boolean success = false;

                if ("add".equals(operation)) {
                    System.out.println("Attempting to add review...");
                    success = reviewDao.addReview(review);
                    if (success) {
                        message = new Message("Thank you! Your review has been submitted.", "success", "alert-success");
                    } else {
                        // Check if duplicate was the reason
                        if (reviewDao.hasUserReviewedProduct(activeUser.getUserId(), productId)) {
                            message = new Message("You have already reviewed this product.", "warning", "alert-warning");
                        } else {
                            message = new Message("Sorry, there was an issue submitting your review.", "error", "alert-danger");
                        }
                    }
                } else { // "update" operation
                    // Get review ID from a hidden form field
                    int reviewId = Integer.parseInt(request.getParameter("reviewId"));
                    review.setReviewId(reviewId); // Set the ID for the update query
                    System.out.println("Attempting to update review ID: " + reviewId);
                    success = reviewDao.updateReview(review);
                    if (success) {
                        message = new Message("Your review has been updated.", "success", "alert-success");
                    } else {
                        message = new Message("Failed to update your review.", "error", "alert-danger");
                    }
                }
            } else {
                // Handle other potential operations like delete? Or throw error.
                throw new ServletException("Invalid review operation specified: " + operation);
            }

        } catch (NumberFormatException e) {
            message = new Message("Invalid ID or rating provided.", "error", "alert-danger");
            redirectPage = "products.jsp";
        } catch (Exception e) {
            System.err.println("Error in ReviewServlet: " + e.getMessage());
            e.printStackTrace();
            message = new Message("An unexpected error occurred.", "error", "alert-danger");
            redirectPage = (request.getParameter("productId") != null)
                    ? "viewProduct.jsp?pid=" + request.getParameter("productId")
                    : "products.jsp";
        }

        session.setAttribute("message", message);
        response.sendRedirect(redirectPage);
    }

    // Generally, reviews shouldn't be submitted via GET
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("index.jsp"); // Or show error
    }
}