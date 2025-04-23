<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.dao.VendorDao"%>
<%@page import="com.phong.dao.UserDao"%> <%-- Needed to get owner names --%>
<%@page import="com.phong.entities.Vendor"%>
<%@page import="com.phong.entities.User"%> <%-- Needed for user map --%>
<%@page import="com.phong.entities.Admin"%>
<%@page import="com.phong.entities.Message"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Collections"%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check & Data Fetching --%>
<%
    Admin activeAdminForVendorDisplay = (Admin) session.getAttribute("activeAdmin");
    if (activeAdminForVendorDisplay == null) {
        pageContext.setAttribute("errorMessage", "You are not logged in! Login first!!", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
        response.sendRedirect("adminlogin.jsp");
        return;
    }

    // Fetch All Vendors
    VendorDao vendorDao = new VendorDao();
    List<Vendor> vendorList = vendorDao.getAllVendors();

    // Fetch associated owner user details efficiently
    Map<Integer, User> ownerUserMap = new HashMap<>();
    if (vendorList != null) {
        UserDao userDao = new UserDao();
        for (Vendor vendor : vendorList) {
            if (!ownerUserMap.containsKey(vendor.getOwnerUserId())) {
                User owner = userDao.getUserById(vendor.getOwnerUserId());
                ownerUserMap.put(vendor.getOwnerUserId(), owner != null ? owner : new User()); // Handle null user
            }
        }
    } else {
        vendorList = Collections.emptyList(); // Ensure list is not null
        pageContext.setAttribute("errorMessage", "Could not retrieve vendor list.", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
    }

    // Make data available for EL
    request.setAttribute("allVendors", vendorList);
    request.setAttribute("ownerUsers", ownerUserMap);

%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Vendors - Phong Shop Admin</title>
    <%@include file="Components/common_css_js.jsp"%>
    <style>
        /* Reuse styles from other admin display pages */
        body { background-color: #f8f9fa; }
        .table th { font-weight: 600; background-color: #e9ecef; vertical-align: middle; }
        .table td { vertical-align: middle; font-size: 0.95rem; }
        .action-buttons a, .action-buttons button { margin: 0 3px; font-size: 0.85rem; padding: 0.25rem 0.6rem; }
        .page-header { margin-bottom: 1.5rem; }
        .vendor-shop-name { font-weight: 500; }
        .owner-details { font-size: 0.9em; color: #6c757d; }
        .status-badge { font-size: 0.85em; font-weight: 600; }
    </style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

    <h2 class="page-header">Manage Vendors</h2>

    <%-- Display Messages --%>
    <%@include file="Components/alert_message.jsp"%>

    <div class="card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover table-striped mb-0">
                    <thead>
                    <tr class="text-center table-light">
                        <th class="text-start ps-3">Shop Name</th>
                        <th class="text-start">Owner Details</th>
                        <th>Business Contact</th>
                        <th>Registered</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%-- Check if list is empty --%>
                    <c:if test="${empty allVendors}">
                        <tr>
                            <td colspan="6" class="text-center text-muted p-4">No vendors found.</td>
                        </tr>
                    </c:if>

                    <%-- Loop through vendors using JSTL --%>
                    <c:forEach var="vendor" items="${allVendors}">
                        <c:set var="owner" value="${ownerUsers[vendor.ownerUserId]}"/> <%-- Get owner user --%>
                        <tr class="text-center">
                            <td class="text-start ps-3 vendor-shop-name">
                                <c:out value="${vendor.shopName}"/>
                            </td>
                            <td class="text-start owner-details">
                                <c:out value="${owner.userName}"/><br>
                                <a href="mailto:${owner.userEmail}"><c:out value="${owner.userEmail}"/></a>
                            </td>
                            <td>
                                <c:if test="${not empty vendor.businessEmail}">
                                    <a href="mailto:${vendor.businessEmail}"><c:out value="${vendor.businessEmail}"/></a><br>
                                </c:if>
                                <c:if test="${not empty vendor.businessPhone}">
                                    <c:out value="${vendor.businessPhone}"/>
                                </c:if>
                                <c:if test="${empty vendor.businessEmail && empty vendor.businessPhone}">
                                    <span class="text-muted fst-italic">N/A</span>
                                </c:if>
                            </td>
                            <td>
                                <fmt:formatDate value="${vendor.registrationDate}" pattern="dd MMM yyyy"/>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${vendor.approved}">
                                        <span class="badge bg-success status-badge">Approved</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-warning text-dark status-badge">Pending Approval</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="action-buttons">
                                <c:if test="${not vendor.approved}">
                                    <%-- Link to Approve action in AddOperationServlet --%>
                                    <a href="AddOperationServlet?operation=approveVendor&vid=${vendor.vendorId}"
                                       class="btn btn-success btn-sm" role="button"
                                       onclick="return confirm('Are you sure you want to approve vendor \'${vendor.shopName}\'?');">
                                        <i class="fa-solid fa-check"></i> Approve
                                    </a>
                                </c:if>

                                <c:if test="${vendor.approved}">
                                    <%-- Link to Suspend action in AddOperationServlet --%>
                                    <a href="AddOperationServlet?operation=suspendVendor&vid=${vendor.vendorId}"
                                       class="btn btn-sm" role="button"
                                       onclick="return confirm('Are you sure you want to suspend vendor \'${vendor.shopName}\'?');">
                                        <i class="fa-solid fa-check"></i> Suspend
                                    </a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div> <%-- End table-responsive --%>
        </div> <%-- End card-body --%>
    </div> <%-- End card --%>

</main> <%-- End main wrapper --%>

<%-- Footer --%>
<%@include file="footer.jsp"%>

</body>
</html>