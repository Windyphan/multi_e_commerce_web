package com.phong.entities;

import java.sql.Timestamp;

public class Review {
    private int reviewId;
    private int rating; // 1 to 5
    private String comment;
    private Timestamp reviewDate;
    private int userId;
    private int productId;

    // Optional: To display username along with review
    private String userName;

    // Constructors
    public Review() {
    }

    public Review(int rating, String comment, Timestamp reviewDate, int userId, int productId) {
        this.rating = rating;
        this.comment = comment;
        this.reviewDate = reviewDate;
        this.userId = userId;
        this.productId = productId;
    }

    public Review(int reviewId, int rating, String comment, Timestamp reviewDate, int userId, int productId) {
        this.reviewId = reviewId;
        this.rating = rating;
        this.comment = comment;
        this.reviewDate = reviewDate;
        this.userId = userId;
        this.productId = productId;
    }

    // Getters and Setters
    public int getReviewId() {
        return reviewId;
    }

    public void setReviewId(int reviewId) {
        this.reviewId = reviewId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Timestamp getReviewDate() {
        return reviewDate;
    }

    public void setReviewDate(Timestamp reviewDate) {
        this.reviewDate = reviewDate;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    // Optional getter/setter for user name if joining tables in DAO
    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    @Override
    public String toString() {
        return "Review [reviewId=" + reviewId + ", rating=" + rating + ", comment=" + comment + ", reviewDate="
                + reviewDate + ", userId=" + userId + ", productId=" + productId + ", userName=" + userName + "]";
    }
}