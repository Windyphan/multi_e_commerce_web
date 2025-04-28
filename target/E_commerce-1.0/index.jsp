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
		/* === Main Content Container === */
		.main-content-container {
			max-width: 1200px; /* Adjust max width as needed */
			margin-left: auto;
			margin-right: auto;
			padding-left: 15px; /* Add padding for smaller screens */
			padding-right: 15px;
		}

		/* === Promo Section General Styling === */
		.promo-section {
			background-color: #ffffff; /* White background for sections */
			border-radius: 0.75rem;   /* Rounded corners */
			padding: 2.5rem 2rem;     /* Generous padding */
			margin-bottom: 2rem;      /* Space between sections */
			overflow: hidden;         /* Prevent content bleed */
			box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08); /* Soft shadow */
		}

		.promo-section h2, .promo-section h3 {
			font-weight: 700;
			color: #333;
			margin-bottom: 0.75rem;
		}
		.promo-section p {
			color: #555;
			font-size: 1.05rem;
			margin-bottom: 1.5rem;
			line-height: 1.6;
		}
		.promo-section .btn {
			padding: 0.75rem 1.75rem;
			font-weight: 600;
			border-radius: 50px; /* Pill-shaped buttons */
			transition: all 0.3s ease;
		}
		.promo-section .btn:hover {
			transform: translateY(-2px);
			box-shadow: 0 4px 8px rgba(0,0,0,0.15);
		}
		.promo-section .sub-text {
			font-size: 0.85rem;
			color: #777;
			margin-top: 1rem;
		}

		/* === Specific Section Styles === */

		/* Section 1: Tuning & Styling */
		.promo-section.tuning-styling {
			background-color: #00a1b1; /* Teal background */
			color: #ffffff; /* White text */
			position: relative; /* For potential absolute positioning of decorative elements */
		}
		.promo-section.tuning-styling h2,
		.promo-section.tuning-styling p,
		.promo-section.tuning-styling .sub-text {
			color: #ffffff;
		}
		.promo-section.tuning-styling .btn {
			background-color: #222; /* Dark button */
			border-color: #222;
			color: #fff;
		}
		.promo-section.tuning-styling .btn:hover {
			background-color: #444;
			border-color: #444;
		}
		/* Placeholder for image area if needed */
		.tuning-img-placeholder {
			background-color: rgba(255, 255, 255, 0.1); /* Subtle indication */
			min-height: 200px;
			border-radius: 0.5rem;
			display: flex;
			align-items: center;
			justify-content: center;
			font-style: italic;
			color: rgba(255, 255, 255, 0.5);
		}


		/* Section 2: Sell for Free */
		.promo-section.sell-free {
			background-color: #f8f9fa; /* Light grey background */
			box-shadow: none; /* Remove shadow if preferred */
			border: 1px solid #e9ecef;
		}
		.promo-section.sell-free .btn {
			background-color: #343a40; /* Dark grey button */
			border-color: #343a40;
			color: #fff;
		}
		.promo-section.sell-free .btn:hover {
			background-color: #495057;
			border-color: #495057;
		}
		/* Placeholder for image area */
		.sell-img-placeholder {
			background-color: #e9ecef;
			min-height: 250px; /* Adjust height */
			border-radius: 0.5rem;
			display: flex;
			align-items: center;
			justify-content: center;
			font-style: italic;
			color: #6c757d;
		}
		.sell-img-placeholder img {
			display: block;         /* Prevents extra space below image */
			width: 100%;            /* Make image fill container width */
			height: 100%;           /* Make image fill container height */
			object-fit: cover;      /* Crucial: Scales image to cover the container, maintaining aspect ratio, cropping if needed */
		}


		/* Section 3: Great Deal */
		.promo-section.great-deal {
			/* Background is default white */
			border: 1px solid #e0e0e0; /* Light border */
			box-shadow: none;
		}
		.promo-section.great-deal .featured-text {
			font-size: 0.9rem;
			color: #6c757d;
			margin-bottom: 0.25rem;
			text-transform: uppercase;
			letter-spacing: 0.5px;
		}
		.promo-section.great-deal .brand-placeholder {
			font-weight: bold;
			font-size: 1.8rem;
			color: #8a2be2; /* purple */
			margin-bottom: 1rem;
		}
		.promo-section.great-deal h3 { /* Using h3 here */
			font-weight: 600;
			font-size: 1.8rem;
		}
		.promo-section.great-deal .btn {
			background-color: transparent;
			border: 2px solid #343a40; /* Outline button */
			color: #343a40;
		}
		.promo-section.great-deal .btn:hover {
			background-color: #343a40;
			color: #fff;
			box-shadow: none; /* Remove hover shadow for outline buttons if desired */
			transform: none; /* Remove lift effect for outline buttons */
		}
		/* === Carousel Specific Styling === */

		/* General Carousel Adjustments */
		.promo-carousel .carousel-inner { padding: 0 40px; /* Make space for controls */ }
		.promo-carousel .carousel-control-prev,
		.promo-carousel .carousel-control-next { width: 5%; } /* Adjust control width */
		.promo-carousel .carousel-control-prev-icon,
		.promo-carousel .carousel-control-next-icon { background-color: rgba(0, 0, 0, 0.3); border-radius: 50%; padding: 15px; background-size: 60%; }

		/* Hot Deals Carousel */
		#hotDealsCarousel .carousel-item { padding: 1rem 0.5rem; /* Padding inside the item */ text-align: center; }
		#hotDealsCarousel .product-card-carousel { /* Style for cards inside this carousel */
			max-width: 300px; /* Limit card width */
			margin: auto; /* Center the card */
			box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
			border: none;
			background-color: #fff; /* Ensure white background */
			/* Copy relevant product card styles here or create specific ones */
			border-radius: 0.375rem; overflow: hidden;
		}
		#hotDealsCarousel .product-card-carousel a { text-decoration: none; color: #212529; }
		#hotDealsCarousel .product-card-carousel .card-img-container { height: 180px; display: flex; align-items: center; justify-content: center; padding: 10px; overflow: hidden; background-color: #f8f9fa; }
		#hotDealsCarousel .product-card-carousel .card-img-top { max-height: 100%; max-width: 100%; object-fit: contain; }
		#hotDealsCarousel .product-card-carousel .card-body { padding: 0.8rem; text-align: center; }
		#hotDealsCarousel .product-card-carousel .card-title { font-size: 0.95rem; font-weight: 600; margin-bottom: 0.4rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #343a40; }
		#hotDealsCarousel .product-card-carousel .product-vendor { font-size: 0.8rem; margin-bottom: 0.3rem; }
		#hotDealsCarousel .product-card-carousel .star-rating { margin-bottom: 0.4rem; font-size: 0.9rem; } /* Adjust star size */
		#hotDealsCarousel .product-card-carousel .price-container { font-size: 0.85rem; line-height: 1.4; }
		#hotDealsCarousel .product-card-carousel .price-discounted { font-size: 1rem; font-weight: 700; color: #dc3545; }
		#hotDealsCarousel .product-card-carousel .price-original { text-decoration: line-through; color: #6c757d; margin-left: 0.4rem; font-size: 0.85em; }
		#hotDealsCarousel .product-card-carousel .discount-badge { color: #198754; font-weight: 600; margin-left: 0.4rem; font-size: 0.8em; }
		#hotDealsCarousel .product-card-carousel .wishlist-icon-container { position: absolute; top: 8px; right: 8px; z-index: 10; }
		#hotDealsCarousel .product-card-carousel .wishlist-btn { background: rgba(255,255,255,0.7); border-radius: 50%; padding: 5px 7px; line-height: 1; color: #dc3545; font-size: 0.9rem;}
		#hotDealsCarousel .product-card-carousel .wishlist-btn:hover { background: rgba(255,255,255,0.9); }
		#hotDealsCarousel .product-card-carousel .wishlist-btn .not-in-wishlist { color: #6c757d; }


		/* Category Carousel */
		.category-carousel-section { padding: 40px 0; background-color: #fff; margin-bottom: 2rem; border-radius: 0.75rem; box-shadow: 0 4px 15px rgba(0,0,0,0.07); }
		.category-carousel-section .section-title { text-align: center; margin-bottom: 30px; font-weight: 600; color: #333; font-size: 1.8rem; }
		#categoryCarousel .carousel-item { /* Padding adjusted by inner row */ }

		#categoryCarousel .category-card-large {
			border: 1px solid #e9ecef; /* Lighter border */
			transition: box-shadow 0.2s ease-in-out, transform 0.2s ease-in-out;
			text-align: center;
			background-color: #fff;
			border-radius: 0.5rem; /* More rounded */
			padding: 1.5rem 1rem;  /* INCREASED Padding */
			display: flex;         /* Use flex for vertical centering */
			flex-direction: column;
			justify-content: center;
			align-items: center;
			min-height: 170px; /* INCREASED Min Height (adjust as needed) */
		}
		#categoryCarousel .category-card-large:hover {
			box-shadow: 0 6px 18px rgba(0, 0, 0, 0.12);
			transform: translateY(-4px); /* Add slight lift on hover */
		}
		#categoryCarousel .category-card-large img {
			width: 85px;   /* INCREASED Image Width */
			height: 85px;  /* INCREASED Image Height */
			object-fit: contain;
			margin: 0 auto 1rem auto; /* INCREASED Margin below image */
		}
		#categoryCarousel .category-card-large h6 {
			font-size: 1rem; /* INCREASED Font Size */
			font-weight: 500;
			color: #444;    /* Slightly darker text */
			margin-bottom: 0;
			line-height: 1.3;
		}
		#categoryCarousel .category-card-large a {
			text-decoration: none;
			color: inherit;
			/* Make the link cover the whole card for easier clicking */
			display: flex;
			flex-direction: column;
			justify-content: center;
			align-items: center;
			width: 100%;
			height: 100%;
		}
		/* Dark controls for light background */
		#categoryCarousel.carousel-dark .carousel-control-prev-icon,
		#categoryCarousel.carousel-dark .carousel-control-next-icon { filter: invert(1) grayscale(100); } /* Make default Bootstrap dark icons visible */

		/* Responsive Adjustments */
		@media (max-width: 991.98px) { /* Below LG breakpoint */
			.promo-section {
				padding: 2rem 1.5rem;
			}
			.img-placeholder { /* Target all placeholders */
				margin-top: 1.5rem;
				min-height: 180px; /* Reduce height on smaller screens */
			}
			.promo-section.tuning-styling .product-card-carousel { max-width: 250px; } /* Smaller cards */
			#hotDealsCarousel .card-img-container { height: 150px; }
		}
		@media (max-width: 767.98px) { /* Below MD breakpoint */
			.promo-section h2, .promo-section h3 {
				font-size: 1.8rem; /* Slightly smaller headings */
			}
			.promo-section p {
				font-size: 1rem;
			}
			.promo-section .btn {
				width: 100%; /* Make buttons full width */
				padding: 0.7rem 1rem;
			}
			/* Center text in sections */
			.promo-section .row > div[class*="col-"] { /* Target direct children cols */
				text-align: center;
			}
			#hotDealsCarousel .carousel-inner { padding: 0 10px; } /* Less padding */
			#hotDealsCarousel .product-card-carousel { max-width: 220px; }
			#hotDealsCarousel .card-img-container { height: 130px; }
			#categoryCarousel .row { --bs-gutter-x: 0.5rem; /* Reduce gap between category cards */ }
			#categoryCarousel .category-card-small img { width: 45px; height: 45px; }
			#categoryCarousel .category-card-small h6 { font-size: 0.75rem; }
			.img-placeholder {
				min-height: 150px;
			}
		}
		/* Placeholder for image area */
		.deal-img-placeholder {
			background-color: #ffe0e6; /* Light pinkish */
			min-height: 250px; /* Adjust height */
			border-radius: 0.5rem;
			display: flex;
			align-items: center;
			justify-content: center;
			font-style: italic;
			color: #ad717c;
		}
		.deal-img-placeholder img {
			display: block;         /* Prevents extra space below image */
			width: 100%;            /* Make image fill container width */
			height: 100%;           /* Make image fill container height */
			object-fit: cover;      /* Crucial: Scales image to cover the container, maintaining aspect ratio, cropping if needed */
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%@include file="Components/navbar.jsp"%>

<main class="main-content-container flex-grow-1 my-4">
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
		<%-- === Section: Category Carousel === --%>
	<c:if test="${not empty navbarCategoryList}">
		<section class="category-carousel-section">
			<h2 class="section-title">Shop by Category</h2>
			<div id="categoryCarousel" class="carousel slide promo-carousel carousel-dark" data-bs-ride="carousel" data-bs-interval="5000"> <%-- Added carousel-dark --%>
					<%-- Optional Indicators --%>
					<%-- <div class="carousel-indicators"> ... </div> --%>

				<div class="carousel-inner">
					<c:set var="itemsPerSlide" value="4"/> <%-- Adjust items per slide 4 --%>
					<c:forEach var="cat" items="${navbarCategoryList}" varStatus="loop">
						<%-- Start a new carousel item every 'itemsPerSlide' --%>
						<c:if test="${loop.index % itemsPerSlide == 0}">
							<div class="carousel-item ${loop.index == 0 ? 'active' : ''}">
							<div class="row row-cols-${itemsPerSlide > 3 ? itemsPerSlide : 3} row row-cols-${itemsPerSlide} g-4 justify-content-center px-md-4"> <%-- Adjust row-cols based on itemsPerSlide, add padding --%>
						</c:if>

						<%-- The Category Card --%>
						<div class="col">
							<div class="category-card-large h-100">
								<a href="products.jsp?category=${cat.categoryId}">
									<img src="${s3BaseUrl}${cat.categoryImage}" alt="${cat.categoryName}">
									<h6><c:out value="${cat.categoryName}"/></h6>
								</a>
							</div>
						</div>

						<%-- Close carousel item if it's the last item OR end of a slide group --%>
						<c:if test="${loop.last or (loop.index + 1) % itemsPerSlide == 0}">
							</div> <%-- // close row --%>
							</div> <%-- // close carousel-item --%>
						</c:if>
					</c:forEach>
				</div>

					<%-- Controls --%>
				<button class="carousel-control-prev" type="button" data-bs-target="#categoryCarousel" data-bs-slide="prev">
					<span class="carousel-control-prev-icon" aria-hidden="true"></span>
					<span class="visually-hidden">Previous</span>
				</button>
				<button class="carousel-control-next" type="button" data-bs-target="#categoryCarousel" data-bs-slide="next">
					<span class="carousel-control-next-icon" aria-hidden="true"></span>
					<span class="visually-hidden">Next</span>
				</button>
			</div>
		</section>
	</c:if> <%-- End Category Carousel Section --%>


	<%-- === Section 1: Tuning & Styling (with Hot Deals Carousel) === --%>
	<section class="promo-section tuning-styling">
		<div class="row align-items-center">
			<div class="col-lg-6 col-md-7">
				<h2 class="display-5">Save up to 30% on hot deal</h2>
				<p>Cruise into deals and upgrade your lifestyle for less.</p>
			</div>
			<div class="col-lg-6 col-md-5"> <%-- Always show this column now --%>
				<%-- Hot Deals Carousel --%>
				<c:if test="${not empty hotDeals}">
					<div id="hotDealsCarousel" class="carousel slide promo-carousel" data-bs-ride="carousel" data-bs-interval="3500"> <%-- Adjust interval --%>
						<div class="carousel-inner">
							<c:forEach var="product" items="${hotDeals}" varStatus="loop">
								<div class="carousel-item ${loop.first ? 'active' : ''}">
										<%-- Use a specific class for cards in this carousel --%>
									<div class="card product-card-carousel position-relative"> <%-- Added position-relative for wishlist icon --%>
											<%-- Wishlist Icon (Optional) --%>
										<div class="wishlist-icon-container">
											<c:choose>
												<c:when test="${empty sessionScope.activeUser}"><a href="login.jsp" class="btn wishlist-btn" title="Login to add to wishlist"><i class="fa-regular fa-heart not-in-wishlist"></i></a></c:when>
												<c:otherwise>
													<c:set var="isInWishlist" value="${userWishlistPids.contains(product.productId)}"/>
													<a href="WishlistServlet?pid=${product.productId}&op=${isInWishlist ? 'remove' : 'add'}" class="btn wishlist-btn" title="${isInWishlist ? 'Remove from' : 'Add to'} Wishlist"><i class="fa-${isInWishlist ? 'solid' : 'regular'} fa-heart ${isInWishlist ? 'in-wishlist' : 'not-in-wishlist'}"></i></a>
												</c:otherwise>
											</c:choose>
										</div>
											<%-- Product Link --%>
										<a href="viewProduct.jsp?pid=${product.productId}">
											<div class="card-img-container">
												<img src="${s3BaseUrl}${product.productImages}" class="card-img-top" alt="${product.productName}">
											</div>
											<div class="card-body">
												<h5 class="card-title" title="${product.productName}"><c:out value="${product.productName}"/></h5>
													<%-- Vendor (Optional) --%>
												<div class="product-vendor mb-1">
													<small class="text-muted">By:
														<c:set var="vendorName" value="${indexVendorNames[product.vendorId]}" />
														<c:out value="${not empty vendorName ? vendorName : 'Phong Shop'}"/>
													</small>
												</div>
													<%-- Rating (Optional) --%>
												<c:set var="avgRating" value="${averageRatings[product.productId]}"/>
												<c:choose>
													<c:when test="${not empty avgRating and avgRating > 0}">
														<div class="star-rating mb-1" title="${avgRating} stars">
															<small><c:forEach var="i" begin="1" end="5"><i class="fa-${avgRating >= i ? 'solid' : (avgRating >= i-0.5 ? 'solid fa-star-half-stroke' : 'regular')} fa-star text-warning"></i></c:forEach></small>
														</div>
													</c:when>
													<c:otherwise><div class="star-rating mb-1 text-muted"><small>No reviews</small></div></c:otherwise>
												</c:choose>
													<%-- Price --%>
												<div class="price-container">
													<span class="price-discounted"><fmt:setLocale value="en_GB"/><fmt:formatNumber value="${product.productPriceAfterDiscount}" type="currency" currencySymbol="£"/></span>
													<c:if test="${product.productDiscount > 0}">
														<span class="price-original"><fmt:formatNumber value="${product.productPrice}" type="currency" currencySymbol="£"/></span>
														<span class="discount-badge">${product.productDiscount}% off</span>
													</c:if>
												</div>
											</div>
										</a>
									</div> <%-- End product-card-carousel --%>
								</div> <%-- End carousel-item --%>
							</c:forEach>
						</div>
							<%-- Controls (Optional but recommended for usability) --%>
						<button class="carousel-control-prev" type="button" data-bs-target="#hotDealsCarousel" data-bs-slide="prev">
							<span class="carousel-control-prev-icon" aria-hidden="true"></span><span class="visually-hidden">Previous</span>
						</button>
						<button class="carousel-control-next" type="button" data-bs-target="#hotDealsCarousel" data-bs-slide="next">
							<span class="carousel-control-next-icon" aria-hidden="true"></span><span class="visually-hidden">Next</span>
						</button>
					</div>
				</c:if>
				<c:if test="${empty hotDeals}">
					<p class="text-white-50 fst-italic mt-3 text-center">No hot deals available right now.</p> <%-- Fallback message --%>
				</c:if>
			</div>
		</div>
	</section> <%-- End Tuning & Styling Section --%>

		<%-- === Section 2: Sell for Free === --%>
		<section class="promo-section sell-free">
			<div class="row align-items-center">
				<div class="col-md-6">
					<h2>Sell for free in your community</h2>
					<p>Clear out and cash in! List items for collection in your area.</p>
					<a href="vendor_login.jsp" class="btn btn-dark">Start listing</a> <%-- Link to listing page --%>
					<p class="sub-text">Excludes Vehicles and business sellers.</p>
				</div>
				<div class="col-md-6 d-none d-md-block">
					<div class="sell-img-placeholder"><img src="Images/background-image.png" alt="People using Phong Shop to sell items locally"></div>
				</div>
			</div>
		</section>

		<%-- === Section 3: Great Deal === --%>
		<section class="promo-section great-deal">
			<div class="row align-items-center">
				<div class="col-md-6">
					<p class="featured-text">Featured</p>
					<%-- Placeholder for Brand Logo/Name --%>
					<div class="brand-placeholder">Phong Shop</div> <%-- Or use <img> if you have a logo --%>
					<h3>Looking for a Great Deal?</h3>
					<p>We've got everything you need.</p>
					<a href="products.jsp" class="btn btn-outline-dark">Shop Now</a> <%-- Link to products page --%>
				</div>
				<div class="col-md-6 d-none d-md-block">
					<%-- Image Placeholder --%>
					<div class="deal-img-placeholder">
						<img src="Images/background-image-2.png" alt="People using Phong Shop to buy items">
					</div>
				</div>
			</div>
		</section>
</main>

<%@include file="Components/footer.jsp"%>
</body>
</html>