package com.phong.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.phong.entities.Review;
import com.phong.helper.ConnectionProvider;

public class ReviewDao {

    public ReviewDao() {
        super();
    }

    /**
     * Saves a new review to the database.
     * Handles potential unique constraint violations (user reviewed product already).
     *
     * @param review The Review object to save.
     * @return true if saved successfully, false otherwise (including duplicate reviews).
     */
    public boolean addReview(Review review) {
        boolean flag = false;
        // Note: review_id is auto-generated (SERIAL)
        String query = "INSERT INTO review(rating, comment, user_id, product_id) VALUES (?, ?, ?, ?)";

        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement psmt = con.prepareStatement(query)) {

            psmt.setInt(1, review.getRating());
            psmt.setString(2, review.getComment());
            psmt.setInt(3, review.getUserId());
            psmt.setInt(4, review.getProductId());

            int rowsAffected = psmt.executeUpdate();
            if (rowsAffected > 0) {
                flag = true;
            }

        } catch (SQLException e) {
            // Check for unique constraint violation (user_id, product_id)
            // PostgreSQL unique violation code is "23505"
            if ("23505".equals(e.getSQLState())) {
                System.err.println("INFO: User " + review.getUserId() + " already reviewed product " + review.getProductId());
                // Consider setting a specific message or just returning false
            } else {
                System.err.println("Error adding review: " + e.getMessage());
                e.printStackTrace(); // Replace with proper logging
            }
        } catch (ClassNotFoundException e) {
            System.err.println("Error adding review (driver not found): " + e.getMessage());
            e.printStackTrace();
        }
        return flag;
    }

    /**
     * Gets all reviews for a specific product, optionally joining with user table for names.
     * Orders by review date descending.
     *
     * @param productId The ID of the product.
     * @return A List of Review objects, potentially empty. Returns null on major error.
     */
    public List<Review> getReviewsByProductId(int productId) {
        List<Review> list = new ArrayList<>();
        // Join with "user" table to get the reviewer's name
        String query = "SELECT r.*, u.name as user_name " +
                "FROM review r JOIN \"user\" u ON r.user_id = u.userid " +
                "WHERE r.product_id = ? " +
                "ORDER BY r.review_date DESC";

        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement psmt = con.prepareStatement(query)) {

            psmt.setInt(1, productId);

            try (ResultSet rs = psmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToReview(rs));
                }
            }

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting reviews for product ID " + productId + ": " + e.getMessage());
            e.printStackTrace();
            return null; // Indicate error
        }
        return list;
    }

    /**
     * Calculates the average rating for a specific product.
     *
     * @param productId The ID of the product.
     * @return The average rating (float), or 0.0f if no reviews or an error occurs.
     */
    public float getAverageRatingByProductId(int productId) {
        float avgRating = 0.0f;
        // AVG function returns numeric/decimal, cast to float if needed
        String query = "SELECT AVG(rating) as avg_rating FROM review WHERE product_id = ?";

        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement psmt = con.prepareStatement(query)) {

            psmt.setInt(1, productId);
            try (ResultSet rs = psmt.executeQuery()) {
                if (rs.next()) {
                    // Use getFloat or getDouble - AVG might return null if no rows match
                    avgRating = rs.getFloat("avg_rating");
                    // getFloat returns 0 if the SQL value was NULL (no reviews)
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error calculating average rating for product ID " + productId + ": " + e.getMessage());
            e.printStackTrace();
        }
        return avgRating;
    }

    /**
     * Checks if a specific user has already reviewed a specific product.
     *
     * @param userId    The ID of the user.
     * @param productId The ID of the product.
     * @return true if a review exists, false otherwise or on error.
     */
    public boolean hasUserReviewedProduct(int userId, int productId) {
        boolean exists = false;
        String query = "SELECT 1 FROM review WHERE user_id = ? AND product_id = ?";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement psmt = con.prepareStatement(query)) {
            psmt.setInt(1, userId);
            psmt.setInt(2, productId);
            try (ResultSet rs = psmt.executeQuery()) {
                if (rs.next()) {
                    exists = true;
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error checking if user " + userId + " reviewed product " + productId + ": " + e.getMessage());
            e.printStackTrace();
        }
        return exists;
    }

    /**
     * Updates an existing review's rating and comment.
     * Checks if the review belongs to the specified user.
     *
     * @param review The Review object containing review_id, new rating, new comment, and user_id.
     * @return true if updated successfully, false otherwise.
     */
    public boolean updateReview(Review review) {
        boolean flag = false;
        // Update rating and comment based on review_id AND user_id to ensure ownership
        String query = "UPDATE review SET rating = ?, comment = ?, review_date = CURRENT_TIMESTAMP " +
                "WHERE review_id = ? AND user_id = ?";

        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement psmt = con.prepareStatement(query)) {

            psmt.setInt(1, review.getRating());
            psmt.setString(2, review.getComment());
            psmt.setInt(3, review.getReviewId());
            psmt.setInt(4, review.getUserId()); // Verify ownership

            int rowsAffected = psmt.executeUpdate();
            if (rowsAffected > 0) {
                flag = true; // Update successful
            } else {
                System.err.println("WARN: Review update failed. Review ID " + review.getReviewId() +
                        " not found or does not belong to user ID " + review.getUserId());
            }

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error updating review ID " + review.getReviewId() + ": " + e.getMessage());
            e.printStackTrace();
        }
        return flag;
    }

    /**
     * Gets a specific review written by a user for a product.
     *
     * @param userId    The ID of the user.
     * @param productId The ID of the product.
     * @return The Review object if found, null otherwise or on error.
     */
    public Review getReviewByUserIdAndProductId(int userId, int productId) {
        Review review = null;
        // No need to join user table here usually
        String query = "SELECT * FROM review WHERE user_id = ? AND product_id = ?";

        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement psmt = con.prepareStatement(query)) {

            psmt.setInt(1, userId);
            psmt.setInt(2, productId);

            try (ResultSet rs = psmt.executeQuery()) {
                if (rs.next()) {
                    review = mapResultSetToReview(rs); // Reuse existing helper
                    // Note: mapResultSetToReview might try to get user_name if joined, handle that
                    // or create a simpler mapResultSetToReviewWithoutUser
                }
            }

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting review for user " + userId + ", product " + productId + ": " + e.getMessage());
            e.printStackTrace();
        }
        return review;
    }


    // Helper method to map ResultSet to Review object
    private Review mapResultSetToReview(ResultSet rs) throws SQLException {
        Review review = new Review();
        review.setReviewId(rs.getInt("review_id"));
        review.setRating(rs.getInt("rating"));
        review.setComment(rs.getString("comment"));
        review.setReviewDate(rs.getTimestamp("review_date"));
        review.setUserId(rs.getInt("user_id"));
        review.setProductId(rs.getInt("product_id"));
        // Include user name from the JOIN
        if (hasColumn(rs, "user_name")) { // Check if column exists (good practice)
            review.setUserName(rs.getString("user_name"));
        }
        return review;
    }

    // Helper to check if a column exists in the ResultSet (avoids errors if JOIN fails)
    private static boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData rsmd = rs.getMetaData();
        int columns = rsmd.getColumnCount();
        for (int x = 1; x <= columns; x++) {
            if (columnName.equals(rsmd.getColumnName(x))) {
                return true;
            }
        }
        return false;
    }

    // Optional: Add methods for deleting or updating reviews if needed
}