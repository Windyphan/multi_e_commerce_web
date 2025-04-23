<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.dao.ProductDao"%>
<%@page import="com.phong.dao.VendorDao"%>
<%@page import="com.phong.entities.Product"%>
<%@page import="com.phong.entities.Vendor"%>
<%@page import="com.phong.dao.CartDao"%>
<%@page import="com.phong.entities.Cart"%>
<%@page import="com.phong.entities.User"%>
<%@page import="java.util.*"%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check & Initial Data Fetching --%>
<%
	User currentUserForCart = (User) session.getAttribute("activeUser");
	if (currentUserForCart == null) {
		// Use JSTL for setting session attributes and redirecting
		pageContext.setAttribute("errorMessage", "You are not logged in! Login first!!", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		response.sendRedirect("login.jsp"); // Standard redirect needed here before response commit
		return; // Stop processing further
	}

	// Fetch Cart and Product Data
	CartDao cartDaoForCart = new CartDao();
	ProductDao productDao = new ProductDao();
	VendorDao vendorDao = new VendorDao();
	List<Cart> cartItems = cartDaoForCart.getCartListByUserId(currentUserForCart.getUserId());

	// Create a list to hold detailed cart item info (Cart + Product)
	// This helps handle cases where a product might have been deleted
	List<CartItemDetail> detailedCartItems = new ArrayList<>();
	float calculatedTotalPrice = 0;
	Map<Integer, String> cartVendorNameMap = new HashMap<>();
	Set<Integer> vendorIdsInCart = new HashSet<>();
	if (cartItems != null) {
		for (Cart cartItem : cartItems) {
			Product product = productDao.getProductsByProductId(cartItem.getProductId());
			if (product != null) { // Only add if product exists
				detailedCartItems.add(new CartItemDetail(cartItem, product));
				calculatedTotalPrice += cartItem.getQuantity() * product.getProductPriceAfterDiscount();
				if (product.getVendorId() > 0) { // Collect valid vendor IDs
					vendorIdsInCart.add(product.getVendorId());
				}
			} else {
				// Optionally log or inform user about items linked to deleted products
				System.err.println("Warning: Cart item ID " + cartItem.getCartId() + " refers to non-existent product ID " + cartItem.getProductId());
				// Consider automatically removing such items from the cart here?
				// cartDao.removeProduct(cartItem.getCartId());
			}
		}
		if (!vendorIdsInCart.isEmpty()) {
			for (int vid : vendorIdsInCart) {
				Vendor vendor = vendorDao.getVendorById(vid);
				if (vendor != null && vendor.isApproved()) { // Only get approved vendors
					cartVendorNameMap.put(vid, vendor.getShopName());
				} else {
					cartVendorNameMap.put(vid, "Phong Shop"); // Fallback name? Or null?
				}
			}
		}
	} else {
		// Handle case where getCartListByUserId itself returned null (DB error)
		detailedCartItems = Collections.emptyList(); // Ensure list is not null
		// Set an error message maybe?
		pageContext.setAttribute("errorMessage", "Error retrieving cart items.", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
	}

	// Make detailed list and total price available for EL
	request.setAttribute("cartContent", detailedCartItems);
	request.setAttribute("cartTotalPrice", calculatedTotalPrice);
	request.setAttribute("cartVendorNames", cartVendorNameMap);

%>
<%-- Helper Inner Class (Place this definition within the <%! ... %> declaration block) --%>
<%!
	// Simple helper class to combine Cart and Product info
	public static class CartItemDetail {
		private Cart cart;
		private Product product;

		public CartItemDetail(Cart cart, Product product) {
			this.cart = cart;
			this.product = product;
		}
		public Cart getCart() { return cart; }
		public Product getProduct() { return product; }
	}
%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Shopping Cart - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f8f9fa;
		}
		.cart-table th {
			font-weight: 600;
			background-color: #e9ecef; /* Light header */
			vertical-align: middle;
		}
		.cart-table td {
			vertical-align: middle;
		}
		.cart-item-img {
			width: 60px;
			height: 60px;
			object-fit: contain;
			margin-right: 10px;
		}
		.cart-item-name {
			font-weight: 500;
			color: #333;
		}
		.quantity-controls {
			display: flex;
			align-items: center;
			justify-content: center;
		}
		.quantity-input { /* Changed from div.qty to an actual input for potential JS updates */
			width: 50px;
			text-align: center;
			border: 1px solid #ced4da;
			border-radius: 0.25rem;
			margin: 0 8px;
			/* Prevent browser default spinners */
			-moz-appearance: textfield;
		}
		.quantity-input::-webkit-outer-spin-button,
		.quantity-input::-webkit-inner-spin-button {
			-webkit-appearance: none;
			margin: 0;
		}

		.quantity-btn {
			border: 1px solid #ced4da;
			background-color: #fff;
			color: #495057;
			width: 32px;
			height: 32px;
			display: inline-flex;
			align-items: center;
			justify-content: center;
			line-height: 1;
			padding: 0;
			border-radius: 50%; /* Circular buttons */
			transition: background-color 0.2s ease;
		}
		.quantity-btn:hover {
			background-color: #e9ecef;
		}
		.quantity-btn i {
			font-size: 0.8rem; /* Adjust icon size */
		}
		.btn-remove {
			font-size: 0.9rem;
			padding: 0.3rem 0.7rem;
		}
		.total-price-row td {
			font-size: 1.2rem;
			font-weight: 700;
			text-align: right;
			padding-top: 1rem;
			padding-bottom: 1rem;
		}
		.cart-actions {
			margin-top: 1.5rem;
		}
		.empty-cart-container {
			padding: 4rem 1rem;
		}
		.empty-cart-container img {
			max-width: 200px;
			opacity: 0.7;
		}
		.empty-cart-container h4 {
			margin-top: 1.5rem;
			color: #6c757d;
		}
		.empty-cart-container p {
			color: #6c757d;
		}
		.product-vendor-info {
			font-size: 0.95rem;
		}
		.product-vendor-info a {
			text-decoration: none;
		}
		.product-vendor-info a:hover {
			text-decoration: underline;
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<div class="container mt-4 mb-5">

	<%-- Display Messages --%>
	<%@include file="Components/alert_message.jsp"%>

	<h2 class="mb-4">Your Shopping Cart</h2>

	<%-- Use c:choose for conditional rendering --%>
	<c:choose>
		<%-- Case 1: Cart is empty --%>
		<c:when test="${empty cartContent}">
			<div class="text-center empty-cart-container">
				<img src="Images/empty-cart.png" alt="Empty Cart" class="img-fluid">
				<h4>Your cart is empty!</h4>
				<p>Looks like you haven't added anything yet.</p>
				<a href="products.jsp" class="btn btn-primary btn-lg mt-3" role="button">
					<i class="fa-solid fa-shopping-bag"></i> Shop Now
				</a>
			</div>
		</c:when>

		<%-- Case 2: Cart has items --%>
		<c:otherwise>
			<div class="card shadow-sm">
				<div class="card-body p-0"> <%-- Remove card body padding for table --%>
					<div class="table-responsive"> <%-- Make table scroll on small screens --%>
						<table class="table cart-table mb-0"> <%-- Remove bottom margin --%>
							<thead>
							<tr class="text-center">
								<th scope="col" class="text-start ps-3" style="width: 45%;">Product</th>
								<th scope="col" style="width: 15%;">Price</th>
								<th scope="col" style="width: 15%;">Quantity</th>
								<th scope="col" style="width: 15%;">Total</th>
								<th scope="col" style="width: 10%;" class="pe-3">Action</th>
							</tr>
							</thead>
							<tbody>
							<c:forEach var="itemDetail" items="${cartContent}">
								<tr class="text-center">
										<%-- Product Column --%>
									<td class="text-start ps-3">
										<div class="d-flex align-items-center">
												<%-- Use forward slash --%>
											<img src="${s3BaseUrl}${itemDetail.product.productImages}" alt="${itemDetail.product.productName}" class="cart-item-img">
											<a href="viewProduct.jsp?pid=${itemDetail.product.productId}" class="cart-item-name ms-2">${itemDetail.product.productName}</a>
														<%-- *** NEW: Display Vendor Name *** --%>
													<small class="text-muted product-vendor">
														Sold by:
														<c:set var="vendorName" value="${cartVendorNames[itemDetail.product.vendorId]}" />
														<a href="vendor_store.jsp?vid=${itemDetail.product.vendorId}" class="link-secondary">
															<c:out value="${not empty vendorName ? vendorName : 'Phong Shop'}"/>
														</a>
													</small>
														<%-- *** End Vendor Name Display *** --%>
										</div>
									</td>
										<%-- Price Column --%>
									<td>
										<fmt:setLocale value="en_GB"/>
										<fmt:formatNumber value="${itemDetail.product.productPriceAfterDiscount}" type="currency" currencySymbol="£"/>
									</td>
										<%-- Quantity Column --%>
									<td>
										<div class="quantity-controls">
												<%-- Decrease Button (conditionally disabled) --%>
											<a href="CartOperationServlet?cid=${itemDetail.cart.cartId}&opt=2"
											   role="button"
											   class="btn quantity-btn ${itemDetail.cart.quantity <= 1 ? 'disabled' : ''}"
											   title="Decrease quantity">
												<i class="fa-solid fa-minus"></i>
											</a>

												<%-- Quantity Display (Readonly Input) --%>
											<input type="number" class="quantity-input form-control form-control-sm" value="${itemDetail.cart.quantity}" readonly aria-label="Quantity">

												<%-- Increase Button (conditionally disabled based on stock) --%>
											<a href="CartOperationServlet?cid=${itemDetail.cart.cartId}&opt=1"
											   role="button"
											   class="btn quantity-btn ${itemDetail.cart.quantity >= itemDetail.product.productQuantity ? 'disabled' : ''}"
											   title="Increase quantity">
												<i class="fa-solid fa-plus"></i>
											</a>
										</div>
											<%-- Optional: Show stock limit if trying to increase beyond stock --%>
										<c:if test="${itemDetail.cart.quantity >= itemDetail.product.productQuantity}">
											<small class="text-danger d-block mt-1">Max stock reached</small>
										</c:if>
									</td>
										<%-- Total Price Column --%>
									<td>
										<fmt:formatNumber value="${itemDetail.cart.quantity * itemDetail.product.productPriceAfterDiscount}" type="currency" currencySymbol="£"/>
									</td>
										<%-- Remove Column --%>
									<td class="pe-3">
										<a href="CartOperationServlet?cid=${itemDetail.cart.cartId}&opt=3"
										   class="btn btn-outline-danger btn-sm btn-remove" role="button" title="Remove item">
											<i class="fa-solid fa-trash-alt"></i>
												<%-- <span class="d-none d-md-inline">Remove</span> --%> <%-- Optional text on larger screens --%>
										</a>
									</td>
								</tr>
							</c:forEach>
								<%-- Total Price Row --%>
							<tr class="total-price-row">
								<td colspan="5" class="pe-3"> <%-- Span 5 columns --%>
									<strong>Total Amount:
										<fmt:formatNumber value="${cartTotalPrice}" type="currency" currencySymbol="£"/>
									</strong>
								</td>
							</tr>
							</tbody>
						</table>
					</div><%-- End table-responsive --%>
				</div> <%-- End card-body --%>
				<div class="card-footer bg-light d-flex justify-content-between align-items-center cart-actions">
					<a href="products.jsp" class="btn btn-secondary" role="button">
						<i class="fa-solid fa-arrow-left"></i> Continue Shopping
					</a>
						<%-- Use a form for checkout to set session attributes cleanly --%>
					<form action="SetCheckoutAttributesServlet" method="POST" style="display: inline;"> <%-- Create a new servlet --%>
						<input type="hidden" name="from" value="cart">
							<%-- Total price could be passed or recalculated in servlet --%>
						<input type="hidden" name="totalPrice" value="${cartTotalPrice}">
						<button type="submit" class="btn btn-primary">
							Proceed to Checkout <i class="fa-solid fa-arrow-right"></i>
						</button>
					</form>
				</div>
			</div><%-- End card --%>
		</c:otherwise>
	</c:choose>
</div> <%-- End container --%>

<%-- Footer --%>
 <%@include file="footer.jsp"%>

<%-- Remove the JavaScript that incorrectly sets session attributes --%>
<%--
<script>
    $(document).ready(function(){
        $('#checkout-btn').click(function(){
        <%-- THIS IS SERVER-SIDE CODE, RUNS ON PAGE LOAD --%>
<%-- session.setAttribute("totalPrice", totalPrice); --%>
<%-- session.setAttribute("from", "cart");
</script>
--%>
</body>
</html>