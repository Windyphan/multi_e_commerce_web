<%-- products.jsp --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.dao.ProductDao"%>
<%-- Remove CategoryDao import if only using list from navbar --%>
<%@page import="com.phong.dao.WishlistDao"%>
<%@page import="com.phong.dao.ReviewDao"%>
<%@page import="com.phong.dao.VendorDao"%>
<%@page import="com.phong.entities.Product"%>
<%@page import="com.phong.entities.User"%> <%-- Keep for session check --%>
<%@page import="com.phong.entities.Wishlist"%>
<%@page import="com.phong.entities.Vendor"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.stream.Collectors"%>
<%@ page import="java.util.Date" %> <%-- Added Date import for logging --%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Data Fetching and Logic --%>
<%
	// *** START PRODUCTS LOGGING ***
	System.out.println("=== PRODUCTS_JSP [" + new Date() + "]: Request received ===");

	User currentUserForProducts = (User) session.getAttribute("activeUser");
	System.out.println("### PRODUCTS_JSP [" + new Date() + "]: currentUserForProducts is null? " + (currentUserForProducts == null));

	String searchKey = request.getParameter("search");
	String categoryIdParam = request.getParameter("category");
	System.out.println("### PRODUCTS_JSP [" + new Date() + "]: searchKey = '" + searchKey + "', categoryIdParam = '" + categoryIdParam + "'");

	ProductDao productDao = new ProductDao();
	// CategoryDao categoryDao = new CategoryDao(); // Not needed if using list from navbar

	List<Product> productList = null;
	String pageTitle = "All Products";
	String displayMessage = "Showing All Products";
	String categoryNameForMessage = null;

	try {
		if (searchKey != null) { // Prioritize search
			searchKey = searchKey.trim();
			if (!searchKey.isEmpty()) {
				productList = productDao.getAllProductsBySearchKey(searchKey);
				pageTitle = "Search Results for '" + searchKey + "'";
				displayMessage = "Showing results for \"" + searchKey + "\"";
			} else {
				productList = productDao.getAllProducts();
				displayMessage = "Search term was empty. Showing All Products.";
			}
		} else if (categoryIdParam != null) { // Check category ID
			categoryIdParam = categoryIdParam.trim();
			try {
				int currentCategoryId = Integer.parseInt(categoryIdParam);
				if (currentCategoryId > 0) { // Specific category
					productList = productDao.getAllProductsByCategoryId(currentCategoryId);

					// --- Get category name efficiently ---
					@SuppressWarnings("unchecked")
					List<com.phong.entities.Category> navCategories = (List<com.phong.entities.Category>) request.getAttribute("navbarCategoryList");
					if (navCategories != null) {
						for (com.phong.entities.Category cat : navCategories) {
							if (cat.getCategoryId() == currentCategoryId) {
								categoryNameForMessage = cat.getCategoryName();
								break;
							}
						}
					}
					// --- End category name lookup ---

					if (categoryNameForMessage != null) {
						pageTitle = categoryNameForMessage + " Products";
						displayMessage = "Showing results for \"" + categoryNameForMessage + "\"";
					} else {
						pageTitle = "Products";
						displayMessage = "Showing results for selected category";
					}
				} else { // category=0 means "All Products"
					productList = productDao.getAllProducts();
				}
			} catch (NumberFormatException nfe) {
				System.err.println("Invalid category ID format received: " + categoryIdParam);
				productList = productDao.getAllProducts();
				displayMessage = "Invalid category specified. Showing All Products.";
			}
		} else { // No search, no category -> show all
			productList = productDao.getAllProducts();
		}
		System.out.println("### PRODUCTS_JSP [" + new Date() + "]: Product fetch logic complete. displayMessage = '" + displayMessage + "'");
	} catch (Exception e) {
		System.err.println("### PRODUCTS_JSP [" + new Date() + "]: ERROR fetching products: " + e.getMessage());
		e.printStackTrace(); // Keep printStackTrace for detailed errors
		pageContext.setAttribute("errorMessage", "Could not load products.", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
	}

	if (productList == null) productList = Collections.emptyList();
	System.out.println("### PRODUCTS_JSP [" + new Date() + "]: Final productList size: " + productList.size());

	// --- Wishlist Logic ---
	Set<Integer> userWishlistProductIds = new HashSet<>();
	if (currentUserForProducts != null) {
		WishlistDao wishlistDao = new WishlistDao();
		List<Wishlist> userWishlist = wishlistDao.getListByUserId(currentUserForProducts.getUserId());
		if (userWishlist != null) {
			userWishlistProductIds = userWishlist.stream()
					.map(Wishlist::getProductId)
					.collect(Collectors.toSet());
		} else {
			System.err.println("### PRODUCTS_JSP [" + new Date() + "]: WARNING: Could not retrieve wishlist for user " + currentUserForProducts.getUserId());
		}
	}
	System.out.println("### PRODUCTS_JSP [" + new Date() + "]: Final userWishlistProductIds size: " + userWishlistProductIds.size());

	Map<Integer, Float> averageRatingsMap = new HashMap<>();
	if (productList != null && !productList.isEmpty()) {
		ReviewDao reviewDao = new ReviewDao();
		for (Product p : productList) {
			averageRatingsMap.put(p.getProductId(), reviewDao.getAverageRatingByProductId(p.getProductId()));
		}
	}

	Map<Integer, String> vendorNameMap = new HashMap<>();
	if (productList != null && !productList.isEmpty()) {
		VendorDao vendorDao = new VendorDao(); // Instantiate VendorDao
		// Get unique vendor IDs from the product list
		Set<Integer> vendorIds = productList.stream()
				.map(Product::getVendorId)
				.filter(vid -> vid > 0) // Filter out potential 0 or negative IDs
				.collect(Collectors.toSet());

		// Fetch details only for the vendors present in the current product list
		if (!vendorIds.isEmpty()) {
			for (int vid : vendorIds) {
				if (!vendorNameMap.containsKey(vid)) { // Avoid refetching if already got
					Vendor vendor = vendorDao.getVendorById(vid);
					if (vendor != null) {
						vendorNameMap.put(vid, vendor.getShopName());
					} else {
						vendorNameMap.put(vid, "Unknown Seller"); // Fallback
					}
				}
			}
		}
	}
	request.setAttribute("vendorNames", vendorNameMap); // Set attribute for EL

	// Set attributes for EL access
	request.setAttribute("productsToDisplay", productList);
	request.setAttribute("pageDisplayMessage", displayMessage);
	request.setAttribute("pageTitle", pageTitle);
	request.setAttribute("userWishlistPids", userWishlistProductIds);
	request.setAttribute("averageRatings", averageRatingsMap);

	// !!! Confirmation log !!!
	System.out.println("### PRODUCTS_JSP [" + new Date() + "]: FINISHED setup. 'message' attribute in session is: " + (session.getAttribute("message") != null ? "PRESENT" : "ABSENT"));

%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title><c:out value="${pageTitle}"/> - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		/* ... Paste styles from previous products.jsp refactor here ... */
		body { background-color: #f8f9fa; }
		.product-card { position: relative; border: 1px solid #e9ecef; transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out; background-color: #fff; border-radius: 0.375rem; overflow: hidden; }
		.product-card:hover { transform: translateY(-5px); box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1); }
		.product-card a { text-decoration: none; color: #212529; }
		.product-card a:hover { text-decoration: none; }
		.product-card .card-img-container { height: 220px; display: flex; align-items: center; justify-content: center; padding: 15px; overflow: hidden; background-color: #f8f9fa; }
		.product-card .card-img-top { max-height: 100%; max-width: 100%; object-fit: contain; transition: transform 0.3s ease; }
		.product-card:hover .card-img-top { transform: scale(1.05); }
		.product-card .card-body { padding: 1rem; text-align: center; }
		.product-card .card-title { font-size: 1rem; font-weight: 600; margin-bottom: 0.5rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #343a40; }
		.product-card .card-title:hover { color: #0d6efd; }
		.product-card .price-container { margin-top: 0.75rem; font-size: 0.9rem; line-height: 1.5; }
		.product-card .price-discounted { font-size: 1.15rem; font-weight: 700; color: #dc3545; }
		.product-card .price-original { text-decoration: line-through; color: #6c757d; margin-left: 0.5rem; font-size: 0.9em; }
		.product-card .discount-badge { color: #198754; font-weight: 600; margin-left: 0.5rem; font-size: 0.85em; }
		.wishlist-icon-container { position: absolute; top: 10px; right: 10px; z-index: 10; }
		.wishlist-btn { background-color: rgba(255, 255, 255, 0.8); border: 1px solid #eee; border-radius: 50%; width: 35px; height: 35px; display: inline-flex; align-items: center; justify-content: center; padding: 0; box-shadow: 0 1px 3px rgba(0,0,0,0.1); transition: background-color 0.2s ease; }
		.wishlist-btn:hover { background-color: rgba(255, 255, 255, 1); border-color: #ddd; }
		.wishlist-btn i { font-size: 1rem; line-height: 1; }
		.wishlist-btn .fa-heart.in-wishlist { color: #dc3545; }
		.wishlist-btn .fa-heart.not-in-wishlist { color: #adb5bd; }
		.wishlist-btn:hover .fa-heart.not-in-wishlist { color: #6c757d; }
		.no-products-found { padding: 3rem 1rem; text-align: center; }
		.no-products-found img { max-width: 200px; opacity: 0.7; margin-bottom: 1rem; }
		.no-products-found h4 { color: #6c757d; }
		.product-vendor {
			font-size: 0.85em;
		}
		.product-vendor a {
			font-weight: 500;
			/* text-decoration: none; */ /* Optional */
		}
		/* Style for the heading hiding */
		#page-message-heading { /* ID kept from previous step */
			/* No transition needed if just hiding */
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%@include file="Components/navbar.jsp"%>

<main class="container flex-grow-1 my-4">

	<h4 class="text-center mb-4" id="page-message-heading"><c:out value="${pageDisplayMessage}"/></h4>

	<%@include file="Components/alert_message.jsp"%>

	<div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
		<c:if test="${empty productsToDisplay}">
			<div class="col-12">
				<div class="no-products-found">
					<img src="Images/no-results.png" alt="No Products Found"> <%-- Use forward slash --%>
					<h4>No products match your criteria.</h4>
					<a href="products.jsp" class="btn btn-outline-primary mt-3">View All Products</a>
				</div>
			</div>
		</c:if>

		<%-- ============================================= --%>
		<%-- == ADD THIS PRODUCT CARD CODE BACK INSIDE! == --%>
		<%-- ============================================= --%>
		<c:forEach var="product" items="${productsToDisplay}">
			<div class="col">
				<div class="card h-100 product-card">

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
					</div>

						<%-- Link covering image and title/price area --%>
					<a href="viewProduct.jsp?pid=${product.productId}">
						<div class="card-img-container">
							<img src="${s3BaseUrl}${product.productImages}" class="card-img-top" alt="${product.productName}">
						</div>
						<div class="card-body">
							<h5 class="card-title" title="${product.productName}"><c:out value="${product.productName}"/></h5>
							<div class="product-vendor mb-2"> <%-- Add margin-bottom --%>
								<small class="text-muted">
									Sold by:
										<%-- Look up name in the map --%>
									<c:set var="vendorName" value="${vendorNames[product.vendorId]}" />
									<a href="vendor_store.jsp?vid=${product.vendorId}" class="link-secondary"> <%-- Link to vendor page --%>
										<c:out value="${not empty vendorName ? vendorName : 'Phong Shop'}"/> <%-- Display name or default --%>
									</a>
								</small>
							</div>
							<div class="price-container">
                                    <span class="price-discounted">
                                        <fmt:formatNumber value="${product.productPriceAfterDiscount}" type="currency" currencySymbol="£"/>
                                    </span>
								<c:if test="${product.productDiscount > 0}">
                                        <span class="price-original">
                                            <fmt:formatNumber value="${product.productPrice}" type="currency" currencySymbol="£"/>
                                        </span>
									<span class="discount-badge">
                                            ${product.productDiscount}% off
                                        </span>
								</c:if>
									<%--Show rating--%>
								<c:set var="avgRating" value="${averageRatings[product.productId]}"/>
								<c:if test="${not empty avgRating and avgRating > 0}">
									<div class="star-rating mb-1" title="${avgRating} out of 5 stars">
										<small> <%-- Use small tag --%>
											<c:forEach var="i" begin="1" end="5">
												<i class="fa-${avgRating >= i ? 'solid' : (avgRating >= i-0.5 ? 'solid fa-star-half-stroke' : 'regular')} fa-star text-warning"></i>
											</c:forEach>
										</small>
									</div>
								</c:if>
							</div>

						</div>
					</a>
				</div> <%-- End card --%>
			</div> <%-- End col --%>
		</c:forEach> <%-- End product loop --%>
		<%-- ============================================= --%>
		<%-- ============================================= --%>

	</div> <%-- End row --%>
</main>

<%@include file="footer.jsp"%>

</body>
</html>