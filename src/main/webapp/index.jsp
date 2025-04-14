<%-- JSTL Core tag library --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> <%-- For number/currency formatting --%>

<%-- Import necessary classes (still needed for DAO calls within this page) --%>
<%@page import="com.phong.dao.ProductDao"%>
<%@page import="com.phong.entities.Product"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Collections"%> <%-- Import Collections for emptyList --%>

<%-- Set Error Page --%>
<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%--
    Server-side Data Fetching (Ideally done in a Servlet/Controller before forwarding)
    We add null checks and default to empty lists to prevent NullPointerExceptions in JSTL loops.
--%>
<%
	ProductDao productDao = new ProductDao();
	List<Product> productList = productDao.getAllLatestProducts();
	List<Product> topDeals = productDao.getDiscountedProducts();

	// Ensure lists are not null for JSTL loops
	if (productList == null) {
		productList = Collections.emptyList(); // Use an empty list instead of null
	}
	if (topDeals == null) {
		topDeals = Collections.emptyList(); // Use an empty list instead of null
	}

	// Make lists available for Expression Language (EL)
	request.setAttribute("latestProducts", productList);
	request.setAttribute("hotDeals", topDeals);
%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Home - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		/* Navbar styling is now primarily in navbar.jsp's style block or external CSS */

		/* === General Section Styling === */
		.section {
			padding: 40px 0; /* Consistent vertical padding */
		}
		.section-title {
			text-align: center;
			margin-bottom: 30px;
			font-weight: 600;
			color: #333;
		}
		.section-bg-light {
			background-color: #f8f9fa; /* Light background for sections */
		}
		.section-bg-accent {
			background-color: #e3f7fc; /* Light blue accent */
		}

		/* === Category Section === */
		.category-section .card {
			border: 1px solid #e0e0e0;
			transition: box-shadow 0.3s ease-in-out;
			text-align: center;
		}
		.category-section .card:hover {
			box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
		}
		.category-section .card-img-top {
			width: 80px; /* Control image size */
			height: 80px;
			object-fit: contain; /* Scale image nicely */
			margin: 15px auto 10px auto; /* Center image */
		}
		.category-section .card-body {
			padding: 0.5rem 1rem 1rem 1rem;
		}
		.category-section .card-title {
			font-size: 1rem;
			font-weight: 500;
			color: #555;
			margin-bottom: 0;
		}
		.category-section a {
			text-decoration: none;
			color: inherit; /* Inherit color */
		}

		/* === Product Card Styling === */
		.product-card {
			border: 1px solid #e0e0e0;
			transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
			background-color: #fff;
		}
		.product-card:hover {
			transform: translateY(-5px);
			box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
		}
		.product-card a {
			text-decoration: none;
			color: #333;
		}
		.product-card .card-img-container {
			height: 200px; /* Fixed height for image container */
			display: flex;
			align-items: center;
			justify-content: center;
			padding: 10px;
			overflow: hidden;
		}
		.product-card .card-img-top {
			max-height: 100%;
			max-width: 100%;
			object-fit: contain;
		}
		.product-card .card-body {
			padding: 1rem;
			text-align: center;
		}
		.product-card .card-title {
			font-size: 1.1rem;
			font-weight: 600;
			margin-bottom: 0.5rem;
			/* Prevent long titles from breaking layout - ellipsis */
			white-space: nowrap;
			overflow: hidden;
			text-overflow: ellipsis;
		}
		.product-card .price-container {
			margin-top: 0.75rem;
			font-size: 0.9rem; /* Slightly smaller base for prices */
		}
		.product-card .price-discounted {
			font-size: 1.2rem; /* Make discounted price stand out */
			font-weight: 700;
			color: #28a745; /* Green for discounted price */
		}
		.product-card .price-original {
			text-decoration: line-through;
			color: #6c757d; /* Grey out original price */
			margin-left: 0.5rem;
		}
		.product-card .discount-badge {
			color: #dc3545; /* Red for discount */
			font-weight: 600;
			margin-left: 0.5rem;
		}
		.product-card .card-title a:hover {
			color: #0056b3; /* Link hover color */
		}

		/* === Carousel Styling === */
		.carousel-item img {
			max-height: 450px; /* Adjust max height */
			object-fit: cover; /* Cover the area, might crop */
		}
		/* Add background to controls for better visibility if needed */
		.carousel-control-prev, .carousel-control-next {
			width: 5%; /* Adjust width */
		}
		.carousel-control-prev-icon, .carousel-control-next-icon {
			background-color: rgba(0, 0, 0, 0.3); /* Slight background */
			border-radius: 50%;
			padding: 10px;
		}

	</style>
</head>
<body>
<%-- Navbar Inclusion --%>
<%@include file="Components/navbar.jsp"%>

<%-- Display Messages (if any) --%>
<%@include file="Components/alert_message.jsp"%>

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

<%-- Latest Products Section --%>
<c:if test="${not empty latestProducts}">
	<section class="section section-bg-light">
		<div class="container">
			<h2 class="section-title">Latest Products</h2>
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

<%-- Footer - Included last --%>
<%@include file="footer.jsp"%>

</body>
</html>