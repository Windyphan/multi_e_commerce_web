<%-- products.jsp --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.dao.ProductDao"%>
<%@page import="com.phong.dao.CategoryDao"%>
<%@page import="com.phong.dao.WishlistDao"%>
<%@page import="com.phong.dao.ReviewDao"%>
<%@page import="com.phong.dao.VendorDao"%>
<%@page import="com.phong.entities.*"%> <%-- Import all entities --%>
<%@page import="java.util.*"%> <%-- Import common utils --%>
<%@page import="java.util.stream.Collectors"%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Data Fetching and Logic --%>
<%
	// *** START PRODUCTS LOGGING ***
	System.out.println("=== PRODUCTS_JSP [" + new Date() + "]: Request received ===");

	User currentUserForProducts = (User) session.getAttribute("activeUser");
	System.out.println("### PRODUCTS_JSP [" + new Date() + "]: currentUserForProducts is null? " + (currentUserForProducts == null));

	// Get request parameters
	String searchKey = request.getParameter("search");
	String categoryIdParam = request.getParameter("category");
	System.out.println("### PRODUCTS_JSP [" + new Date() + "]: searchKey = '" + searchKey + "', categoryIdParam = '" + categoryIdParam + "'");

	// DAO instances
	ProductDao productDao = new ProductDao();
	CategoryDao categoryDao = new CategoryDao(); // Needed for category name lookup
	ReviewDao reviewDao = new ReviewDao();     // Needed for average ratings
	VendorDao vendorDao = new VendorDao();       // Needed for vendor names

	// --- Fetch products based on parameters ---
	List<Product> productList = null;
	String pageTitle = "All Products";
	String displayMessage = "";
	String categoryNameForMessage = null;
	int activeCategoryId = 0; // Default active category for sidebar

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
			activeCategoryId = -1; // Indicate no category is active during search
		} else if (categoryIdParam != null) { // Check category ID
			categoryIdParam = categoryIdParam.trim();
			try {
				activeCategoryId = Integer.parseInt(categoryIdParam); // Set active category
				if (activeCategoryId > 0) { // Specific category
					productList = productDao.getAllProductsByCategoryId(activeCategoryId);
					categoryNameForMessage = categoryDao.getCategoryName(activeCategoryId); // Simple fetch is ok now

					if (categoryNameForMessage != null) {
						pageTitle = categoryNameForMessage + " Products";
						displayMessage = "Showing results for \"" + categoryNameForMessage + "\"";
					} else {
						pageTitle = "Products";
						displayMessage = "Showing results for selected category";
					}
				} else { // category=0 means "All Products"
					productList = productDao.getAllProducts();
					activeCategoryId = 0; // Ensure "All Products" is active
				}
			} catch (NumberFormatException nfe) {
				System.err.println("Invalid category ID format received: " + categoryIdParam);
				productList = productDao.getAllProducts();
				displayMessage = "Invalid category specified. Showing All Products.";
				activeCategoryId = 0; // Default to all
			}
		} else { // No search, no category -> show all
			productList = productDao.getAllProducts();
			activeCategoryId = 0; // Set "All Products" active
		}
		System.out.println("### PRODUCTS_JSP [" + new Date() + "]: Product fetch logic complete. displayMessage = '" + displayMessage + "'");
	} catch (Exception e) {
		System.err.println("### PRODUCTS_JSP [" + new Date() + "]: ERROR fetching products: " + e.getMessage());
		e.printStackTrace();
		pageContext.setAttribute("message", new Message("Could not load products: " + e.getMessage(), "error", "alert-danger"), PageContext.REQUEST_SCOPE); // Use request scope for page load errors
	}

	// Ensure list is not null
	if (productList == null) productList = Collections.emptyList();
	System.out.println("### PRODUCTS_JSP [" + new Date() + "]: Final productList size: " + productList.size());

	// --- Fetch Wishlist Logic ---
	Set<Integer> userWishlistProductIds = new HashSet<>();
	if (currentUserForProducts != null) {
		WishlistDao wishlistDao = new WishlistDao();
		List<Wishlist> userWishlist = wishlistDao.getListByUserId(currentUserForProducts.getUserId());
		if (userWishlist != null) {
			userWishlistProductIds = userWishlist.stream().map(Wishlist::getProductId).collect(Collectors.toSet());
		} else { /* Log warning */ }
	}
	System.out.println("### PRODUCTS_JSP [" + new Date() + "]: Final userWishlistProductIds size: " + userWishlistProductIds.size());

	// --- Fetch Average Ratings ---
	Map<Integer, Float> averageRatingsMap = new HashMap<>();
	if (!productList.isEmpty()) {
		for (Product p : productList) {
			averageRatingsMap.put(p.getProductId(), reviewDao.getAverageRatingByProductId(p.getProductId()));
		}
	}
	System.out.println("### PRODUCTS_JSP [" + new Date() + "]: Fetched " + averageRatingsMap.size() + " average ratings.");

	// --- Fetch Vendor Names ---
	Map<Integer, String> vendorNameMap = new HashMap<>();
	if (!productList.isEmpty()) {
		Set<Integer> vendorIds = productList.stream().map(Product::getVendorId).filter(vid -> vid > 0).collect(Collectors.toSet());
		if (!vendorIds.isEmpty()) {
			for (int vid : vendorIds) {
				if (!vendorNameMap.containsKey(vid)) {
					Vendor vendor = vendorDao.getVendorById(vid);
					if (vendor != null && vendor.isApproved()) {
						vendorNameMap.put(vid, vendor.getShopName());
					} else { vendorNameMap.put(vid, "Phong Shop"); } // Fallback
				}
			}
		}
	}
	System.out.println("### PRODUCTS_JSP [" + new Date() + "]: Fetched " + vendorNameMap.size() + " vendor names.");

	// --- Set attributes for EL access ---
	request.setAttribute("productsToDisplay", productList);
	request.setAttribute("pageDisplayMessage", displayMessage);
	request.setAttribute("pageTitle", pageTitle);
	request.setAttribute("userWishlistPids", userWishlistProductIds);
	request.setAttribute("averageRatings", averageRatingsMap); // Pass ratings map
	request.setAttribute("vendorNames", vendorNameMap);         // Pass vendor names map
	request.setAttribute("activeCategoryId", activeCategoryId); // Pass active category for sidebar

	// Assuming navbarCategoryList is set by navbar include
	// request.setAttribute("sidebarCategoryList", request.getAttribute("navbarCategoryList")); // Pass to sidebar

	System.out.println("### PRODUCTS_JSP [" + new Date() + "]: FINISHED setup. 'message' attribute in session is: " + (session.getAttribute("message") != null ? "PRESENT" : "ABSENT"));
%>
<script>
	// Make server-side data available to client-side JS safely
	const s3BaseUrl = '<c:out value="${s3BaseUrl}"/>';
	const isUserLoggedIn = ${not empty sessionScope.activeUser};
	// Use try-catch for JSON parsing as attribute might be missing or invalid
	let userWishlistPids = new Set();
	try {
		const wishlistJson = '<c:out value="${wishlistJson}" escapeXml="false"/>'; // Get JSON string set in JSP scriptlet
		if (wishlistJson) {
			userWishlistPids = new Set(JSON.parse(wishlistJson));
		}
	} catch(e) {
		console.error("Error parsing wishlist JSON:", e);
		// Keep userWishlistPids as empty Set
	}
	console.log("Client-side Wishlist PIDs:", userWishlistPids);
	console.log("Client-side LoggedIn:", isUserLoggedIn);
	console.log("Client-side S3 Base URL:", s3BaseUrl);
</script>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title><c:out value="${pageTitle}"/> - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		/* Include Sidebar CSS */
		.sidebar{background-color:#ffffff;padding:1.5rem;border-radius:.375rem;box-shadow:0 1px 3px rgba(0,0,0,.05);height:fit-content}
		.sidebar .sidebar-title{font-weight:600;font-size:1.1rem;margin-bottom:1rem;padding-bottom:.5rem;border-bottom:1px solid #eee}
		.sidebar .list-group-item{border:none;padding:.6rem 0;font-size:.95rem;color:#495057;background-color:transparent;border-left:3px solid transparent;transition:background-color .2s ease,color .2s ease,border-left .2s ease}
		.sidebar .list-group-item:hover{color:#0d6efd;background-color:#f1f3f5}
		.sidebar .list-group-item.active{color:#0d6efd;background-color:#e7f1ff;border-left:3px solid #0d6efd;font-weight:600}
		.sidebar a{text-decoration:none}

		/* Include Product Card CSS */
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
		.product-card .price-container { margin-top: 0.5rem; font-size: 0.9rem; line-height: 1.5; } /* Reduced top margin */
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
		.product-vendor { font-size: 0.85em; margin-top: 0.25rem; } /* Added margin-top */
		.product-vendor a { font-weight: 500; }
		.star-rating { font-size: 0.85rem; margin-top: 0.25rem;} /* Rating styles */
		.star-rating i { margin-right: 1px; }
		.star-rating .text-warning { color: #ffc107 !important; }
		#page-message-heading { /* Styles for fading heading if used */ }
	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%@include file="Components/navbar.jsp"%>

<main class="container-fluid flex-grow-1 my-4">
	<%@include file="Components/alert_message.jsp"%>

	<div class="row g-4">

		<%-- === Sidebar Column === --%>
		<div class="col-lg-3">
			<%@include file="Components/sidebar.jsp"%> <%-- Sidebar Include --%>
		</div>

		<%-- === Main Content Column === --%>
		<div class="col-lg-9">

			<h4 class="text-center mb-4" id="page-message-heading"><c:out value="${pageDisplayMessage}"/></h4>

			<div id="product-grid-container">
				<div class="row row-cols-1 row-cols-sm-2 row-cols-md-2 row-cols-lg-3 g-4"> <%-- Grid cols adjusted --%>
					<c:if test="${empty productsToDisplay}">
						<div class="col-12">
							<div class="no-products-found">
								<img src="Images/no-results.png" alt="No Products Found">
								<h4>No products match your criteria.</h4>
								<a href="products.jsp" class="btn btn-outline-primary mt-3">View All Products</a>
							</div>
						</div>
					</c:if>

					<c:forEach var="product" items="${productsToDisplay}">
						<div class="col">
							<div class="card h-100 product-card">
								<div class="wishlist-icon-container">
									<c:choose>
										<c:when test="${empty sessionScope.activeUser}"><a href="login.jsp" class="btn wishlist-btn" title="Login to add to wishlist"><i class="fa-regular fa-heart not-in-wishlist"></i></a></c:when>
										<c:otherwise>
											<c:set var="isInWishlist" value="${userWishlistPids.contains(product.productId)}"/>
											<c:choose>
												<c:when test="${isInWishlist}"><a href="WishlistServlet?pid=${product.productId}&op=remove" class="btn wishlist-btn" title="Remove from Wishlist"><i class="fa-solid fa-heart in-wishlist"></i></a></c:when>
												<c:otherwise><a href="WishlistServlet?pid=${product.productId}&op=add" class="btn wishlist-btn" title="Add to Wishlist"><i class="fa-regular fa-heart not-in-wishlist"></i></a></c:otherwise>
											</c:choose>
										</c:otherwise>
									</c:choose>
								</div>

								<a href="viewProduct.jsp?pid=${product.productId}">
									<div class="card-img-container">
										<img src="${s3BaseUrl}${product.productImages}" class="card-img-top" alt="${product.productName}">
									</div>
									<div class="card-body">
										<h5 class="card-title" title="${product.productName}"><c:out value="${product.productName}"/></h5>

											<%-- Vendor Name --%>
										<div class="product-vendor mb-1">
											<small class="text-muted">
												Sold by:
												<c:set var="vendorName" value="${vendorNames[product.vendorId]}" />
												<a href="vendor_store.jsp?vid=${product.vendorId}" class="link-secondary">
													<c:out value="${not empty vendorName ? vendorName : 'Phong Shop'}"/>
												</a>
											</small>
										</div>

											<%-- Average Rating --%>
										<c:set var="avgRating" value="${averageRatings[product.productId]}"/>
										<c:if test="${not empty avgRating and avgRating > 0}">
											<div class="star-rating mb-1" title="<fmt:formatNumber value='${avgRating}' maxFractionDigits='1'/> out of 5 stars">
												<small>
													<c:forEach var="i" begin="1" end="5">
														<i class="fa-${avgRating >= i ? 'solid' : (avgRating >= i-0.5 ? 'solid fa-star-half-stroke' : 'regular')} fa-star text-warning"></i>
													</c:forEach>
													<span class="text-muted ms-1">(<fmt:formatNumber value='${avgRating}' maxFractionDigits='1'/>)</span> <%-- Numerical rating --%>
												</small>
											</div>
										</c:if>
										<c:if test="${empty avgRating or avgRating <= 0}">
											<div class="star-rating mb-1 text-muted"><small>No reviews yet</small></div>
										</c:if>

											<%-- Price --%>
										<div class="price-container">
											<span class="price-discounted"><fmt:formatNumber value="${product.productPriceAfterDiscount}" type="currency" currencySymbol="£"/></span>
											<c:if test="${product.productDiscount > 0}">
												<span class="price-original"><fmt:formatNumber value="${product.productPrice}" type="currency" currencySymbol="£"/></span>
												<span class="discount-badge">${product.productDiscount}% off</span>
											</c:if>
										</div>
									</div>
								</a>
							</div> <%-- End card --%>
						</div> <%-- End col --%>
					</c:forEach> <%-- End product loop --%>
				</div> <%-- End Product Grid Row --%>
			</div> <%-- End product-grid-container --%>
		</div> <%-- End Main Content Column --%>
	</div> <%-- End Row for Sidebar/Content --%>
</main>

<%@include file="Components/footer.jsp"%>
<script>
	document.addEventListener('DOMContentLoaded', () => {
		const filterForm = document.getElementById('filter-form');
		const productGridContainer = document.getElementById('product-grid-container'); // Target for replacing content
		const pageMessageHeading = document.getElementById('page-message-heading'); // To update status

		// Function to gather current filter values
		function getFilterData() {
			const formData = new FormData(filterForm);
			const data = {
				// Use getAll for checkboxes as there can be multiple values
				categories: formData.getAll('category'), // Gets array of checked category IDs
				minPrice: formData.get('minPrice'),
				maxPrice: formData.get('maxPrice'),
				ratingSort: formData.get('ratingSort') || '' // Default to empty string if no sort selected
				// Add other filters (search term?)
				// search: new URLSearchParams(window.location.search).get('search') || ''
			};
			return data;
		}

		// Function to handle fetching and displaying filtered products (AJAX Placeholder)
		function applyFilters() {
			const filters = getFilterData();
			console.log("Applying Filters:", filters); // Log the selected filters

			// --- AJAX/Fetch Implementation (To be added) ---
			// 1. Show a loading indicator
			if(pageMessageHeading) pageMessageHeading.textContent = 'Loading products...';
			if(productGridContainer) productGridContainer.innerHTML = '<div class="text-center p-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>'; // Basic spinner

			// 2. Construct URLSearchParams or JSON payload for the backend
			const params = new URLSearchParams();
			filters.categories.forEach(catId => params.append('category', catId));
			if (filters.minPrice) params.append('minPrice', filters.minPrice);
			if (filters.maxPrice) params.append('maxPrice', filters.maxPrice);
			if (filters.ratingSort) params.append('ratingSort', filters.ratingSort);
			// if (filters.search) params.append('search', filters.search); // Add search if needed

			// 3. Use Fetch API to send request to a backend endpoint (e.g., /FilterProductsServlet)
			//    This endpoint needs to query the DB using the filters and return JSON
			fetch('FilterProductsServlet?' + params.toString(), { // Example using GET with params
				method: 'GET', // Or POST if sending JSON body
				headers: {
					'Accept': 'application/json'
					// 'Content-Type': 'application/json' // If sending POST with JSON body
				}
				// body: JSON.stringify(filters) // If sending POST
			})
					.then(response => {
						if (!response.ok) {
							throw new Error(`HTTP error ${response.status}`);
						}
						return response.json(); // Expecting JSON array of products
					})
					.then(data => { // Rename parameter to 'data' for clarity
						console.log("Received data:", data); // Log the whole structure

						if (data && data.error) {
							// ... handle server error ...
						} else if (data && Array.isArray(data.products)) { // Check data.products
							console.log("Rendering products array:", data.products);
							console.log("Vendor names:", data.vendorNames); // Log maps too
							console.log("Average ratings:", data.averageRatings);

							// *** CORRECTED CALL: Pass individual parts of the data object ***
							renderProductGrid(data.products, data.vendorNames, data.averageRatings);

							if(pageMessageHeading) pageMessageHeading.textContent = `Showing ${data.products.length} product(s)`;
						} else {
							console.error("Invalid data structure received:", data);
							renderProductGrid([], {}, {}); // Pass empty structures on error
							if(pageMessageHeading) pageMessageHeading.textContent = 'Error: Invalid data received';
						}
					})
					.catch(error => {
						console.error('Error applying filters:', error);
						if(pageMessageHeading) pageMessageHeading.textContent = 'Error loading products';
						if(productGridContainer) productGridContainer.innerHTML = '<div class="alert alert-danger">Could not load products. Please try again later.</div>';
					});
			// --- End AJAX/Fetch ---
		}

		// Function to dynamically render the product grid (Placeholder - Requires detailed implementation)
		function renderProductGrid(productArray, vendorNameMap, ratingMap) {
			const productGridContainer = document.getElementById('product-grid-container');
			if (!productGridContainer) return;
			productGridContainer.innerHTML = ''; // Clear existing products

			if (!productArray || productArray.length === 0) {
				productGridContainer.innerHTML = `
            <div class="col-12">
                <div class="no-products-found">
                    <img src="Images/no-results.png" alt="No Products Found">
                    <h4>No products match your criteria.</h4>
                    <a href="products.jsp" class="btn btn-outline-primary mt-3">View All Products</a>
                </div>
            </div>`;
				return;
			}

			const productGridRow = document.createElement('div');
			// Add necessary grid classes based on how many items per row you want
			productGridRow.className = 'row row-cols-1 row-cols-sm-2 row-cols-md-2 row-cols-lg-3 g-4';
			let allCardsHtml = ''; // Build HTML string efficiently

			// ** IMPORTANT: You need JS templating here **
			// This is where you'd loop through the 'products' JSON array and build the
			// HTML for each product card dynamically using JavaScript.
			// This involves creating divs, imgs, spans, setting attributes, text content, etc.
			// Libraries like Handlebars.js or just plain JS template literals can help.
			productArray.forEach(product => {
				// --- Prepare data for this card ---
				try {
					// --- Prepare data (same as before) ---
					const productId = product.productId;
					const productName = product.productName || 'N/A';
					const productImages = product.productImages || '';
					const vendorId = product.vendorId;
					const vendorName = vendorNameMap[vendorId] || 'Phong Shop';
					const avgRating = ratingMap[productId] || 0;
					const isInWishlist = userWishlistPids.has(productId);

					// --- Build Helper HTML Strings (same logic as before) ---
					let wishlistButtonHtml = '';
					try {
						if (!isUserLoggedIn) {
							wishlistButtonHtml = '<a href="login.jsp" class="btn wishlist-btn" title="Login to add to wishlist"><i class="fa-regular fa-heart not-in-wishlist"></i></a>';
						} else {
							if (isInWishlist) {
								wishlistButtonHtml = '<a href="WishlistServlet?pid=' + productId + '&op=remove" class="btn wishlist-btn" title="Remove from Wishlist"><i class="fa-solid fa-heart in-wishlist"></i></a>';
							} else {
								wishlistButtonHtml = '<a href="WishlistServlet?pid=' + productId + '&op=add" class="btn wishlist-btn" title="Add to Wishlist"><i class="fa-regular fa-heart not-in-wishlist"></i></a>';
							}
						}
					} catch(wlError) { console.error("Wishlist HTML Error", wlError); wishlistButtonHtml = ''; }

					let ratingStarsHtml = '';
					try {
						if (avgRating > 0) {
							let stars = '';
							for (let i = 1; i <= 5; i++) {
								if (avgRating >= i) stars += '<i class="fa-solid fa-star text-warning"></i>';
								else if (avgRating >= i - 0.5) stars += '<i class="fa-solid fa-star-half-stroke text-warning"></i>';
								else stars += '<i class="fa-regular fa-star text-warning"></i>';
							}
							const ratingFormatted = avgRating.toLocaleString(undefined,{minimumFractionDigits: 1, maximumFractionDigits: 1});
							ratingStarsHtml = '<div class="star-rating mb-1" title="' + ratingFormatted + ' out of 5 stars"><small>' + stars + ' <span class="text-muted ms-1">(' + ratingFormatted + ')</span></small></div>';
						} else {
							ratingStarsHtml = '<div class="star-rating mb-1 text-muted"><small>No reviews yet</small></div>';
						}
					} catch (rateError) { console.error("Rating HTML Error", rateError); ratingStarsHtml = ''; }


					let priceHtml = '';
					try {
						const formatter = new Intl.NumberFormat('en-GB', { style: 'currency', currency: 'GBP' });
						const priceAfterDiscountNum = Number(product.productPriceAfterDiscount);
						const priceOriginalNum = Number(product.productPrice);
						const discountNum = Number(product.productDiscount);

						const discountedPriceFormatted = !isNaN(priceAfterDiscountNum) ? formatter.format(priceAfterDiscountNum) : 'N/A';
						const originalPriceFormatted = !isNaN(priceOriginalNum) ? formatter.format(priceOriginalNum) : '';

						priceHtml = '<span class="price-discounted">' + discountedPriceFormatted + '</span>';
						if (!isNaN(discountNum) && discountNum > 0) {
							if (originalPriceFormatted) {
								priceHtml += ' <span class="price-original">' + originalPriceFormatted + '</span>';
							}
							priceHtml += ' <span class="discount-badge">' + discountNum + '% off</span>';
						}
					} catch (priceError) { console.error("Price HTML Error", priceError); priceHtml = ''; }

					// --- Assemble the card HTML using String Concatenation ---
					// Escape quotes within attributes if necessary, though less needed here
					// Use encodeURIComponent for URL parameters if they could contain special chars
					let cardHtml = '';
					cardHtml += '<div class="col">';
					cardHtml += '  <div class="card h-100 product-card">';
					cardHtml += '    <div class="wishlist-icon-container">' + wishlistButtonHtml + '</div>';
					cardHtml += '    <a href="viewProduct.jsp?pid=' + productId + '">'; // Basic concatenation
					cardHtml += '      <div class="card-img-container">';
					// Ensure s3BaseUrl and productImages are defined and valid strings
					cardHtml += '        <img src="' + s3BaseUrl + (productImages || '') + '" class="card-img-top" alt="' + (productName || '') + '">';
					cardHtml += '      </div>';
					cardHtml += '      <div class="card-body">';
					cardHtml += '        <h5 class="card-title" title="' + (productName || '') + '">' + (productName || '') + '</h5>';
					cardHtml += '        <div class="product-vendor mb-1">';
					cardHtml += '          <small class="text-muted">Sold by: <a href="vendor_store.jsp?vid=' + vendorId + '" class="link-secondary">' + vendorName + '</a></small>';
					cardHtml += '        </div>';
					cardHtml +=          ratingStarsHtml; // Inject rating string
					cardHtml += '        <div class="price-container">';
					cardHtml +=             priceHtml; // Inject price string
					cardHtml += '        </div>';
					cardHtml += '      </div>';
					cardHtml += '    </a>';
					cardHtml += '  </div>';
					cardHtml += '</div>';

					allCardsHtml += cardHtml;

				} catch (cardError) {
					console.error(`Error rendering card structure for PID ${product ? product.productId : 'UNKNOWN'}:`, cardError);
					allCardsHtml += `<div class="col"><div class="card h-100"><div class="card-body text-danger">Error loading product</div></div></div>`;
				}
			}); // End forEach

			productGridRow.innerHTML = allCardsHtml; // Set the row's HTML all at once
			console.log(`  PID ${productId} - Generated all card HTML:`, allCardsHtml); // <-- ADD LOG
			productGridContainer.appendChild(productGridRow); // Add completed row to container
		}


		// --- Attach Event Listeners ---
		filterForm.addEventListener('change', applyFilters);

		// Initial load (Optional - might load initial state via JSP EL)
		// applyFilters(); // Apply filters based on initial state (e.g., URL params)?

	});
</script>
</body>
</html>