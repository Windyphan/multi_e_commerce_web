<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.entities.Vendor"%>
<%@page import="com.phong.entities.Message"%>
<%@page import="com.phong.entities.User"%> <%-- To display owner info --%>
<%@page import="com.phong.dao.UserDao"%> <%-- To fetch owner info --%>

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

    // Fetch owner User details for display (optional but good)
    User ownerUser = null;
    if (activeVendor != null) {
        UserDao userDao = new UserDao();
        ownerUser = userDao.getUserById(activeVendor.getOwnerUserId());
    }
    if(ownerUser == null) ownerUser = new User(); // Avoid NullPointerExceptions in EL

    // Set attributes for EL
    request.setAttribute("vendorDetails", activeVendor);
    request.setAttribute("ownerDetails", ownerUser);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shop Settings - Phong Shop Vendor</title>
    <%@include file="Components/common_css_js.jsp"%>
    <style>
        /* Reuse styles from admin/user profile pages */
        body { background-color: #f8f9fa; }
        .profile-card {
            border: none; border-radius: 0.5rem;
            box-shadow: 0 3px 10px rgba(0,0,0,0.07);
            margin: 2rem auto; max-width: 800px; /* Adjust width */
        }
        .profile-card .card-header { background-color: #e9ecef; font-weight: 600; padding: 1rem 1.25rem; border-bottom: 1px solid #dee2e6; }
        .profile-card .card-header h3 { margin-bottom: 0; font-size: 1.4rem; }
        .profile-card .card-body { padding: 2rem; }
        .profile-form .form-label { font-weight: 600; margin-bottom: 0.5rem; color: #495057; }
        .profile-form .form-control { border-radius: 0.375rem; border: 1px solid #ced4da; }
        .profile-form .form-control:focus { border-color: #86b7fe; outline: 0; box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25); }
        .profile-form .form-control:disabled, .profile-form .form-control[readonly] { background-color: #e9ecef; opacity: 1; }
        .profile-form .btn { padding: 0.5rem 1.2rem; font-weight: 500; }
        .section-divider { margin-top: 1.5rem; margin-bottom: 1.5rem; }
    </style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar (Vendor context) --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

    <div class="card profile-card">
        <div class="card-header text-center">
            <h3><i class="fas fa-store-alt"></i> Your Shop Settings</h3>
        </div>
        <div class="card-body profile-form">

            <%-- Display Messages (e.g., update success/failure) --%>
            <%@include file="Components/alert_message.jsp"%>

            <%-- Form for updating vendor details --%>
            <%-- Point action to a servlet dedicated to vendor updates, e.g., VendorProfileServlet --%>
            <form action="VendorProfileServlet" method="post" class="needs-validation" novalidate>
                <input type="hidden" name="operation" value="updateShopDetails">
                <%-- Vendor ID might not be needed if retrieved from session in servlet --%>
                <input type="hidden" name="vendorId" value="${vendorDetails.vendorId}">

                <h5 class="mb-3">Shop Information</h5>
                <div class="mb-3">
                    <label for="shopNameInput" class="form-label">Shop Name</label>
                    <input type="text" class="form-control" id="shopNameInput" name="shop_name" required value="<c:out value='${vendorDetails.shopName}'/>">
                    <div class="invalid-feedback">Shop name is required.</div>
                </div>
                <%-- Add textarea for shop description if you have that field --%>
                <%-- <div class="mb-3"> <label for="shopDescInput" class="form-label">Shop Description</label> <textarea ...></textarea> </div> --%>
                <%-- Add input type="file" for logo if you have that field & S3 upload logic --%>
                <%-- <div class="mb-3"> <label for="shopLogoInput" class="form-label">Shop Logo</label> <input type="file" name="shop_logo" ...> </div> --%>


                <hr class="section-divider">

                <h5 class="mb-3">Business Contact</h5>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="businessEmailInput" class="form-label">Business Email</label>
                        <input type="email" class="form-control" id="businessEmailInput" name="business_email" value="<c:out value='${vendorDetails.businessEmail}'/>" placeholder="Optional contact email">
                        <%-- Add validation feedback if making required --%>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="businessPhoneInput" class="form-label">Business Phone</label>
                        <input type="tel" class="form-control" id="businessPhoneInput" name="business_phone" value="<c:out value='${vendorDetails.businessPhone}'/>" placeholder="Optional contact phone" pattern="[0-9\s\-+()]*">
                    </div>
                </div>
                <%-- Add inputs for Business Address, VAT Number etc. if added to Vendor entity/table --%>


                <hr class="section-divider">

                <h5 class="mb-3">Owner Account Information</h5>
                <p class="small text-muted">This information is linked to your personal user account. To change these, please update your main user profile.</p>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Owner Name</label>
                        <input type="text" class="form-control" value="<c:out value='${ownerDetails.userName}'/>" readonly disabled>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Owner Login Email</label>
                        <input type="email" class="form-control" value="<c:out value='${ownerDetails.userEmail}'/>" readonly disabled>
                    </div>
                </div>

                <div class="text-center mt-4">
                    <a href="vendor_dashboard.jsp" class="btn btn-secondary me-2">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Save Changes
                    </button>
                </div>

            </form>
        </div> <%-- End card-body --%>
    </div> <%-- End card --%>

</main> <%-- End main wrapper --%>

<%-- Footer --%>
<%@include file="Components/footer.jsp"%>

<script>
    // Standard Bootstrap validation script
    (() => {
        'use strict'
        const forms = document.querySelectorAll('.needs-validation')
        Array.from(forms).forEach(form => {
            form.addEventListener('submit', event => {
                if (!form.checkValidity()) {
                    event.preventDefault()
                    event.stopPropagation()
                }
                form.classList.add('was-validated')
            }, false)
        })
    })()
</script>

</body>
</html>