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
	OrderDao orderDaoForOrderDisplay = new OrderDao();
	List<Order> orderListForOrderDisplay = orderDaoForOrderDisplay.getAllOrder(); // Fetches all orders

	// Fetch associated user and product details efficiently
	// Create Maps to store details keyed by ID to avoid repeated DB calls in loops
	Map<Integer, User> userMapForOrderDisplay = new HashMap<>();
	Map<Integer, List<OrderedProduct>> orderedProductMapForOrderDisplay = new HashMap<>();
	UserDao userDaoForOrderDisplay = new UserDao();
	OrderedProductDao ordProdDaoForOrderDisplay = new OrderedProductDao();

	if (orderListForOrderDisplay != null) {
		for (Order order : orderListForOrderDisplay) {
			// Fetch User if not already fetched
			if (!userMapForOrderDisplay.containsKey(order.getUserId())) {
				User orderUser = userDaoForOrderDisplay.getUserById(order.getUserId());
				if (orderUser != null) {
					userMapForOrderDisplay.put(order.getUserId(), orderUser);
				} else {
					// Handle case where user might have been deleted
					User deletedUser = new User();
					deletedUser.setUserName("User Deleted");
					deletedUser.setUserPhone("");
					deletedUser.setUserAddress("N/A");
					deletedUser.setUserCity("");
					deletedUser.setUserCounty("");
					deletedUser.setUserPostcode("");
					userMapForOrderDisplay.put(order.getUserId(), deletedUser);
				}
			}
			// Fetch Ordered Products for this order
			List<OrderedProduct> productsForOrder = ordProdDaoForOrderDisplay.getAllOrderedProduct(order.getId());
			orderedProductMapForOrderDisplay.put(order.getId(), productsForOrder != null ? productsForOrder : Collections.emptyList());
		}
	} else {
		orderListForOrderDisplay = Collections.emptyList(); // Ensure list is not null for JSTL
		pageContext.setAttribute("errorMessage", "Could not retrieve orders.", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
	}

	// Make data available for EL
	request.setAttribute("allOrders", orderListForOrderDisplay);
	request.setAttribute("usersData", userMapForOrderDisplay);
	request.setAttribute("orderedProductsData", orderedProductMapForOrderDisplay);
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

<%-- Main Content Wrapper --%>
<main>

	<h2 class="mb-4">Manage Customer Orders</h2>

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
                                         "  id="statusBadge-${order.id}">
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

									<%-- Status Update Controls (No Form Tag) --%>
								<div class="mt-3 status-update-form d-flex align-items-center"> <%-- Added flex directly here --%>
										<%-- Label is visually hidden but good for accessibility --%>
									<label for="statusSelect-${order.id}" class="form-label me-2 visually-hidden">Update Status for Order #<c:out value="${order.orderId}"/></label>

									<select id="statusSelect-${order.id}" name="status" class="form-select form-select-sm" ${order.status == 'Delivered' ? 'disabled' : ''}>
										<option value="" selected disabled>-- Change Status --</option>
										<option value="Order Confirmed" ${order.status == 'Order Confirmed' ? 'selected' : ''}>Order Confirmed</option>
										<option value="Shipped" ${order.status == 'Shipped' ? 'selected' : ''}>Shipped</option>
										<option value="Out For Delivery" ${order.status == 'Out For Delivery' ? 'selected' : ''}>Out For Delivery</option>
										<option value="Delivered" ${order.status == 'Delivered' ? 'selected' : ''}>Delivered</option>
									</select>

										<%-- Changed to type="button", added class and data attribute --%>
									<button type="button" class="btn btn-secondary btn-sm ms-2 btn-update-status"
											data-order-id="${order.id}" <%-- Store DB primary key 'id' --%>
										${order.status == 'Delivered' ? 'disabled' : ''}>
										<i class="fa-solid fa-sync-alt"></i> Update
									</button>
								</div>

							</div> <%-- End Order Summary & Status Column --%>
						</div> <%-- End row --%>
					</div> <%-- End order-body --%>
				</div> <%-- End order-card --%>
			</c:forEach>
		</c:otherwise>
	</c:choose>

</main> <%-- End main wrapper --%>
<script>
	document.addEventListener('DOMContentLoaded', () => {
		document.querySelectorAll('.btn-update-status').forEach(button => {
			button.addEventListener('click', function(event) {
				event.preventDefault();
				const orderId = this.getAttribute('data-order-id');
				const selectElement = document.getElementById('statusSelect-' + orderId); // Concatenation for ID

				if (!selectElement) {
					console.error("Could not find select element for order " + orderId); // Concatenation
					return;
				}
				const newStatus = selectElement.value;

				if (!newStatus || newStatus === "") {
					Swal.fire('Error', 'Please select a valid status.', 'warning');
					return;
				}

				// --- UI Updates & Fetch ---
				this.disabled = true;
				const originalButtonText = this.innerHTML;
				// No template literal here, simple HTML string
				this.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Updating...';

				const formData = new FormData();
				formData.append('oid', orderId);
				formData.append('status', newStatus);

				// var formData = "oid=" + encodeURIComponent(orderId)
				// 		+ "&status=" + encodeURIComponent(newStatus);

				// console.log("--- FormData Contents Before Fetch ---");
				// for (let [key, value] of data.entries()) {
				// 	console.log(key + ': ' + value);
				// }
				// console.log("------------------------------------");

				fetch('UpdateOrderServlet', {
					method: 'POST',
					body: formData
				})
						.then(response => {
							// Check response.ok FIRST before assuming JSON
							if (!response.ok) {
								// console.log("--- FormData Contents Before Fetch ---");
								// for (let [key, value] of data.entries()) {
								// 	console.log(key + ': ' + value);
								// }
								// console.log("------------------------------------");
								// Try to get error text, then throw
								return response.text().then(text => {
									throw new Error("HTTP error " + response.status + ": " + (text || 'Server error'));
								});
							}
							return response.json(); // Expect JSON on success
						})
						.then(data => {
							if (data && data.status === 'success') { // Check response structure
								Swal.fire({
									toast: true,
									icon: 'success',
									title: data.message || 'Status Updated!',
									position: 'top-end',
									showConfirmButton: false,
									timer: 2500,
									timerProgressBar: true
								});

								// --- Update UI ---
								const statusBadge = document.getElementById('statusBadge-' + orderId); // Concatenation for ID
								if (statusBadge) {
									// Use data from JSON response (data.newStatus should match newStatus variable)
									statusBadge.textContent = data.newStatus || newStatus;
									statusBadge.className = 'badge status-badge ms-1 ' + getStatusBadgeClass(data.newStatus || newStatus);
								}

								if ((data.newStatus || newStatus) === 'Delivered') {
									selectElement.disabled = true;
									this.disabled = true;
									this.innerHTML = 'Updated';
								} else {
									this.disabled = false;
									this.innerHTML = originalButtonText;
								}

							} else {
								// Handle error reported in JSON response
								Swal.fire('Update Failed', (data ? data.message : null) || 'Could not update status.', 'error');
								this.disabled = false;
								this.innerHTML = originalButtonText;
							}
						})
						.catch(error => {
							console.error('Error updating order status:', error);
							// Display error from catch (could be network error or error thrown from !response.ok)
							Swal.fire('Error', error.message || 'An unexpected error occurred. Please try again.', 'error');
							// Ensure button is re-enabled and text reset on any failure
							this.disabled = false;
							this.innerHTML = originalButtonText;
						});
			});
		});

		// Helper function (no changes needed, doesn't use template literals)
		function getStatusBadgeClass(status) {
			switch(status) {
				case 'Delivered': return 'bg-success';
				case 'Shipped':
				case 'Out For Delivery': return 'bg-info text-dark';
				case 'Order Confirmed': return 'bg-primary';
				default: return 'bg-warning text-dark';
			}
		}

	}); // End DOMContentLoaded
</script>
</body>
</html>