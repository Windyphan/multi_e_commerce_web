<%-- index.jsp --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.dao.ProductDao"%>
<%@page import="com.phong.dao.VendorDao"%>
<%@page import="com.phong.dao.ReviewDao"%>
<%@page import="com.phong.entities.Product"%>
<%@page import="com.phong.entities.Vendor"%>
<%@page import="com.phong.entities.User"%> <%-- Used if checking user for wishlist --%>
<%@page import="com.phong.entities.Wishlist"%> <%-- Used if checking wishlist --%>
<%@page import="com.phong.dao.WishlistDao"%> <%-- Used if checking wishlist --%>
<%@page import="java.util.*"%>
<%@page import="java.util.stream.Collectors"%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Data Fetching --%>
<%
	// Fetch latestProducts, topDeals (keep existing logic)
	ProductDao productDao = new ProductDao();
	List<Product> productList = productDao.getAllLatestProducts();
	List<Product> topDeals = productDao.getDiscountedProducts();
	if (productList == null) productList = Collections.emptyList();
	if (topDeals == null) topDeals = Collections.emptyList();

	// Fetch average ratings and vendor names for products shown on index
	Map<Integer, Float> averageRatingsMap = new HashMap<>();
	Map<Integer, String> indexVendorNameMap = new HashMap<>();
	Set<Integer> vendorIdsNeeded = new HashSet<>();
	ReviewDao reviewDao = new ReviewDao(); // Fetch ratings
	VendorDao vendorDao = new VendorDao();   // Fetch vendors

	List<Product> allProductsOnIndex = new ArrayList<>(productList); // Combine lists
	allProductsOnIndex.addAll(topDeals); // Add deals (might have duplicates if a product is both latest and deal)

	if (!allProductsOnIndex.isEmpty()) {
		for (Product p : allProductsOnIndex) {
			// Fetch rating (avoid refetch if product is in both lists)
			if (!averageRatingsMap.containsKey(p.getProductId())) {
				averageRatingsMap.put(p.getProductId(), reviewDao.getAverageRatingByProductId(p.getProductId()));
			}
			// Collect vendor IDs
			if (p.getVendorId() > 0) {
				vendorIdsNeeded.add(p.getVendorId());
			}
		}
		// Fetch vendor names
		if (!vendorIdsNeeded.isEmpty()) {
			for (int vid : vendorIdsNeeded) {
				if (!indexVendorNameMap.containsKey(vid)) {
					Vendor vendor = vendorDao.getVendorById(vid);
					if (vendor != null && vendor.isApproved()) {
						indexVendorNameMap.put(vid, vendor.getShopName());
					} else { indexVendorNameMap.put(vid, "Phong Shop"); } // Fallback
				}
			}
		}
	}

	// Fetch user wishlist (if needed for heart icons on index)
	User activeUser = (User) session.getAttribute("activeUser");
	Set<Integer> userWishlistProductIds = new HashSet<>();
	if (activeUser != null) {
		WishlistDao wishlistDao = new WishlistDao();
		List<Wishlist> userWishlist = wishlistDao.getListByUserId(activeUser.getUserId());
		if (userWishlist != null) {
			userWishlistProductIds = userWishlist.stream().map(Wishlist::getProductId).collect(Collectors.toSet());
		}
	}

	// Set attributes for EL
	request.setAttribute("latestProducts", productList);
	request.setAttribute("hotDeals", topDeals);
	request.setAttribute("averageRatings", averageRatingsMap);
	request.setAttribute("indexVendorNames", indexVendorNameMap);
	request.setAttribute("userWishlistPids", userWishlistProductIds);

	// Set active category for sidebar (0 = All)
	request.setAttribute("activeCategoryId", 0);
	// Ensure category list is available for sidebar (assuming navbar sets navbarCategoryList)
	// request.setAttribute("sidebarCategoryList", request.getAttribute("navbarCategoryList"));
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
	<title>Home - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		/* Include Sidebar CSS */
		.sidebar{background-color:#ffffff;padding:1.5rem;border-radius:.375rem;box-shadow:0 1px 3px rgba(0,0,0,.05);height:fit-content}
		.sidebar .sidebar-title{font-weight:600;font-size:1.1rem;margin-bottom:1rem;padding-bottom:.5rem;border-bottom:1px solid #eee}
		.sidebar .list-group-item{border:none;padding:.6rem 0;font-size:.95rem;color:#495057;background-color:transparent;border-left:3px solid transparent;transition:background-color .2s ease,color .2s ease,border-left .2s ease}
		.sidebar .list-group-item:hover{color:#0d6efd;background-color:#f1f3f5}
		.sidebar .list-group-item.active{color:#0d6efd;background-color:#e7f1ff;border-left:3px solid #0d6efd;font-weight:600}
		.sidebar a{text-decoration:none}

		/* Include other styles (product card, carousel, etc.) */
		body { background-color: #f8f9fa; }
		.product-card { position: relative; /* ... other styles ... */ }
		.wishlist-icon-container { position: absolute; top: 10px; right: 10px; z-index: 10; }
		.wishlist-btn { /* ... other styles ... */ }
		.section { padding: 40px 0; }
		.section-title { text-align: center; margin-bottom: 30px; font-weight: 600; color: #333; }
		.section-bg-light { background-color: #f8f9fa; }
		.carousel { margin-bottom: 1rem; /* Less margin if sidebar is present */ }
		.carousel-item img { max-height: 400px; /* Maybe slightly smaller */ object-fit: cover; }
		/* ... other necessary styles ... */
	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%@include file="Components/navbar.jsp"%>

<main class="container-fluid flex-grow-1 my-4">
	<%@include file="Components/alert_message.jsp"%>

	<%-- Carousel Section --%>
	<section class="section p-0"> <%-- Remove padding if carousel touches edges --%>
		<div id="carouselAutoplaying" class="carousel slide carousel-dark" data-bs-ride="carousel">
			<div class="carousel-inner">
				<div class="carousel-item active">
					<img src="Images/scroll_img1.png" class="d-block w-100" alt="Promotion Banner 1">
				</div>
				<div class="carousel-item">
					<img src="Images/scroll_img2.png" class="d-block w-100" alt="Promotion Banner 2">
				</div>
			</div>
			<button class="carousel-control-prev" type="button" data-bs-target="#carouselAutoplaying" data-bs-slide="prev">
				<span class="carousel-control-prev-icon" aria-hidden="true"></span>
				<span class="visually-hidden">Previous</span>
			</button>
			<button class="carousel-control-next" type="button" data-bs-target="#carouselAutoplaying" data-bs-slide="next">
				<span class="carousel-control-next-icon" aria-hidden="true"></span>
				<span class="visually-hidden">Next</span>
			</button>
		</div>
	</section>

	<%-- Category List Section --%>
	<%-- Only render if categoryList is not null and not empty --%>
	<c:if test="${not empty navbarCategoryList}">
		<section class="section category-section section-bg-accent">
			<div class="container">
					<%-- Use responsive columns for categories --%>
				<div class="row row-cols-3 row-cols-md-4 row-cols-lg-6 g-3 justify-content-center">
					<c:forEach var="cat" items="${navbarCategoryList}">
						<div class="col">
							<a href="products.jsp?category=${cat.categoryId}">
								<div class="card category-card h-100">
										<%-- Use forward slashes for web paths --%>
									<img src="${s3BaseUrl}${cat.categoryImage}" class="card-img-top" alt="${cat.categoryName}">
									<div class="card-body">
										<h6 class="card-title">${cat.categoryName}</h6>
									</div>
								</div>
							</a>
						</div>
					</c:forEach>
				</div>
			</div>
		</section>
	</c:if>

	<%-- Hot Deals Section --%>
	<c:if test="${not empty hotDeals}">
		<section class="section"> <%-- Different background or no background --%>
			<div class="container">
				<h2 class="section-title">Hot Deals</h2>
					<%-- Responsive grid --%>
				<div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
					<c:forEach var="product" items="${hotDeals}">
						<div class="col">
							<div class="card h-100 product-card">
								<a href="viewProduct.jsp?pid=${product.productId}">
									<div class="card-img-container">
										<img src="${s3BaseUrl}${product.productImages}" class="card-img-top" alt="${product.productName}">
									</div>
									<div class="card-body">
										<h5 class="card-title" title="${product.productName}">${product.productName}</h5>
										<div class="price-container">
                                             <span class="price-discounted">
                                                 <fmt:setLocale value="en_GB"/>
                                                 <fmt:formatNumber value="${product.productPriceAfterDiscount}" type="currency" currencySymbol="£"/>
                                             </span>
											<span class="price-original">
                                                 <fmt:formatNumber value="${product.productPrice}" type="currency" currencySymbol="£"/>
                                             </span>
											<span class="discount-badge">
                                                 ${product.productDiscount}% off
                                             </span>
										</div>
									</div>
								</a>
							</div>
						</div>
					</c:forEach>
				</div>
			</div>
		</section>
	</c:if>

	<div class="row g-4"> <%-- Row for sidebar and main content --%>
		<%-- === Sidebar Column === --%>
		<div class="col-lg-3 d-none d-lg-block"> <%-- Hide sidebar on smaller screens for index --%>
			<%@include file="Components/sidebar.jsp"%>
		</div>

		<%-- === Main Content Column === --%>
		<div class="col-lg-9"> <%-- Content takes remaining space --%>

			<div id="product-grid-container">
				<%-- Latest Products Section --%>
				<c:if test="${not empty latestProducts}">
					<section class="section section-bg-light">
						<div class="container">
								<%-- Responsive grid: 1 col on xs, 2 on sm, 3 on md, 4 on lg --%>
							<div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
									<%-- Loop through the latestProducts list --%>
								<c:forEach var="product" items="${latestProducts}">
									<div class="col">
										<div class="card h-100 product-card">
											<a href="viewProduct.jsp?pid=${product.productId}">
												<div class="card-img-container">
														<%-- Use forward slashes for web paths --%>
													<img src="${s3BaseUrl}${product.productImages}" class="card-img-top" alt="${product.productName}">
												</div>
												<div class="card-body">
													<h5 class="card-title" title="${product.productName}">${product.productName}</h5>
													<div class="product-vendor mb-2">
														<small class="text-muted">
															Sold by:
															<c:set var="vendorName" value="${indexVendorNames[product.vendorId]}" />
															<c:if test="${not empty vendorName}"> <%-- Only show if vendor name was found & vendor is approved --%>
																<a href="vendor_store.jsp?vid=${product.vendorId}" class="link-secondary">
																	<c:out value="${vendorName}"/>
																</a>
															</c:if>
																<%-- Optional: Show platform name if vendorName is null/empty --%>
															<c:if test="${empty vendorName}">
																<span class="fst-italic">Phong Shop</span>  <%-- Or just show nothing --%>
															</c:if>
														</small>
													</div>
														<%-- *** End Vendor Name Display *** --%>
													<div class="price-container">
                                             <span class="price-discounted">
                                                 <fmt:setLocale value="en_GB"/> <%-- Set locale for currency --%>
                                                 <fmt:formatNumber value="${product.productPriceAfterDiscount}" type="currency" currencySymbol="£"/>
                                             </span>
															<%-- Show original price only if there's a discount --%>
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
										</div>
									</div>
								</c:forEach>
							</div>
						</div>
					</section>
				</c:if>
			</div>

			<%-- Confirmation message script (logic remains the same, ensure 'user' is available) --%>
			<c:set var="orderStatus" value="${sessionScope.order}" />
			<c:if test="${not empty orderStatus and orderStatus eq 'success'}">
				<script type="text/javascript">
					// Ensure Swal is loaded in common_css_js.jsp
					if (typeof Swal !== 'undefined') {
						Swal.fire({
							icon : 'success',
							title: 'Order Placed, Thank you!',
							text: 'Confirmation will be sent to ${sessionScope.activeUser.userEmail}', // Access user from session scope
							width: 600,
							padding: '3em',
							showConfirmButton : false,
							timer : 3500,
							backdrop: `rgba(0,0,123,0.4)`
						});
					} else {
						console.error("SweetAlert (Swal) is not loaded!");
					}
				</script>
				<% session.removeAttribute("order"); %> <%-- Still need scriptlet to remove attribute --%>
			</c:if>

		</div> <%-- End Main Content Column --%>
	</div> <%-- End Row --%>
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