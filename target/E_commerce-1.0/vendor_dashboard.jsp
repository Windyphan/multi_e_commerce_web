<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.entities.Vendor"%> <%-- For session check --%>
<%@page import="com.phong.entities.Message"%> <%-- For potential messages --%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check: Ensure vendor is logged in and approved --%>
<c:set var="activeVendor" value="${sessionScope.activeVendor}" />
<c:if test="${empty activeVendor or not activeVendor.approved}">
    <c:set var="errorMessage" value="Access Denied. Please log in as an approved vendor." scope="session"/>
    <c:set var="errorType" value="error" scope="session"/>
    <c:set var="errorClass" value="alert-danger" scope="session"/>
    <c:redirect url="vendor_login.jsp"/>
</c:if>

<%--
    Optional Data Fetching (Example - Implement in specific pages later)
    // Vendor specific data like pending orders, total products etc. could be fetched here
    // by instantiating DAOs and setting request attributes, but it's often better
    // to fetch data only on the specific management pages (vendor_orders.jsp etc.)
    // int pendingOrderCount = orderDao.getPendingOrderCountForVendor(activeVendor.getVendorId());
    // request.setAttribute("pendingOrderCount", pendingOrderCount);
--%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vendor Dashboard - Phong Shop</title>
    <%@include file="Components/common_css_js.jsp"%>
    <style>
        body {
            background-color: #f8f9fa;
        }
        .dashboard-header {
            background-color: #ffffff;
            padding: 1.5rem;
            margin-bottom: 2rem;
            border-radius: 0.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }
        .dashboard-header h2 {
            margin-bottom: 0.25rem;
        }
        .dashboard-header .shop-name {
            color: #6f42c1; /* Vendor purple */
            font-weight: 600;
        }
        .dashboard-card { /* Reusing style from admin.jsp */
            transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
            border: none;
            border-radius: 0.5rem;
            background-color: #ffffff;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            color: #343a40;
        }
        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.12);
        }
        .dashboard-card a {
            text-decoration: none;
            color: inherit; /* Inherit text color for link */
        }
        .dashboard-card .card-body {
            padding: 2rem 1.5rem; /* More vertical padding */
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 180px; /* Ensure consistent height */
        }
        .dashboard-card i { /* Style icons */
            font-size: 2.8rem; /* Larger icons */
            color: #6f42c1; /* Vendor purple */
            margin-bottom: 1rem;
            opacity: 0.9;
        }
        .dashboard-card .card-title {
            font-size: 1.25rem;
            font-weight: 600;
            margin-top: 0.5rem;
        }
        .dashboard-card .card-text { /* For optional counts */
            font-size: 1.5rem;
            font-weight: 700;
            color: #495057;
        }
    </style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar - Needs adaptation for Vendor context or use a specific vendor_navbar.jsp --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

    <%-- Display Messages --%>
    <%@include file="Components/alert_message.jsp"%>

    <%-- Dashboard Header --%>
    <div class="dashboard-header">
        <h2>Vendor Dashboard</h2>
        <p class="lead text-muted mb-0">Welcome back, <span class="shop-name"><c:out value="${activeVendor.shopName}"/></span>!</p>
    </div>

    <%-- Dashboard Link Cards --%>
    <div class="row g-4 justify-content-center">
        <div class="col-12 col-sm-6 col-lg-4">
            <div class="card dashboard-card text-center h-100">
                <a href="vendor_products.jsp">
                    <div class="card-body">
                        <i class="fas fa-box-open"></i>
                        <h4 class="card-title">Manage Products</h4>
                        <%-- Optional: Display product count --%>
                        <%-- <p class="card-text">${vendorProductCount}</p> --%>
                    </div>
                </a>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-lg-4">
            <div class="card dashboard-card text-center h-100">
                <a href="vendor_orders.jsp">
                    <div class="card-body">
                        <i class="fas fa-receipt"></i>
                        <h4 class="card-title">View Orders</h4>
                        <%-- Optional: Display new/pending order count --%>
                        <%-- <p class="card-text">${pendingOrderCount}</p> --%>
                    </div>
                </a>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-lg-4">
            <div class="card dashboard-card text-center h-100">
                <a href="vendor_profile.jsp">
                    <div class="card-body">
                        <i class="fas fa-store-alt"></i>
                        <h4 class="card-title">Shop Settings</h4>
                        <%-- Optional: Maybe link to profile editing --%>
                    </div>
                </a>
            </div>
        </div>
        <%-- Add more cards for Payouts, Analytics etc. later --%>
    </div>

</main> <%-- End main wrapper --%>

<%-- Footer --%>
<%@include file="footer.jsp"%>

</body>
</html>