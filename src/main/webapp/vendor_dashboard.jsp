<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.entities.Vendor"%> <%-- For session check --%>
<%@page import="com.phong.dao.VendorDao"%> <%-- For session check --%>
<%@page import="java.time.LocalDate"%> <%-- For potential messages --%>
<%@page import="java.util.ArrayList"%> <%-- For potential messages --%>
<%@page import="java.util.HashMap"%> <%-- For potential messages --%>
<%@page import="java.util.List"%> <%-- For potential messages --%>
<%@page import="java.util.Map"%> <%-- For potential messages --%>

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

    // --- NEW: Fetch Sales Summaries ---
    VendorDao vendorDao = new VendorDao(); // DAO with new method
    Map<String, Number> summaryToday = null;
    Map<String, Number> summary7Days = null;
    Map<String, Number> summary15Days = null;
    Map<String, Number> summary30Days = null;

    LocalDate today = LocalDate.now();
    LocalDate yesterday = today.minusDays(1); // For 'today' range start (optional)
    LocalDate sevenDaysAgo = today.minusDays(6);
    LocalDate fifteenDaysAgo = today.minusDays(14);
    LocalDate thirtyDaysAgo = today.minusDays(29);

    String summaryError = null;
    try {
        // Today: From start of today until start of tomorrow
        summaryToday = vendorDao.getVendorSalesSummaryForPeriod(vendorId, yesterday, today);

        // Last 7 Days: From 7 days ago until start of today
        summary7Days = vendorDao.getVendorSalesSummaryForPeriod(vendorId, sevenDaysAgo, today); // Includes today

        // Last 15 Days: From 15 days ago until start of today
        summary15Days = vendorDao.getVendorSalesSummaryForPeriod(vendorId, fifteenDaysAgo, today); // Includes today

        // Last 30 Days: From 30 days ago until start of today
        summary30Days = vendorDao.getVendorSalesSummaryForPeriod(vendorId, thirtyDaysAgo, today); // Includes today

        if (summaryToday == null || summary7Days == null || summary15Days == null || summary30Days == null) {
            // Handle case where DAO method returned null (error)
            summaryError = "Could not load sales summary data.";
        }

    } catch (Exception e) {
        // Handle any unexpected exceptions during date calculation or DAO calls
        System.err.println("Error calculating vendor summaries: " + e.getMessage());
        e.printStackTrace();
        summaryError = "An error occurred while calculating sales summaries.";
    }

    // Set attributes for EL (even if null/empty, JSTL can handle)
    request.setAttribute("summaryToday", summaryToday);
    request.setAttribute("summary7Days", summary7Days);
    request.setAttribute("summary15Days", summary15Days);
    request.setAttribute("summary30Days", summary30Days);
    request.setAttribute("summaryError", summaryError);

%>

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

    <%-- *** Sales Summary Section *** --%>
    <h4 class="mb-3">Sales Summary (Shipped/Delivered Orders)</h4>
    <c:choose>
        <c:when test="${not empty summaryError}">
            <div class="alert alert-warning" role="alert">
                Could not load sales summary: <c:out value="${summaryError}"/>
            </div>
        </c:when>
        <c:otherwise>
            <div class="row g-4">
                    <%-- Today's Summary Card --%>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="card text-center border-primary shadow-sm">
                        <div class="card-header bg-primary text-white">Today</div>
                        <div class="card-body">
                            <p class="card-text fs-4 fw-bold mb-1"><c:out value="${summaryToday.itemsSold}"/></p>
                            <p class="card-text text-muted small mb-2">Items Sold</p>
                            <p class="card-text fs-5 fw-bold">
                                <fmt:formatNumber value="${summaryToday.totalRevenue}" type="currency" currencySymbol="£"/>
                            </p>
                            <p class="card-text text-muted small">Revenue</p>
                        </div>
                    </div>
                </div>
                    <%-- Last 7 Days Summary Card --%>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="card text-center border-info shadow-sm">
                        <div class="card-header bg-info text-dark">Last 7 Days</div>
                        <div class="card-body">
                            <p class="card-text fs-4 fw-bold mb-1"><c:out value="${summary7Days.itemsSold}"/></p>
                            <p class="card-text text-muted small mb-2">Items Sold</p>
                            <p class="card-text fs-5 fw-bold">
                                <fmt:formatNumber value="${summary7Days.totalRevenue}" type="currency" currencySymbol="£"/>
                            </p>
                            <p class="card-text text-muted small">Revenue</p>
                        </div>
                    </div>
                </div>
                    <%-- Last 15 Days Summary Card --%>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="card text-center border-secondary shadow-sm">
                        <div class="card-header bg-secondary text-white">Last 15 Days</div>
                        <div class="card-body">
                            <p class="card-text fs-4 fw-bold mb-1"><c:out value="${summary15Days.itemsSold}"/></p>
                            <p class="card-text text-muted small mb-2">Items Sold</p>
                            <p class="card-text fs-5 fw-bold">
                                <fmt:formatNumber value="${summary15Days.totalRevenue}" type="currency" currencySymbol="£"/>
                            </p>
                            <p class="card-text text-muted small">Revenue</p>
                        </div>
                    </div>
                </div>
                    <%-- Last 30 Days Summary Card --%>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="card text-center border-success shadow-sm">
                        <div class="card-header bg-success text-white">Last 30 Days</div>
                        <div class="card-body">
                            <p class="card-text fs-4 fw-bold mb-1"><c:out value="${summary30Days.itemsSold}"/></p>
                            <p class="card-text text-muted small mb-2">Items Sold</p>
                            <p class="card-text fs-5 fw-bold">
                                <fmt:formatNumber value="${summary30Days.totalRevenue}" type="currency" currencySymbol="£"/>
                            </p>
                            <p class="card-text text-muted small">Revenue</p>
                        </div>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
    <%-- *** END: Sales Summary Section *** --%>


    <hr class="my-4"> <%-- Separator --%>

    <%-- Dashboard Link Cards --%>
    <div class="row g-4 justify-content-center">
        <div class="col-12 col-sm-6 col-lg-4">
            <div class="card dashboard-card text-center h-100">
                <a href="vendor_products.jsp">
                    <div class="card-body">
                        <i class="fas fa-box-open"></i>
                        <h4 class="card-title">Manage Products</h4>
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
                    </div>
                </a>
            </div>
        </div>
        <%-- Add more cards for Payouts, Analytics etc. later --%>
    </div>

</main> <%-- End main wrapper --%>

<%-- Footer --%>
<%@include file="Components/footer.jsp"%>

</body>
</html>