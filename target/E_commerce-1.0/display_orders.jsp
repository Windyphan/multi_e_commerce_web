<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.dao.AdminDao"%> <%-- Keep if navbar uses it directly --%>
<%@page import="com.phong.dao.UserDao"%>
<%@page import="com.phong.entities.Admin"%> <%-- Keep if navbar uses it directly --%>
<%@page import="com.phong.entities.User"%> <%-- Keep if navbar uses it directly --%>
<%@page import="com.phong.entities.Message"%>
<%@page import="com.phong.entities.OrderedProduct"%>
<%@page import="com.phong.entities.Order"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%> <%-- Import Map --%>
<%@page import="java.util.HashMap"%> <%-- Import HashMap --%>
<%@page import="com.phong.dao.OrderedProductDao"%>
<%@page import="com.phong.dao.OrderDao"%>
<%@page import="java.util.Collections"%> <%-- Import Collections --%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check & Data Fetching --%>
<%
	Admin activeAdminForOrderDisplay = (Admin) session.getAttribute("activeAdmin");
	if (activeAdminForOrderDisplay == null) {
		pageContext.setAttribute("errorMessage", "You are not logged in! Login first!!", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		response.sendRedirect("adminlogin.jsp");
		return;
	}

	// Fetch Orders
	OrderDao orderDao = new OrderDao();
	List<Order> orderList = orderDao.getAllOrder(); // Fetches all orders

	// Fetch associated user and product details efficiently
	// Create Maps to store details keyed by ID to avoid repeated DB calls in loops
	Map<Integer, User> userMap = new HashMap<>();
	Map<Integer, List<OrderedProduct>> orderedProductMap = new HashMap<>();
	UserDao userDao = new UserDao();
	OrderedProductDao ordProdDao = new OrderedProductDao();

	if (orderList != null) {
		for (Order order : orderList) {
			// Fetch User if not already fetched
			if (!userMap.containsKey(order.getUserId())) {
				User orderUser = userDao.getUserById(order.getUserId()); // Assuming UserDao has getUserById
				if (orderUser != null) {
					userMap.put(order.getUserId(), orderUser);
				} else {
					// Handle case where user might have been deleted
					User deletedUser = new User();
					deletedUser.setUserName("User Deleted");
					deletedUser.setUserPhone("");
					deletedUser.setUserAddress("N/A");
					deletedUser.setUserCity("");
					deletedUser.setUserCounty("");
					deletedUser.setUserPostcode("");
					userMap.put(order.getUserId(), deletedUser);
				}
			}
			// Fetch Ordered Products for this order
			List<OrderedProduct> productsForOrder = ordProdDao.getAllOrderedProduct(order.getId());
			orderedProductMap.put(order.getId(), productsForOrder != null ? productsForOrder : Collections.emptyList());
		}
	} else {
		orderList = Collections.emptyList(); // Ensure list is not null for JSTL
		pageContext.setAttribute("errorMessage", "Could not retrieve orders.", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
	}

	// Make data available for EL
	request.setAttribute("allOrders", orderList);
	request.setAttribute("usersData", userMap);
	request.setAttribute("orderedProductsData", orderedProductMap);
%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Manage Orders - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f8f9fa;
		}
		.order-card {
			border: 1px solid #dee2e6;
			border-radius: 0.375rem;
			margin-bottom: 1.5rem;
			background-color: #fff;
			box-shadow: 0 1px 3px rgba(0,0,0,0.05);
		}
		.order-header {
			background-color: #f8f9fa;
			padding: 0.75rem 1.25rem;
			border-bottom: 1px solid #dee2e6;
			display: flex;
			justify-content: space-between;
			align-items: center;
			font-size: 0.9rem;
		}
		.order-header .order-id {
			font-weight: 600;
			color: #0d6efd;
		}
		.order-header .order-date {
			color: #6c757d;
		}
		.order-body {
			padding: 1.25rem;
		}
		.order-section-title {
			font-weight: 600;
			margin-bottom: 0.75rem;
			color: #495057;
			font-size: 1rem;
			border-bottom: 1px solid #eee;
			padding-bottom: 0.5rem;
		}
		.address-details p, .user-details p {
			margin-bottom: 0.25rem;
			font-size: 0.9rem;
			line-height: 1.5;
		}
		.address-details strong, .user-details strong {
			color: #212529;
		}
		.product-list-table {
			margin-top: 1rem;
			font-size: 0.9rem;
		}
		.product-list-table th {
			font-weight: 500;
			color: #495057;
			background-color: #f8f9fa;
		}
		.product-list-table td {
			vertical-align: middle;
		}
		.product-img-sm {
			width: 45px;
			height: 45px;
			object-fit: contain;
			margin-right: 10px;
		}
		.status-badge {
			font-size: 0.85em;
			font-weight: 600;
		}
		.status-update-form select {
			max-width: 200px; /* Limit select width */
			display: inline-block; /* Allow button next to it */
			margin-right: 10px;
			font-size: 0.9rem;
		}
		.status-update-form button {
			font-size: 0.9rem;
		}
		.empty-orders img {
			max-width: 150px;
			opacity: 0.7;
		}
		.empty-orders h4 {
			margin-top: 1rem;
			color: #6c757d;
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

	<h2 class="mb-4">Manage Customer Orders</h2>

	<%-- Display Messages --%>
	<%@include file="Components/alert_message.jsp"%>

	<%-- Check if there are any orders --%>
	<c:choose>
		<c:when test="${empty allOrders}">
			<div class="text-center p-5 empty-orders">
				<img src="Images/empty-cart.png" alt="No Orders"> <%-- Consider a different icon --%>
				<h4>No orders found.</h4>
			</div>
		</c:when>
		<c:otherwise>
			<%-- Loop through each Order --%>
			<c:forEach var="order" items="${allOrders}">
				<div class="card order-card">
					<div class="order-header">
						<div>
							Order ID: <span class="order-id">#<c:out value="${order.orderId}"/></span>
						</div>
						<div class="order-date">
							Placed on:
							<fmt:formatDate value="${order.date}" pattern="dd MMM yyyy, hh:mm a"/>
						</div>
					</div>
					<div class="order-body">
						<div class="row">
								<%-- Customer & Address Section --%>
							<div class="col-md-4 mb-3 mb-md-0">
								<h6 class="order-section-title">Customer & Delivery</h6>
									<%-- Get User details from the prepared Map --%>
								<c:set var="customer" value="${usersData[order.userId]}"/>
								<div class="user-details mb-2">
									<p><strong>Name:</strong> <c:out value="${customer.userName}"/></p>
									<p><strong>Phone:</strong> <c:out value="${customer.userPhone}"/></p>
									<p><strong>Email:</strong> <c:out value="${customer.userEmail}"/></p> <%-- Added email --%>
								</div>
								<div class="address-details">
									<p>
										<c:out value="${customer.userAddress}"/><br>
										<c:out value="${customer.userCity}"/><br>
										<c:out value="${customer.userCounty}"/> - <c:out value="${customer.userPostcode}"/>
									</p>
								</div>
							</div>

								<%-- Order Summary & Status Section --%>
							<div class="col-md-8">
								<h6 class="order-section-title">Order Summary & Status</h6>
								<p><strong>Payment Type:</strong> <span class="badge bg-secondary"><c:out value="${order.paymentType}"/></span></p>
								<p><strong>Current Status:</strong>
									<span class="badge status-badge
                                            <c:choose>
                                                <c:when test="${order.status == 'Delivered'}">bg-success</c:when>
                                                <c:when test="${order.status == 'Shipped' || order.status == 'Out For Delivery'}">bg-info text-dark</c:when>
                                                <c:when test="${order.status == 'Order Confirmed'}">bg-primary</c:when>
                                                <c:otherwise>bg-warning text-dark</c:otherwise> <%-- Default for 'Order Placed' etc. --%>
                                            </c:choose>
                                         ">
                                             <c:out value="${order.status}"/>
                                         </span>
								</p>

									<%-- Product List for this order --%>
								<h6 class="order-section-title mt-3">Items Ordered</h6>
								<c:set var="productsInOrder" value="${orderedProductsData[order.id]}"/>
								<c:choose>
									<c:when test="${empty productsInOrder}">
										<p class="text-muted">No product details found for this order.</p>
									</c:when>
									<c:otherwise>
										<table class="table table-sm product-list-table">
											<thead>
											<tr>
												<th style="width: 10%;"></th> <%-- Image col --%>
												<th>Product</th>
												<th class="text-center">Qty</th>
												<th class="text-end">Price</th>
												<th class="text-end">Total</th>
											</tr>
											</thead>
											<tbody>
											<c:forEach var="orderedProd" items="${productsInOrder}">
												<tr>
													<td>
														<img src="${s3BaseUrl}${orderedProd.image}" alt="" class="product-img-sm">
													</td>
													<td><c:out value="${orderedProd.name}"/></td>
													<td class="text-center"><c:out value="${orderedProd.quantity}"/></td>
													<td class="text-end">
														<fmt:formatNumber value="${orderedProd.price}" type="currency" currencySymbol="£" />
													</td>
													<td class="text-end">
														<fmt:formatNumber value="${orderedProd.price * orderedProd.quantity}" type="currency" currencySymbol="£" />
													</td>
												</tr>
											</c:forEach>
											</tbody>
										</table>
									</c:otherwise>
								</c:choose>

									<%-- Status Update Form --%>
								<div class="mt-3 status-update-form">
									<form action="UpdateOrderServlet" method="post" class="d-flex align-items-center">
										<input type="hidden" name="oid" value="${order.id}">
										<label for="statusSelect-${order.id}" class="form-label me-2 visually-hidden">Update Status:</label>
										<select id="statusSelect-${order.id}" name="status" class="form-select form-select-sm" ${order.status == 'Delivered' ? 'disabled' : ''}>
											<option value="" selected disabled>-- Change Status --</option>
											<option value="Order Confirmed" ${order.status == 'Order Confirmed' ? 'selected' : ''}>Order Confirmed</option>
											<option value="Shipped" ${order.status == 'Shipped' ? 'selected' : ''}>Shipped</option>
											<option value="Out For Delivery" ${order.status == 'Out For Delivery' ? 'selected' : ''}>Out For Delivery</option>
											<option value="Delivered" ${order.status == 'Delivered' ? 'selected' : ''}>Delivered</option>
												<%-- Add other statuses like Cancelled if needed --%>
										</select>
										<button type="submit" class="btn btn-secondary btn-sm" ${order.status == 'Delivered' ? 'disabled' : ''}>
											<i class="fa-solid fa-sync-alt"></i> Update
										</button>
									</form>
								</div>

							</div> <%-- End Order Summary & Status Column --%>
						</div> <%-- End row --%>
					</div> <%-- End order-body --%>
				</div> <%-- End order-card --%>
			</c:forEach>
		</c:otherwise>
	</c:choose>

</main> <%-- End main wrapper --%>

<%-- Footer --%>
<%@include file="footer.jsp"%>
<%@include file="Components/admin_modals.jsp"%>

</body>
</html>