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
        UserDao userDaoForVendorDisplay = new UserDao();
        for (Vendor vendor : vendorList) {
            if (!ownerUserMap.containsKey(vendor.getOwnerUserId())) {
                User owner = userDaoForVendorDisplay.getUserById(vendor.getOwnerUserId());
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
        .btn-suspend {
            /* Example: Use warning color, or secondary */
            background-color: #ffc107;
            border-color: #ffc107;
            color: #000; /* Text color for warning */
        }
        .btn-suspend:hover {
            background-color: #e0a800;
            border-color: #d39e00;
            color: #000;
        }
        /* Simple alert styling for dynamic messages */
        #vendor-alert-placeholder .alert {
            display: none; /* Hidden initially */
        }
    </style>
</head>
<body class="d-flex flex-column min-vh-100">

<%-- Main Content Wrapper --%>
<main>
    <h2 class="page-header">Manage Vendors</h2>

    <%-- Placeholder for dynamic AJAX messages --%>
    <div id="vendor-alert-placeholder" class="mb-3">
        <div class="alert" role="alert">
            <span class="alert-message"></span>
            <button type="button" class="btn-close float-end" aria-label="Close" onclick="$(this).parent().hide();"></button>
        </div>
    </div>


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
                    <%-- ADD ID to tbody --%>
                    <tbody id="vendor-table-body">
                    <%-- ADD No Results Row --%>
                    <tr id="vendor-no-results-row" style="${empty allVendors ? '' : 'display: none;'}">
                        <td colspan="6" class="text-center text-muted p-4">No vendors found.</td>
                    </tr>

                    <c:forEach var="vendor" items="${allVendors}">
                        <c:set var="owner" value="${ownerUsers[vendor.ownerUserId]}"/>
                        <%-- ADD data-vendor-id to row --%>
                        <tr class="text-center" data-vendor-id="${vendor.vendorId}">
                            <td class="text-start ps-3 vendor-shop-name"><c:out value="${vendor.shopName}"/></td>
                            <td class="text-start owner-details">
                                <c:out value="${owner.userName}"/><br>
                                <a href="mailto:${owner.userEmail}"><c:out value="${owner.userEmail}"/></a>
                            </td>
                            <td>
                                    <%-- Contact details --%>
                                <c:if test="${not empty vendor.businessEmail}"><a href="mailto:${vendor.businessEmail}"><c:out value="${vendor.businessEmail}"/></a><br></c:if>
                                <c:if test="${not empty vendor.businessPhone}"><c:out value="${vendor.businessPhone}"/></c:if>
                                <c:if test="${empty vendor.businessEmail && empty vendor.businessPhone}"><span class="text-muted fst-italic">N/A</span></c:if>
                            </td>
                            <td><fmt:formatDate value="${vendor.registrationDate}" pattern="dd MMM yyyy"/></td>
                            <td> <%-- ADD status-cell class for easier selection --%>
                                <span class="status-badge ${vendor.approved ? 'bg-success' : 'bg-warning text-dark'} status-badge-text">
                                        ${vendor.approved ? 'Approved' : 'Pending Approval'}
                                </span>
                            </td>
                            <td class="action-buttons"> <%-- ADD action-cell class --%>
                                <c:choose>
                                    <c:when test="${not vendor.approved}">
                                        <%-- MODIFY Approve Link for AJAX --%>
                                        <a href="javascript:void(0);"
                                           class="btn btn-success btn-sm vendor-action-btn" role="button"
                                           data-vendor-id="${vendor.vendorId}"
                                           data-vendor-name="${vendor.shopName}"
                                           data-action="approveVendor"> <%-- Add action type --%>
                                            <i class="fa-solid fa-check"></i> Approve
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <%-- MODIFY Suspend Link for AJAX --%>
                                        <%-- ADD btn-suspend class for styling --%>
                                        <a href="javascript:void(0);"
                                           class="btn btn-sm btn-suspend vendor-action-btn" role="button"
                                           data-vendor-id="${vendor.vendorId}"
                                           data-vendor-name="${vendor.shopName}"
                                           data-action="suspendVendor"> <%-- Add action type --%>
                                            <i class="fa-solid fa-times"></i> Suspend <%-- Changed icon? --%>
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div> <%-- End table-responsive --%>
        </div> <%-- End card-body --%>
    </div> <%-- End card --%>

</main> <%-- End main wrapper --%>
<script>
    $(document).ready(function() {

        // --- Function to display alerts ---
        function showVendorAlert(message, type) {
            const alertDiv = $('#vendor-alert-placeholder .alert');
            const messageSpan = alertDiv.find('.alert-message');
            messageSpan.text(message);
            alertDiv.removeClass('alert-success alert-danger alert-warning alert-info').addClass('alert-' + (type === 'success' ? 'success' : 'danger'));
            alertDiv.fadeIn();
            // setTimeout(() => { alertDiv.fadeOut(); }, 5000);
        }

        // --- AJAX Vendor Action (Approve/Suspend) ---
        $('#vendor-table-body').on('click', '.vendor-action-btn', function(event) {
            event.preventDefault();

            const button = $(this);
            const vendorId = button.data('vendor-id');
            const vendorName = button.data('vendor-name');
            const action = button.data('action'); // 'approveVendor' or 'suspendVendor'
            const isApproving = (action === 'approveVendor');
            const confirmMessage = isApproving
                ? `Are you sure you want to approve vendor '${vendorName}'?`
                : `Are you sure you want to suspend vendor '${vendorName}'?`;

            if (!confirm(confirmMessage)) {
                return;
            }

            $('#vendor-alert-placeholder .alert').hide();
            button.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i>'); // Show loading

            $.ajax({
                type: 'POST',
                url: 'AddOperationServlet?operation=' + action, // Use action from button data
                data: { vid: vendorId },
                dataType: 'json',
                success: function(response) {
                    if (response.status === 'success' && response.vendorId == vendorId) {
                        showVendorAlert(response.message, 'success');

                        // --- Update UI ---
                        const row = button.closest('tr');
                        const statusBadge = row.find('.status-badge-text');
                        const actionCell = button.closest('td'); // Get the cell containing the button
                        const newStatusIsApproved = response.isApproved;

                        // Update status badge
                        statusBadge.text(newStatusIsApproved ? 'Approved' : 'Pending Approval');
                        statusBadge.removeClass('bg-success bg-warning text-dark')
                            .addClass(newStatusIsApproved ? 'bg-success' : 'bg-warning text-dark');

                        // Create the HTML for the *new* button
                        let newButtonHtml = '';
                        if (newStatusIsApproved) {
                            // Build Suspend button HTML
                            newButtonHtml += '<a href="javascript:void(0);" ';
                            newButtonHtml +=   'class="btn btn-sm btn-suspend vendor-action-btn" role="button" ';
                            newButtonHtml +=   'data-vendor-id="' + vendorId + '" ';
                            newButtonHtml +=   'data-vendor-name="' + vendorName + '" ';
                            newButtonHtml +=   'data-action="suspendVendor">';
                            newButtonHtml +=   '<i class="fa-solid fa-times"></i> Suspend';
                            newButtonHtml += '</a>';
                        } else {
                            // Build Approve button HTML
                            newButtonHtml += '<a href="javascript:void(0);" ';
                            newButtonHtml +=   'class="btn btn-success btn-sm vendor-action-btn" role="button" ';
                            newButtonHtml +=   'data-vendor-id="' + vendorId + '" ';
                            newButtonHtml +=   'data-vendor-name="' + vendorName + '" ';
                            newButtonHtml +=   'data-action="approveVendor">';
                            newButtonHtml +=   '<i class="fa-solid fa-check"></i> Approve';
                            newButtonHtml += '</a>';
                        }
                        // Replace the old button with the new one
                        actionCell.html(newButtonHtml);
                        // Note: No need to re-enable button, as we replaced it.

                    } else {
                        // Handle error from servlet response
                        showVendorAlert(response.message || 'Could not update vendor status.', 'danger');
                        // Restore original button (find original text/icon/class based on action)
                        const originalIcon = isApproving ? 'fa-check' : 'fa-times';
                        const originalClass = isApproving ? 'btn-success' : 'btn-suspend';
                        const originalText = isApproving ? 'Approve' : 'Suspend';
                        button.prop('disabled', false).removeClass('btn-suspend').addClass(originalClass).html(`<i class="fa-solid ${originalIcon}"></i> ${originalText}`);
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    // Handle AJAX communication error
                    console.error("AJAX Vendor Action Error:", textStatus, errorThrown, jqXHR.responseText);
                    showVendorAlert('Failed to communicate with the server. Please try again.', 'danger');
                    // Restore original button
                    const originalIcon = isApproving ? 'fa-check' : 'fa-times';
                    const originalClass = isApproving ? 'btn-success' : 'btn-suspend';
                    const originalText = isApproving ? 'Approve' : 'Suspend';
                    button.prop('disabled', false).removeClass('btn-suspend').addClass(originalClass).html(`<i class="fa-solid ${originalIcon}"></i> ${originalText}`);
                }
            });
        });

    }); // End $(document).ready
</script>
</body>
</html>