<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Optional: Add errorPage directive --%>
<%-- <%@page errorPage="error_exception.jsp"%> --%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Become a Seller - Phong Shop</title>
    <%@include file="Components/common_css_js.jsp"%>
    <style>
        body {
            background-color: #f4f7f6;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        .register-container {
            flex-grow: 1;
            display: flex;
            align-items: center;
            padding-top: 2rem;
            padding-bottom: 2rem;
        }
        .register-card {
            border: none;
            border-radius: 0.75rem;
            box-shadow: 0 5px 25px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .register-card .card-header {
            background-color: #6f42c1; /* Bootstrap purple variant */
            color: #fff;
            padding: 1.5rem 1rem;
            border-bottom: none;
            text-align: center;
        }
        .register-card .card-header i { /* Icon if you add one */
            font-size: 2.5rem;
            margin-bottom: 0.75rem;
            display: block;
        }
        .register-card .card-title {
            margin-bottom: 0;
            font-weight: 500;
            font-size: 1.6rem; /* Slightly larger title */
        }
        .register-card .card-body {
            padding: 1.5rem 2rem;
        }
        .register-card .section-title {
            font-weight: 600;
            font-size: 1.1rem;
            color: #495057;
            margin-top: 1rem;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid #eee;
        }
        .register-card .form-label {
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: #495057;
            font-size: 0.95rem;
        }
        .register-card .form-control, .register-card .form-select {
            height: calc(1.5em + 0.9rem + 2px);
            border-radius: 0.375rem;
            border: 1px solid #ced4da;
            font-size: 0.95rem;
        }
        .register-card .form-control:focus, .register-card .form-select:focus {
            border-color: #86b7fe;
            outline: 0;
            box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
        }
        .register-card .btn-primary {
            padding: 0.7rem 1.5rem; /* Slightly larger button */
            font-size: 1.1rem;
            font-weight: 500;
            border-radius: 50px;
            width: 100%;
        }
        .register-card .btn-primary:hover {
            background-color: #0b5ed7;
        }
        .register-card .alert {
            margin-bottom: 1.5rem;
        }
        .register-card .extra-links {
            margin-top: 1.5rem;
            font-size: 0.9rem;
        }
        .register-card .extra-links a {
            text-decoration: none;
            font-weight: 500;
        }
        .register-card .extra-links span {
            color: #6c757d;
        }
        .register-card .form-check-label {
            font-size: 0.9rem;
        }
    </style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Use Guest Navbar View --%>
<%@include file="Components/navbar.jsp"%>

<main class="container register-container flex-grow-1">
    <div class="row w-100 justify-content-center">
        <div class="col-11 col-sm-10 col-md-9 col-lg-8 col-xl-7"> <%-- Wider card for more fields --%>
            <div class="card register-card">
                <div class="card-header">
                    <i class="fas fa-store"></i> <%-- Store Icon --%>
                    <h3 class="card-title">Apply to Sell on Phong Shop</h3>
                </div>
                <div class="card-body">

                    <%-- Display Messages (e.g., registration failure) --%>
                    <%@include file="Components/alert_message.jsp"%>

                    <%-- Registration Form --%>
                    <form action="VendorRegisterServlet" method="post" id="vendor-register-form" class="needs-validation" novalidate>

                        <h5 class="section-title">Owner Account Details</h5>
                        <%-- User account fields --%>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="regUserName" class="form-label">Your Full Name</label>
                                <input type="text" class="form-control" id="regUserName" name="user_name" placeholder="Enter your full name" required>
                                <div class="invalid-feedback">Please enter your name.</div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="regUserEmail" class="form-label">Your Login Email</label>
                                <input type="email" class="form-control" id="regUserEmail" name="user_email" placeholder="Your primary email address" required>
                                <div class="invalid-feedback">Please enter a valid email.</div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="regUserPassword" class="form-label">Create Password</label>
                                <input type="password" class="form-control" id="regUserPassword" name="user_password" placeholder="Create account password" required minlength="8" pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}" title="Min. 8 chars, incl. number, uppercase, lowercase">
                                <div class="invalid-feedback">Password must meet complexity requirements.</div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="regUserMobile" class="form-label">Your Mobile Number</label>
                                <input type="tel" class="form-control" id="regUserMobile" name="user_mobile_no" placeholder="Your primary mobile number" required pattern="[0-9\s\-+()]*">
                                <div class="invalid-feedback">Please enter a valid phone number.</div>
                            </div>
                        </div>

                        <h5 class="section-title">Shop Details</h5>
                        <%-- Vendor specific fields --%>
                        <div class="mb-3">
                            <label for="regShopName" class="form-label">Shop Name</label>
                            <input type="text" class="form-control" id="regShopName" name="shop_name" placeholder="The public name for your shop" required>
                            <div class="invalid-feedback">Please enter a shop name.</div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="regBusinessEmail" class="form-label">Business Email (Optional)</label>
                                <input type="email" class="form-control" id="regBusinessEmail" name="business_email" placeholder="Optional contact email">
                                <%-- No 'required' here, can be null --%>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="regBusinessPhone" class="form-label">Business Phone (Optional)</label>
                                <input type="tel" class="form-control" id="regBusinessPhone" name="business_phone" placeholder="Optional contact phone" pattern="[0-9\s\-+()]*">
                            </div>
                        </div>
                        <%-- Add inputs for other VENDOR fields here if needed (Address, VAT etc) --%>

                        <div class="mb-3">
                            <label for="regVendorAddress" class="form-label">Business Address (Optional)</label>
                            <input type="text" class="form-control" id="regVendorAddress" name="business_address" placeholder="Street Address">
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="regVendorCity" class="form-label">Town/City (Optional)</label>
                                <input type="text" class="form-control" id="regVendorCity" name="business_city">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="regVendorPostcode" class="form-label">Postcode (Optional)</label>
                                <input type="text" class="form-control" id="regVendorPostcode" name="business_postcode" pattern="[A-Za-z]{1,2}[0-9Rr][0-9A-Za-z]? [0-9][A-Za-z]{2}">
                            </div>
                        </div>
                        <hr class="my-4">

                        <div class="form-check mb-4">
                           <input class="form-check-input" type="checkbox" value="" id="termsCheck" required>
                           <label class="form-check-label" for="termsCheck">
                               I agree to the <a href="/terms_vendor.jsp" target="_blank">Vendor Terms & Conditions</a>. </label><%-- Link to T&Cs page --%>
                        <div class="invalid-feedback">You must agree before submitting.</div>
                </div>


                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-primary btn-lg">
                        <i class="fa-solid fa-store"></i> Submit Application
                    </button>
                </div>

                <div class="mt-3 text-center extra-links">
                    <span>Already have an account? </span><a href="login.jsp">Sign in as Customer</a> |
                    <a href="vendor_login.jsp">Sign in as Vendor</a>
                </div>
                </form>
            </div>
        </div>
    </div>
    </div>
</main>

<%-- Footer --%>
<%@include file="footer.jsp"%>

<script>
    // Bootstrap validation script
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