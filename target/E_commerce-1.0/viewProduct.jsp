<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.dao.ProductDao"%>
<%@page import="com.phong.dao.CategoryDao"%>
<%@page import="com.phong.dao.WishlistDao"%> <%-- If showing wishlist status --%>
<%@page import="com.phong.dao.ReviewDao"%>
<%@page import="com.phong.entities.Product"%>
<%@page import="com.phong.entities.User"%>
<%@page import="com.phong.entities.Review"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.List"%>
<%@page import="java.util.stream.Collectors"%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Data Fetching and Validation --%>
<%
	// Get active user (if any)
	User currentUserForViewProducts = (User) session.getAttribute("activeUser");

	// Get Product ID from request and validate
	Product product = null;
	int productId = 0;
	String pidParam = request.getParameter("pid");
	String errorMessage = null;
	String categoryName = "N/A"; // Default category name

	if (pidParam != null && !pidParam.trim().isEmpty()) {
		try {
			productId = Integer.parseInt(pidParam.trim());
			if (productId > 0) {
				ProductDao productDao = new ProductDao();
				product = productDao.getProductsByProductId(productId);
				if (product == null) {
					errorMessage = "Product not found.";
				} else {
					// Fetch category name if product found
					CategoryDao categoryDaoForViewProduct = new CategoryDao();
					categoryName = categoryDaoForViewProduct.getCategoryName(product.getCategoryId());
					if (categoryName == null) categoryName = "Unknown"; // Handle null category name
				}
			} else {
				errorMessage = "Invalid Product ID specified.";
			}
		} catch (NumberFormatException e) {
			errorMessage = "Invalid Product ID format.";
		} catch (Exception e) {
			System.err.println("Error fetching product details: " + e.getMessage());
			e.printStackTrace();
			errorMessage = "Could not load product details.";
		}
	} else {
		errorMessage = "No Product ID specified.";
	}

	// Fetch user's wishlist efficiently (only if logged in and product found)
	Set<Integer> userWishlistProductIds = new HashSet<>();
	if (currentUserForViewProducts != null && product != null) {
		WishlistDao wishlistDao = new WishlistDao();
		List<com.phong.entities.Wishlist> userWishlist = wishlistDao.getListByUserId(currentUserForViewProducts.getUserId());
		if (userWishlist != null) {
			userWishlistProductIds = userWishlist.stream()
					.map(com.phong.entities.Wishlist::getProductId)
					.collect(Collectors.toSet());
		} else {
			System.err.println("Warning: Could not retrieve wishlist for user " + currentUserForViewProducts.getUserId());
		}
	}

	// Fetch Reviews and Average Rating
	List<Review> reviews = Collections.emptyList();
	float averageRating = 0.0f;
	int reviewCount = 0;
	boolean userHasReviewed = false;
	Review existingUserReview = null; // Variable to hold existing review

	if (product != null) { // Only fetch if product exists
		ReviewDao reviewDao = new ReviewDao();
		List<Review> fetchedReviews = reviewDao.getReviewsByProductId(product.getProductId());
		if (fetchedReviews != null) {
			reviews = fetchedReviews;
			reviewCount = reviews.size();
		}
		averageRating = reviewDao.getAverageRatingByProductId(product.getProductId());

		// Check if current logged-in user has reviewed this product
		if (currentUserForViewProducts != null) {
			// Use the new DAO method
			existingUserReview = reviewDao.getReviewByUserIdAndProductId(currentUserForViewProducts.getUserId(), product.getProductId());
			userHasReviewed = (existingUserReview != null); // Simplified check
		}
	}

	// Set attributes for EL access
	request.setAttribute("product", product);
	request.setAttribute("categoryName", categoryName);
	request.setAttribute("userWishlistPids", userWishlistProductIds);
	request.setAttribute("productReviews", reviews);
	request.setAttribute("averageRating", averageRating);
	request.setAttribute("reviewCount", reviewCount);
	request.setAttribute("userHasReviewed", userHasReviewed);
	request.setAttribute("existingUserReview", existingUserReview); // Pass existing review

	// Redirect if product not found or ID invalid
	if (errorMessage != null) {
		pageContext.setAttribute("errorMessage", errorMessage, PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		response.sendRedirect("products.jsp"); // Go back to product list
		return;
	}

%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<%-- Set title dynamically --%>
	<title><c:out value="${product.productName}"/> - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f8f9fa;
		}
		.product-view-container {
			background-color: #fff;
			padding: 2rem;
			border-radius: 0.5rem;
			box-shadow: 0 3px 10px rgba(0,0,0,0.07);
		}
		.product-image-container {
			text-align: center; /* Center image within column */
			position: relative; /* For wishlist icon */
		}
		.product-image {
			max-width: 100%;
			max-height: 450px; /* Limit image height */
			object-fit: contain;
			border: 1px solid #eee;
			padding: 10px;
			border-radius: 0.375rem;
		}
		.product-details h4 {
			font-weight: 600;
			margin-bottom: 1rem;
			color: #212529;
		}
		.product-details .description-title,
		.product-details .status-title,
		.product-details .category-title {
			font-weight: 600;
			font-size: 1.1rem;
			color: #495057;
			margin-top: 1.2rem;
			margin-bottom: 0.3rem;
		}
		.product-details .description-text {
			line-height: 1.6;
			color: #343a40;
		}
		.price-section {
			margin-top: 1.5rem;
			padding-top: 1.5rem;
			border-top: 1px solid #eee;
		}
		.price-section .final-price {
			font-size: 2rem; /* Larger final price */
			font-weight: 700;
			color: #dc3545; /* Red price */
			margin-right: 0.75rem;
		}
		.price-section .original-price {
			font-size: 1.2rem;
			text-decoration: line-through;
			color: #6c757d;
			margin-right: 0.75rem;
		}
		.price-section .discount-percent {
			font-size: 1.1rem;
			color: #198754; /* Green discount */
			font-weight: 600;
		}
		.status-text {
			font-weight: 500;
			font-size: 1.1rem;
		}
		.status-text.available {
			color: #198754; /* Green */
		}
		.status-text.out-of-stock {
			color: #dc3545; /* Red */
		}
		.category-text {
			color: #0d6efd; /* Blue */
			font-weight: 500;
		}
		.action-buttons {
			margin-top: 2rem;
			padding-top: 1.5rem;
			border-top: 1px solid #eee;
		}
		.action-buttons .btn {
			font-size: 1.1rem;
			padding: 0.7rem 1.5rem;
			margin: 0 0.5rem;
		}

		/* Wishlist Icon */
		.wishlist-icon-container {
			position: absolute;
			top: 15px;
			right: 15px;
			z-index: 10;
		}
		.wishlist-btn {
			background-color: rgba(255, 255, 255, 0.8);
			border: 1px solid #eee;
			border-radius: 50%;
			width: 40px; /* Slightly larger */
			height: 40px;
			display: inline-flex;
			align-items: center;
			justify-content: center;
			padding: 0;
			box-shadow: 0 1px 3px rgba(0,0,0,0.1);
		}
		.wishlist-btn i { font-size: 1.2rem; } /* Larger icon */
		.wishlist-btn .fa-heart.in-wishlist { color: #dc3545; }
		.wishlist-btn .fa-heart.not-in-wishlist { color: #adb5bd; }
		.wishlist-btn:hover .fa-heart.not-in-wishlist { color: #6c757d; }

	</style>
</head>
<body class="d-flex flex-column min-vh-100">

<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-5"> <%-- Increased margin --%>

	<%-- Display Messages --%>
	<%@include file="Components/alert_message.jsp"%>

	<%-- Check if product exists (handled by redirect earlier, but good practice) --%>
	<c:if test="${not empty product}">
		<div class="product-view-container">
			<div class="row g-4"> <%-- Add gap between columns --%>
					<%-- Image Column --%>
				<div class="col-md-6">
					<div class="product-image-container">
							<%-- Wishlist Button --%>
						<div class="wishlist-icon-container">
							<c:choose>
								<c:when test="${empty sessionScope.activeUser}">
									<a href="login.jsp" class="btn wishlist-btn" title="Login to add to wishlist">
										<i class="fa-regular fa-heart not-in-wishlist"></i>
									</a>
								</c:when>
								<c:otherwise>
									<c:set var="isInWishlist" value="${userWishlistPids.contains(product.productId)}"/>
									<c:choose>
										<c:when test="${isInWishlist}">
											<a href="WishlistServlet?pid=${product.productId}&op=remove" class="btn wishlist-btn" title="Remove from Wishlist">
												<i class="fa-solid fa-heart in-wishlist"></i>
											</a>
										</c:when>
										<c:otherwise>
											<a href="WishlistServlet?pid=${product.productId}&op=add" class="btn wishlist-btn" title="Add to Wishlist">
												<i class="fa-regular fa-heart not-in-wishlist"></i>
											</a>
										</c:otherwise>
									</c:choose>
								</c:otherwise>
							</c:choose>
						</div> <%-- End wishlist container --%>

							<%-- Use forward slash --%>
						<img src="${s3BaseUrl}${product.productImages}" class="product-image" alt="${product.productName}">
					</div>
				</div>

					<%-- Details Column --%>
				<div class="col-md-6 product-details">
					<h4><c:out value="${product.productName}"/></h4>

						<%-- Price Section --%>
					<div class="price-section">
                            <span class="final-price">
                                <fmt:setLocale value="en_GB"/>
                                <fmt:formatNumber value="${product.productPriceAfterDiscount}" type="currency" currencySymbol="£"/>
                            </span>
						<c:if test="${product.productDiscount > 0}">
                                <span class="original-price">
                                    <fmt:formatNumber value="${product.productPrice}" type="currency" currencySymbol="£"/>
                                </span>
							<span class="discount-percent">
                                    (${product.productDiscount}% off)
                                </span>
						</c:if>
					</div>

					<div class="d-flex align-items-center mb-2"> <%-- Flex container for rating --%>
						<c:if test="${reviewCount > 0}">
							<div class="star-rating me-2" title="${averageRating} out of 5 stars">
								<c:forEach var="i" begin="1" end="5">
									<i class="fa-${averageRating >= i ? 'solid' : (averageRating >= i-0.5 ? 'solid fa-star-half-stroke' : 'regular')} fa-star text-warning"></i>
								</c:forEach>
							</div>
							<span class="text-muted small">(${reviewCount} Review<c:if test="${reviewCount != 1}">s</c:if>)</span>
						</c:if>
						<c:if test="${reviewCount == 0}">
							<span class="text-muted small">No reviews yet</span>
						</c:if>
					</div>

						<%-- Description --%>
					<h6 class="description-title">Description</h6>
					<p class="description-text"><c:out value="${product.productDescription}"/></p>

						<%-- Status --%>
					<h6 class="status-title">Status</h6>
					<c:choose>
						<c:when test="${product.productQuantity > 0}">
                                 <span class="status-text available">
                                     <i class="fa-solid fa-check-circle"></i> Available
                                 </span>
						</c:when>
						<c:otherwise>
                                 <span class="status-text out-of-stock">
                                     <i class="fa-solid fa-times-circle"></i> Out of stock
                                 </span>
						</c:otherwise>
					</c:choose>

						<%-- Category --%>
					<h6 class="category-title">Category</h6>
					<span class="category-text"><c:out value="${categoryName}"/></span>

						<%-- Action Buttons Form --%>
						<%-- Use forms for actions that change county (Add to Cart) --%>
					<div class="action-buttons text-center"> <%-- Center buttons --%>
						<c:choose>
							<c:when test="${empty sessionScope.activeUser}"> <%-- User Logged Out --%>
								<button type="button" onclick="window.location.href='login.jsp'" class="btn btn-primary">
									<i class="fa-solid fa-cart-plus"></i> Add to Cart
								</button>
								<button type="button" onclick="window.location.href='login.jsp'" class="btn btn-success">
									<i class="fa-solid fa-bolt"></i> Buy Now
								</button>
							</c:when>
							<c:otherwise> <%-- User Logged In --%>
								<%-- Add to Cart Form --%>
								<form action="AddToCartServlet" method="post" style="display: inline-block;">
									<input type="hidden" name="pid" value="${product.productId}">
										<%-- uid is taken from session in servlet --%>
									<button type="submit" class="btn btn-primary" ${product.productQuantity <= 0 ? 'disabled' : ''}>
										<i class="fa-solid fa-cart-plus"></i> Add to Cart
									</button>
								</form>

								<%-- Buy Now Form (posts to a servlet to set session attrs) --%>
								<form action="SetCheckoutAttributesServlet" method="post" style="display: inline-block;">
									<input type="hidden" name="from" value="buy">
									<input type="hidden" name="pid" value="${product.productId}">
									<input type="hidden" name="buyNowPrice" value="${product.productPriceAfterDiscount}">
									<button type="submit" class="btn btn-success" ${product.productQuantity <= 0 ? 'disabled' : ''}>
										<i class="fa-solid fa-bolt"></i> Buy Now
									</button>
								</form>
							</c:otherwise>
						</c:choose>
					</div>
				</div> <%-- End details column --%>
				<hr class="my-4">

				<div class="row">
					<div class="col-12">
						<h4 class="mb-3">Customer Reviews & Ratings</h4>
					</div>

						<%-- Column for Average Rating & Form --%>
					<div class="col-md-5 col-lg-4 mb-4 mb-md-0">
							<%-- Average Rating Display --%>
						<div class="card sticky-top" style="top: 20px;"> <%-- Make rating/form sticky? --%>
							<div class="card-body text-center">
								<h5>Average Rating</h5>
								<c:choose>
									<c:when test="${reviewCount > 0}">
										<h2 class="display-4 fw-bold"><fmt:formatNumber value="${averageRating}" maxFractionDigits="1"/> / 5</h2>
										<div class="star-rating mb-2">
												<%-- Display stars based on average --%>
											<c:forEach var="i" begin="1" end="5">
												<i class="fa-${averageRating >= i ? 'solid' : (averageRating >= i-0.5 ? 'solid fa-star-half-stroke' : 'regular')} fa-star text-warning"></i>
											</c:forEach>
										</div>
										<span class="text-muted">Based on ${reviewCount} review<c:if test="${reviewCount != 1}">s</c:if></span>
									</c:when>
									<c:otherwise>
										<p class="text-muted mt-3">No reviews yet.</p>
									</c:otherwise>
								</c:choose>
							</div>
						</div>

							<%-- Review Submission Form --%>
							<%-- Show only if user is logged in AND hasn't reviewed yet --%>
							<c:choose>
								<c:when test="${empty sessionScope.activeUser}">
									<div class="alert alert-secondary mt-4" role="alert">
										Please <a href="login.jsp" class="alert-link">login</a> to write or update a review.
									</div>
								</c:when>
								<c:otherwise> <%-- User is logged in --%>
									<div class="card mt-4">
										<div class="card-header">
											<c:choose>
												<c:when test="${userHasReviewed}">Edit Your Review</c:when>
												<c:otherwise>Write a Review</c:otherwise>
											</c:choose>
										</div>
										<div class="card-body">
											<form action="ReviewServlet" method="post" class="needs-validation" novalidate>
													<%-- Hidden field for operation type --%>
												<input type="hidden" name="operation" value="${userHasReviewed ? 'update' : 'add'}">
												<input type="hidden" name="productId" value="${product.productId}">
													<%-- Include review ID ONLY if updating --%>
												<c:if test="${userHasReviewed}">
													<input type="hidden" name="reviewId" value="${existingUserReview.reviewId}">
												</c:if>

												<div class="mb-3">
													<label for="ratingInput" class="form-label">Your Rating:</label>
													<div id="ratingInput" class="star-rating-input">
															<%-- Add 'checked' based on existingUserReview.rating if updating --%>
														<input type="radio" id="star5" name="rating" value="5" required ${userHasReviewed && existingUserReview.rating == 5 ? 'checked' : ''}/><label for="star5" title="5 stars">★</label>
														<input type="radio" id="star4" name="rating" value="4" required ${userHasReviewed && existingUserReview.rating == 4 ? 'checked' : ''}/><label for="star4" title="4 stars">★</label>
														<input type="radio" id="star3" name="rating" value="3" required ${userHasReviewed && existingUserReview.rating == 3 ? 'checked' : ''}/><label for="star3" title="3 stars">★</label>
														<input type="radio" id="star2" name="rating" value="2" required ${userHasReviewed && existingUserReview.rating == 2 ? 'checked' : ''}/><label for="star2" title="2 stars">★</label>
														<input type="radio" id="star1" name="rating" value="1" required ${userHasReviewed && existingUserReview.rating == 1 ? 'checked' : ''}/><label for="star1" title="1 star">★</label>
													</div>
													<div class="invalid-feedback d-block">Please select a rating.</div>
												</div>
												<div class="mb-3">
													<label for="commentInput" class="form-label">Your Review:</label>
														<%-- Pre-fill textarea with existing comment if updating --%>
													<textarea class="form-control" id="commentInput" name="comment" rows="4"
															  placeholder="Share your thoughts..."><c:if test="${userHasReviewed}"><c:out value="${existingUserReview.comment}"/></c:if></textarea>
												</div>
												<button type="submit" class="btn btn-primary">
													<c:choose>
														<c:when test="${userHasReviewed}">Update Review</c:when>
														<c:otherwise>Submit Review</c:otherwise>
													</c:choose>
												</button>
											</form>
										</div>
									</div>
								</c:otherwise>
							</c:choose>
							<%-- Show message if user already reviewed --%>
						<c:if test="${not empty sessionScope.activeUser and userHasReviewed}">
							<div class="alert alert-info mt-4" role="alert">
								You have already submitted a review for this product.
							</div>
						</c:if>

					</div>

						<%-- Column for Existing Reviews --%>
					<div class="col-md-7 col-lg-8">
						<c:choose>
							<c:when test="${empty productReviews}">
								<%-- Message handled by average rating section --%>
							</c:when>
							<c:otherwise>
								<c:forEach var="review" items="${productReviews}">
									<div class="card mb-3"> <%-- Card per review --%>
										<div class="card-body">
											<div class="d-flex justify-content-between align-items-center mb-2">
												<span class="fw-bold"><c:out value="${review.userName}"/></span>
												<small class="text-muted">
													<fmt:formatDate value="${review.reviewDate}" pattern="dd MMM yyyy"/>
												</small>
											</div>
											<div class="star-rating mb-2">
													<%-- Display stars for this review --%>
												<c:forEach var="i" begin="1" end="5">
													<i class="fa-${review.rating >= i ? 'solid' : 'regular'} fa-star text-warning"></i>
												</c:forEach>
											</div>
											<p class="card-text"><c:out value="${review.comment}"/></p>
										</div>
									</div>
								</c:forEach>
							</c:otherwise>
						</c:choose>
					</div>
				</div><%-- End Review --%>
			</div> <%-- End row --%>
		</div> <%-- End product-view-container --%>
	</c:if> <%-- End check if product is not empty --%>

	<%-- Display error message if product wasn't found initially --%>
	<c:if test="${empty product and not empty errorMessage}">
		<div class="alert alert-danger text-center" role="alert">
			<c:out value="${errorMessage}"/> Please <a href="products.jsp" class="alert-link">return to products</a>.
		</div>
	</c:if>

</main> <%-- End main wrapper --%>

<%-- Footer --%>
<%@include file="footer.jsp"%>

<%-- Remove the invalid JavaScript --%>

</body>
</html>