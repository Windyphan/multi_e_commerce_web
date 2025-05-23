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
	User currentUserForProducts = (User) session.getAttribute("activeUser");
	final int PRODUCTS_PER_PAGE = 9;
	int currentPage = 1;
	// --- Read ALL parameters ---
	String pageParam = request.getParameter("page");
	String searchKey = request.getParameter("search");
	String[] categoryParams = request.getParameterValues("category"); // Read categories
	String minPriceStr = request.getParameter("minPrice");           // Read minPrice
	String maxPriceStr = request.getParameter("maxPrice");           // Read maxPrice
	String ratingSort = request.getParameter("ratingSort");          // Read ratingSort

	// --- Parse Parameters ---
	if (pageParam != null) if (pageParam != null) {
		try {
			currentPage = Integer.parseInt(pageParam);
			if (currentPage < 1) currentPage = 1;
		} catch (NumberFormatException e) {
			currentPage = 1; // Default if parameter is invalid
		}
	}
	if (searchKey != null) searchKey = searchKey.trim();

	List<Integer> categoryIds = new ArrayList<>();
	if (categoryParams != null) {
		for (String catIdStr : categoryParams) {
			try {
				int catId = Integer.parseInt(catIdStr);
				if (catId > 0) categoryIds.add(catId);
			} catch (NumberFormatException e) { /* ignore */ }
		}
	}

	Float minPrice = null;
	Float maxPrice = null;
	try {
		if (minPriceStr != null && !minPriceStr.trim().isEmpty()) minPrice = Float.parseFloat(minPriceStr.trim());
		if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) maxPrice = Float.parseFloat(maxPriceStr.trim());
		// Add validation (min>=0, max>=min) if needed
	} catch (NumberFormatException e) { /* ignore invalid price */ }

	if (ratingSort != null && !ratingSort.equals("asc") && !ratingSort.equals("desc")) {
		ratingSort = null; // Default if invalid
	}

	// DAO instances
	ProductDao productDao = new ProductDao();
	CategoryDao categoryDao = new CategoryDao();
	ReviewDao reviewDao = new ReviewDao();
	VendorDao vendorDao = new VendorDao();

	// --- Fetch products based on ALL parameters ---
	List<Product> productList = null;
	String pageTitle = "Products"; // Adjust title logic
	String displayMessage = "Showing Products"; // Adjust message logic
	int activeCategoryId = categoryIds.isEmpty() ? 0 : -1; // Rough logic for sidebar active state
	int totalProducts = 0;

	// --- Determine which DAO methods to call ---

	try {
		boolean isSearch = (searchKey != null && !searchKey.isEmpty());
		boolean isFiltered = !categoryIds.isEmpty() || minPrice != null || maxPrice != null || ratingSort != null;

		if (isSearch) {
			totalProducts = productDao.getTotalProductCountBySearch(searchKey); // Or a combined filtered+search count?
			productList = productDao.getProductsBySearchPaginated(searchKey, currentPage, PRODUCTS_PER_PAGE); // Or filtered+search paginated?
			pageTitle = "Search Results for '" + searchKey + "'";
			displayMessage = "Showing results for \"" + searchKey + "\"";
			activeCategoryId = -1;
		} else { // No search key, apply filters or show all
			// Call DAO methods that accept filter criteria
			totalProducts = productDao.getFilteredProductCount(categoryIds, minPrice, maxPrice, null); // Pass null for searchKey here
			productList = productDao.getFilteredProductsPaginated(categoryIds, minPrice, maxPrice, ratingSort, null, currentPage, PRODUCTS_PER_PAGE); // Pass null for searchKey
			activeCategoryId = categoryIds.size() == 1 ? categoryIds.get(0) : (categoryIds.isEmpty() ? 0 : -1); // Update active category logic

			// Set appropriate display message based on filters applied
			if(isFiltered) {
				displayMessage = "Showing filtered products";
				pageTitle = "Filtered Products";
				if (activeCategoryId > 0) {
					pageTitle = categoryDao.getCategoryName(activeCategoryId) + " Products"; // Refine title
				}
			} else {
				displayMessage = "Showing all products";
				pageTitle = "All Products";
			}
		}

	} catch (Exception e) { /* Handle fetch errors */ }

	// Calculate total pages (same as before)
	int totalPages = (int) Math.ceil((double) totalProducts / PRODUCTS_PER_PAGE);
	if (totalPages == 0) totalPages = 1; // Ensure at least 1 page even if no products
	if (currentPage > totalPages) {
		currentPage = totalPages; // Adjust if requested page > total pages
		// Optional: Re-fetch products for the last page if needed, but often okay to show empty if logic prevents this state
	}

	// Ensure list is not null
	if (productList == null) productList = Collections.emptyList();
	// --- Fetch Wishlist Logic ---
	Set<Integer> userWishlistProductIds = new HashSet<>();
	if (currentUserForProducts != null) {
		WishlistDao wishlistDao = new WishlistDao();
		List<Wishlist> userWishlist = wishlistDao.getListByUserId(currentUserForProducts.getUserId());
		if (userWishlist != null) {
			userWishlistProductIds = userWishlist.stream().map(Wishlist::getProductId).collect(Collectors.toSet());
		} else { /* Log warning */ }
	}
	// --- Fetch Average Ratings ---
	Map<Integer, Float> averageRatingsMap = new HashMap<>();
	if (!productList.isEmpty()) {
		for (Product p : productList) {
			averageRatingsMap.put(p.getProductId(), reviewDao.getAverageRatingByProductId(p.getProductId()));
		}
	}
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

	// --- Set attributes for EL access ---
	request.setAttribute("productsToDisplay", productList);
	request.setAttribute("pageDisplayMessage", displayMessage);
	request.setAttribute("pageTitle", pageTitle);
	request.setAttribute("userWishlistPids", userWishlistProductIds);
	request.setAttribute("averageRatings", averageRatingsMap); // Pass ratings map
	request.setAttribute("vendorNames", vendorNameMap);         // Pass vendor names map
	request.setAttribute("activeCategoryId", activeCategoryId); // For sidebar state
	request.setAttribute("currentPage", currentPage);
	request.setAttribute("totalPages", totalPages);
	// Pass back filter parameters so they can be included in pagination links
	request.setAttribute("searchKey", searchKey);
	request.setAttribute("selectedCategories", categoryIds); // Pass selected categories
	request.setAttribute("minPrice", minPrice);
	request.setAttribute("maxPrice", maxPrice);
	request.setAttribute("ratingSort", ratingSort);

%>
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
		.pagination { margin-top: 2rem; } /* Add margin above pagination */
		#pagination-container .pagination .page-item .page-link {
			/* Slightly larger click area, maybe different border */
			padding: 0.5rem 0.85rem; /* Adjust padding */
			border-radius: 0.25rem; /* Consistent radius */
			margin: 0 3px; /* Add horizontal space between page numbers */
			border: 1px solid #dee2e6; /* Default border */
			color: #0d6efd; /* Default link color */
			transition: all 0.2s ease-in-out;
		}

		#pagination-container .pagination .page-item.active .page-link {
			/* Style for the active page */
			background-color: #0d6efd;
			border-color: #0d6efd;
			color: #fff;
			box-shadow: 0 2px 5px rgba(13, 110, 253, 0.3); /* Subtle shadow */
		}

		#pagination-container .pagination .page-item.disabled .page-link {
			/* Style for disabled Prev/Next or ellipsis */
			color: #adb5bd; /* Lighter grey */
			background-color: #e9ecef; /* Slight background */
			border-color: #dee2e6;
			cursor: not-allowed;
		}

		#pagination-container .pagination .page-item:not(.active) .page-link:hover {
			/* Hover effect for non-active links */
			background-color: #e7f1ff; /* Light blue hover */
			border-color: #b6d4fe;
			color: #0a58ca;
		}
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
						<div class="text-center col-12">
							<div class="no-products-found">
								<i class="fas fa-search fa-4x text-muted mb-3"></i>
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
			<%-- ****** PAGINATION CONTROLS ****** --%>
			<div id="pagination-container" class="mt-4 d-flex justify-content-center"> <%-- Keep container ID --%>
				<c:if test="${totalPages > 1}">
					<nav aria-label="Product navigation"> <%-- Removed class mt-4 from nav --%>
						<ul class="pagination justify-content-center">

								<%-- Previous Page Link --%>
							<li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
								<c:url var="prevUrl" value="products.jsp">
									<%-- Include ALL potential filter parameters --%>
									<c:if test="${not empty searchKey}"><c:param name="search" value="${searchKey}"/></c:if>
									<c:forEach var="catId" items="${selectedCategories}"><c:param name="category" value="${catId}"/></c:forEach>
									<c:if test="${not empty minPrice}"><c:param name="minPrice" value="${minPrice}"/></c:if>
									<c:if test="${not empty maxPrice}"><c:param name="maxPrice" value="${maxPrice}"/></c:if>
									<c:if test="${not empty ratingSort}"><c:param name="ratingSort" value="${ratingSort}"/></c:if>
									<c:param name="page" value="${currentPage - 1}"/>
								</c:url>
								<a class="page-link" href="${currentPage > 1 ? prevUrl : '#'}" aria-label="Previous">
									<span aria-hidden="true">«</span>
								</a>
							</li>

								<%-- Page Number Links with Ellipsis Logic --%>
							<c:set var="pageWindow" value="2"/>
							<c:forEach var="i" begin="1" end="${totalPages}">
								<%-- Conditions to SHOW link 'i' --%>
								<c:set var="showPageLink" value="false"/>
								<c:if test="${i == 1 || i == totalPages || (i >= (currentPage - pageWindow) && i <= (currentPage + pageWindow))}">
									<c:set var="showPageLink" value="true"/>
								</c:if>
								<%-- Left Ellipsis --%>
								<c:if test="${i == (currentPage - pageWindow) && i > 2}">
									<li class="page-item disabled"><span class="page-link">...</span></li>
								</c:if>
								<%-- Display Link --%>
								<c:if test="${showPageLink}">
									<li class="page-item ${i == currentPage ? 'active' : ''}">
										<c:url var="pageUrl" value="products.jsp">
											<%-- Include ALL potential filter parameters --%>
											<c:if test="${not empty searchKey}"><c:param name="search" value="${searchKey}"/></c:if>
											<c:forEach var="catId" items="${selectedCategories}"><c:param name="category" value="${catId}"/></c:forEach>
											<c:if test="${not empty minPrice}"><c:param name="minPrice" value="${minPrice}"/></c:if>
											<c:if test="${not empty maxPrice}"><c:param name="maxPrice" value="${maxPrice}"/></c:if>
											<c:if test="${not empty ratingSort}"><c:param name="ratingSort" value="${ratingSort}"/></c:if>
											<c:param name="page" value="${i}"/>
										</c:url>
										<a class="page-link" href="${pageUrl}">${i}</a>
									</li>
								</c:if>
								<%-- Right Ellipsis --%>
								<c:if test="${i == (currentPage + pageWindow) && i < (totalPages - 1)}">
									<li class="page-item disabled"><span class="page-link">...</span></li>
								</c:if>
							</c:forEach>

								<%-- Next Page Link --%>
							<li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
								<c:url var="nextUrl" value="products.jsp">
									<%-- Include ALL potential filter parameters --%>
									<c:if test="${not empty searchKey}"><c:param name="search" value="${searchKey}"/></c:if>
									<c:forEach var="catId" items="${selectedCategories}"><c:param name="category" value="${catId}"/></c:forEach>
									<c:if test="${not empty minPrice}"><c:param name="minPrice" value="${minPrice}"/></c:if>
									<c:if test="${not empty maxPrice}"><c:param name="maxPrice" value="${maxPrice}"/></c:if>
									<c:if test="${not empty ratingSort}"><c:param name="ratingSort" value="${ratingSort}"/></c:if>
									<c:param name="page" value="${currentPage + 1}"/>
								</c:url>
								<a class="page-link" href="${currentPage < totalPages ? nextUrl : '#'}" aria-label="Next">
									<span aria-hidden="true">»</span>
								</a>
							</li>
						</ul>
					</nav>
				</c:if>
			</div>
			<%-- ****** END PAGINATION CONTROLS ****** --%>
		</div> <%-- End Main Content Column --%>
	</div> <%-- End Row for Sidebar/Content --%>
</main>

<%@include file="Components/footer.jsp"%>
<script>
	const s3BaseUrl = '<c:out value="${s3BaseUrl}"/>';
	const isUserLoggedIn = ${not empty sessionScope.activeUser};
	// Use try-catch for JSON parsing as attribute might be missing or invalid
	let userWishlistPids = new Set();
	// Pass wishlist PIDs safely (example using iteration, adjust if needed)
	<c:if test="${not empty userWishlistPids}">
	userWishlistPids = new Set([<c:forEach items="${userWishlistPids}" var="pid" varStatus="loop">${pid}${not loop.last ? ',' : ''}</c:forEach>]);
	</c:if>
	// Pass category names map (ensure categoryNames is populated correctly in JSP scriptlet)
	const categoryNamesJs = {
		<c:forEach var="entry" items="${categoryNames}" varStatus="loop">
		"${entry.key}": "${entry.value}"${!loop.last ? ',' : ''}
		</c:forEach>
	};
	const initialCurrentPage = ${currentPage};
	const initialTotalPages = ${totalPages};
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
	console.log("JS Initial State - Categories:", categoryNamesJs);
	console.log("JS Initial State - CurrentPage:", initialCurrentPage, "TotalPages:", initialTotalPages);
</script>
</body>
</html>