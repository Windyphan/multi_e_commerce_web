<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.dao.OrderDao"%>
<%@page import="com.phong.dao.OrderedProductDao"%>
<%@page import="com.phong.dao.UserDao"%>
<%@page import="com.phong.entities.Order"%>
<%@page import="com.phong.entities.OrderedProduct"%>
<%@page import="com.phong.entities.Vendor"%>
<%@page import="com.phong.entities.User"%>
<%@page import="com.phong.entities.Message"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.stream.Collectors"%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check & Data Fetching --%>
<%
    Vendor activeVendor = (Vendor) session.getAttribute("activeVendor");
    // Redirect if not logged in as vendor or if vendor is not approved
    if (activeVendor == null || !activeVendor.isApproved()) {
        pageContext.setAttribute("errorMessage", "Access Denied. Please log in as an approved vendor.", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
        response.sendRedirect("vendor_login.jsp");
        return;
    }

    int vendorId = activeVendor.getVendorId();

    // Fetch Orders containing items from this vendor
    OrderDao orderDao = new OrderDao();
    List<Order> relevantOrderList = orderDao.getAllOrderByVendorId(vendorId);

    // Fetch associated ordered products and user details efficiently
    Map<Integer, List<OrderedProduct>> vendorOrderedProductMap = new HashMap<>(); // Key: order.id, Value: List of *vendor's* items in that order
    Map<Integer, User> customerMap = new HashMap<>(); // Key: user.id, Value: User object
    UserDao userDao = new UserDao();
    OrderedProductDao ordProdDao = new OrderedProductDao();

    if (relevantOrderList != null) {
        for (Order order : relevantOrderList) {
            // Fetch Customer if not already fetched
            if (!customerMap.containsKey(order.getUserId())) {
                User customer = userDao.getUserById(order.getUserId());
                customerMap.put(order.getUserId(), customer != null ? customer : new User()); // Handle null user
            }

            // Fetch ALL ordered products for this order
            List<OrderedProduct> allProductsForOrder = ordProdDao.getAllOrderedProduct(order.getId());
            if (allProductsForOrder != null) {
                // Filter to get only items belonging to THIS vendor
                List<OrderedProduct> vendorItems = allProductsForOrder.stream()
                        .filter(item -> item.getVendorId() == vendorId)
                        .collect(Collectors.toList());
                vendorOrderedProductMap.put(order.getId(), vendorItems);
            } else {
                vendorOrderedProductMap.put(order.getId(), Collections.emptyList());
            }
        }
    } else {
        relevantOrderList = Collections.emptyList(); // Ensure list is not null for JSTL
        pageContext.setAttribute("errorMessage", "Could not retrieve your orders.", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
    }

    // Make data available for EL
    request.setAttribute("vendorOrders", relevantOrderList);
    request.setAttribute("vendorItemsByOrder", vendorOrderedProductMap);
    request.setAttribute("customers", customerMap);

%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Orders - Phong Shop Vendor</title>
    <%@include file="Components/common_css_js.jsp"%>
    <style>
        /* Reuse styles from admin display_orders if desired, or customize */
        body { background-color: #f8f9fa; }
        .order-card { border: 1px solid #dee2e6; border-radius: 0.375rem; margin-bottom: 1.5rem; background-color: #fff; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
        .order-header { background-color: #f8f9fa; padding: 0.75rem 1.25rem; border-bottom: 1px solid #dee2e6; display: flex; justify-content: space-between; align-items: center; font-size: 0.9rem; }
        .order-header .order-id { font-weight: 600; color: #6f42c1; /* Vendor purple */ }
        .order-header .order-date, .order-header .order-status-header { color: #6c757d; }
        .order-body { padding: 1.25rem; }
        .order-section-title { font-weight: 600; margin-bottom: 0.75rem; color: #495057; font-size: 1rem; border-bottom: 1px solid #eee; padding-bottom: 0.5rem; }
        .address-details p, .customer-details p { margin-bottom: 0.25rem; font-size: 0.9rem; line-height: 1.5; }
        .address-details strong, .customer-details strong { color: #212529; }
        .vendor-item-list { list-style: none; padding-left: 0; margin-top: 1rem; font-size: 0.9rem; }
        .vendor-item-list li { display: flex; align-items: center; padding: 0.5rem 0; border-bottom: 1px dashed #eee; }
        .vendor-item-list li:last-child { border-bottom: none; }
        .vendor-item-img { width: 40px; height: 40px; object-fit: contain; margin-right: 10px; }
        .vendor-item-details { flex-grow: 1; }
        .vendor-item-name { font-weight: 500; }
        .vendor-item-qty-price { color: #555; font-size: 0.85em; }
        .status-badge { font-size: 0.85em; font-weight: 600; }
        .empty-orders img { max-width: 150px; opacity: 0.7; }
        .empty-orders h4 { margin-top: 1rem; color: #6c757d; }
    </style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar (Vendor context) --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

    <h2 class="mb-4">Your Order Items to Fulfill</h2>

    <%-- Display Messages --%>
    <%@include file="Components/alert_message.jsp"%>

    <%-- Check if there are any orders for this vendor --%>
    <c:choose>
        <c:when test="${empty vendorOrders}">
            <div class="text-center p-5 empty-orders">
                <img src="Images/empty-cart.png" alt="No Orders"> <%-- Update icon maybe --%>
                <h4>You have no orders requiring fulfillment yet.</h4>
            </div>
        </c:when>
        <c:otherwise>
            <%-- Loop through each relevant Order --%>
            <c:forEach var="order" items="${vendorOrders}">
                <div class="card order-card">
                    <div class="order-header">
                        <div>
                            Order <span class="order-id">#<c:out value="${order.orderId}"/></span>
                            <span class="ms-3">(Payment: <c:out value="${order.paymentType}"/>)</span>
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
                    <div class="order-body">
                        <div class="row">
                                <%-- Customer/Shipping Info --%>
                            <div class="col-md-5 mb-3 mb-md-0">
                                <h6 class="order-section-title">Ship To</h6>
                                <c:set var="customer" value="${customers[order.userId]}"/>
                                <div class="customer-details mb-2">
                                    <p><strong>Customer:</strong> <c:out value="${customer.userName}"/></p>
                                    <p><strong>Phone:</strong> <c:out value="${customer.userPhone}"/></p>
                                        <%-- Maybe hide email from vendor? <p><strong>Email:</strong> <c:out value="${customer.userEmail}"/></p> --%>
                                </div>
                                <div class="address-details">
                                    <p>
                                        <c:out value="${customer.userAddress}"/><br>
                                        <c:out value="${customer.userCity}"/><br>
                                        <c:out value="${customer.userCounty}"/>, <c:out value="${customer.userPostcode}"/>
                                    </p>
                                </div>
                            </div>
                                <%-- Vendor's Items in this Order --%>
                            <div class="col-md-7">
                                <h6 class="order-section-title">Your Item(s) in this Order</h6>
                                <c:set var="vendorItemsInThisOrder" value="${vendorItemsByOrder[order.id]}"/>
                                <c:choose>
                                    <c:when test="${empty vendorItemsInThisOrder}">
                                        <p class="text-muted fst-italic">No items found for your shop in this order record.</p>
                                    </c:when>
                                    <c:otherwise>
                                        <ul class="vendor-item-list">
                                            <c:forEach var="item" items="${vendorItemsInThisOrder}">
                                                <li>
                                                    <img src="${s3BaseUrl}${item.image}" alt="" class="vendor-item-img">
                                                    <div class="vendor-item-details">
                                                        <span class="vendor-item-name"><c:out value="${item.name}"/></span>
                                                        <span class="d-block vendor-item-qty-price">
                                                                 Qty: <c:out value="${item.quantity}"/> @
                                                                 <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="£"/> each
                                                             </span>
                                                    </div>
                                                        <%-- Maybe add SKU or other vendor-specific info here? --%>
                                                </li>
                                            </c:forEach>
                                        </ul>
                                        <%-- Optional: Add button for vendor to mark as shipped (would need new servlet/logic) --%>
                                        <%--
                                        <div class="text-end mt-3">
                                            <button class="btn btn-sm btn-outline-success" ${order.status != 'Order Confirmed' ? 'disabled' : ''}>Mark as Shipped</button>
                                        </div>
                                        --%>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div> <%-- End row --%>
                    </div> <%-- End order-body --%>
                </div> <%-- End order-card --%>
            </c:forEach>
        </c:otherwise>
    </c:choose>

</main> <%-- End main wrapper --%>

<%-- Footer --%>
<%@include file="Components/footer.jsp"%>

</body>
</html>