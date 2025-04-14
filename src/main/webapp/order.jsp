<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.entities.User"%>
<%@page import="com.phong.entities.OrderedProduct"%>
<%@page import="com.phong.entities.Order"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.phong.dao.OrderedProductDao"%>
<%@page import="com.phong.dao.OrderDao"%>
<%@page import="java.util.Collections"%>

<%@page errorPage="error_exception.jsp"%>
<%-- Assuming this is included in a page with UTF-8 set --%>

<%-- Security Check & Data Fetching --%>
<%
	User currentUserForOrder = (User) session.getAttribute("activeUser");
	if (currentUserForOrder == null) {
		pageContext.setAttribute("errorMessage", "You are not logged in! Login first!!", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		// Redirect from the main page including this, not here directly if it's an include
		// response.sendRedirect("login.jsp");
		// return;
	}

	// Fetch Orders for the logged-in user
	OrderDao orderDao = new OrderDao();
	List<Order> userOrderList = Collections.emptyList(); // Default to empty
	Map<Integer, List<OrderedProduct>> userOrderedProductMap = new HashMap<>(); // Use map for products

	if (currentUserForOrder != null) { // Only fetch if user is logged in
		userOrderList = orderDao.getAllOrderByUserId(currentUserForOrder.getUserId());

		// Fetch associated product details efficiently
		OrderedProductDao ordProdDao = new OrderedProductDao();
		if (userOrderList != null) {
			for (Order order : userOrderList) {
				List<OrderedProduct> productsForOrder = ordProdDao.getAllOrderedProduct(order.getId());
				userOrderedProductMap.put(order.getId(), productsForOrder != null ? productsForOrder : Collections.emptyList());
			}
		} else {
			userOrderList = Collections.emptyList(); // Handle DAO error
			pageContext.setAttribute("errorMessage", "Could not retrieve your orders.", PageContext.SESSION_SCOPE);
			pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
			pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		}
	}

	// Make data available for EL
	request.setAttribute("myOrders", userOrderList);
	request.setAttribute("myOrderedProducts", userOrderedProductMap);
%>

<style>
	/* Styles specific to user orders */
	.order-history-card {
		border: 1px solid #dee2e6;
		border-radius: 0.375rem;
		margin-bottom: 1.5rem;
		background-color: #fff;
		box-shadow: 0 1px 3px rgba(0,0,0,0.05);
	}
	.order-history-header {
		background-color: #f8f9fa;
		padding: 0.75rem 1.25rem;
		border-bottom: 1px solid #dee2e6;
		display: flex;
		justify-content: space-between;
		align-items: center;
		font-size: 0.9rem;
	}
	.order-history-header .order-id {
		font-weight: 600;
		color: #0d6efd;
	}
	.order-history-header .order-date, .order-history-header .order-status-header {
		color: #6c757d;
	}
	.order-history-body {
		padding: 1.25rem;
	}
	.order-item-row {
		display: flex;
		align-items: center;
		padding: 0.75rem 0;
		border-bottom: 1px dashed #eee; /* Dashed separator */
	}
	.order-item-row:last-child {
		border-bottom: none;
		padding-bottom: 0;
	}
	.order-item-row:first-child {
		padding-top: 0;
	}
	.order-item-img {
		width: 50px;
		height: 50px;
		object-fit: contain;
		margin-right: 15px;
		border: 1px solid #eee;
		padding: 2px;
		background-color: #fff;
	}
	.order-item-details {
		flex-grow: 1; /* Take remaining space */
		font-size: 0.9rem;
	}
	.order-item-name {
		font-weight: 600;
		color: #333;
		display: block; /* Ensure it takes its own line if needed */
	}
	.order-item-qty-price {
		color: #555;
		margin-top: 2px;
	}
	.order-total-per-item {
		font-weight: 500;
		margin-left: auto; /* Push total to the right */
		padding-left: 1rem; /* Space before total */
		color: #212529;
		font-size: 0.95rem;
	}
	.status-badge { /* Reusing admin style, ensure it's available */
		font-size: 0.85em;
		font-weight: 600;
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

<div class="container-fluid px-0 px-md-3 py-3"> <%-- Adjust padding --%>

	<%-- Check if orders exist --%>
	<c:choose>
		<c:when test="${empty myOrders}">
			<div class="text-center p-5 empty-orders">
				<img src="Images/empty-cart.png" alt="No Orders"> <%-- Consider specific icon --%>
				<h4>You haven't placed any orders yet.</h4>
				<a href="products.jsp" class="btn btn-primary mt-3">Start Shopping</a>
			</div>
		</c:when>
		<c:otherwise>
			<h4 class="mb-3">My Order History</h4>
			<%-- Loop through each Order --%>
			<c:forEach var="order" items="${myOrders}">
				<div class="card order-history-card">
					<div class="order-history-header">
						<div>
							Order <span class="order-id">#<c:out value="${order.orderId}"/></span>
							<span class="ms-3">(${order.paymentType})</span>
						</div>
						<div>
                             <span class="order-date">
                                <fmt:formatDate value="${order.date}" pattern="dd MMM yyyy"/>
                            </span>
							<span class="order-status-header ms-3">
                                 Status:
                                 <span class="badge status-badge ms-1
                                     <c:choose>
                                         <c:when test='${order.status == "Delivered"}'>bg-success</c:when>
                                         <c:when test='${order.status == "Shipped" || order.status == "Out For Delivery"}'>bg-info text-dark</c:when>
                                         <c:when test='${order.status == "Order Confirmed"}'>bg-primary</c:when>
                                         <c:otherwise>bg-warning text-dark</c:otherwise>
                                     </c:choose>
                                 ">
                                     <c:out value="${order.status}"/>
                                 </span>
                             </span>
						</div>
					</div>
					<div class="order-history-body">
							<%-- Retrieve product list for this specific order from the map --%>
						<c:set var="productsInThisOrder" value="${myOrderedProducts[order.id]}"/>
						<c:choose>
							<c:when test="${empty productsInThisOrder}">
								<p class="text-muted fst-italic">Product details for this order are currently unavailable.</p>
							</c:when>
							<c:otherwise>
								<%-- Loop through products in this order --%>
								<c:forEach var="orderedProd" items="${productsInThisOrder}">
									<div class="order-item-row">
										<img src="${s3BaseUrl}${orderedProd.image}" alt="" class="order-item-img">
										<div class="order-item-details">
											<span class="order-item-name"><c:out value="${orderedProd.name}"/></span>
											<span class="order-item-qty-price">
                                                Qty: <c:out value="${orderedProd.quantity}"/> | Price Each:
                                                <fmt:formatNumber value="${orderedProd.price}" type="currency" currencySymbol="£"/>
                                            </span>
										</div>
										<div class="order-total-per-item">
											<fmt:formatNumber value="${orderedProd.price * orderedProd.quantity}" type="currency" currencySymbol="£"/>
										</div>
									</div>
								</c:forEach>
							</c:otherwise>
						</c:choose>
					</div>
				</div> <%-- End order-history-card --%>
			</c:forEach>
		</c:otherwise>
	</c:choose>
</div>