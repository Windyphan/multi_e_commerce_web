<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Optional: <%@page errorPage="error_exception.jsp"%> --%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vendor Login - Phong Shop</title>
    <%@include file="Components/common_css_js.jsp"%>
    <style>
        body {
            background-color: #f4f7f6;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        .login-container {
            flex-grow: 1;
            display: flex;
            align-items: center;
            padding-top: 2rem;
            padding-bottom: 2rem;
        }
        .login-card {
            border: none;
            border-radius: 0.75rem;
            box-shadow: 0 5px 25px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .login-card .card-header {
            background-color: #6f42c1; /* Same purple as vendor register */
            color: #fff;
            padding: 1.5rem 1rem;
            border-bottom: none;
            text-align: center;
        }
        .login-card .card-header i { /* Icon */
            font-size: 2.5rem;
            margin-bottom: 0.75rem;
            display: block;
        }
        .login-card .card-title {
            margin-bottom: 0;
            font-weight: 500;
            font-size: 1.5rem;
        }
        .login-card .card-body {
            padding: 2rem 2.5rem;
        }
        .login-card .form-label {
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: #495057;
        }
        .login-card .form-control {
            height: calc(1.5em + 1rem + 2px);
            border-radius: 0.375rem;
            border: 1px solid #ced4da;
        }
        .login-card .form-control:focus {
            border-color: #86b7fe;
            outline: 0;
            box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
        }
        .login-card .btn-primary {
            padding: 0.6rem 1.5rem;
            font-size: 1.05rem;
            font-weight: 500;
            border-radius: 50px;
            width: 100%;
            background-color: #6f42c1; /* Match header */
            border: none;
            transition: background-color 0.2s ease;
        }
        .login-card .btn-primary:hover {
            background-color: #5a3e8d; /* Darker purple */
        }
        .login-card .alert {
            margin-bottom: 1.5rem;
        }
        .login-card .extra-links {
            margin-top: 1.5rem;
            font-size: 0.9rem;
        }
        .login-card .extra-links a {
            text-decoration: none;
            font-weight: 500;
        }
        .login-card .extra-links span {
            color: #6c757d;
        }
    </style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Use Guest Navbar View --%>
<%@include file="Components/navbar.jsp"%>

<main class="container login-container flex-grow-1">
    <div class="row w-100 justify-content-center">
        <div class="col-11 col-sm-8 col-md-6 col-lg-5 col-xl-4">
            <div class="card login-card">
                <div class="card-header">
                    <i class="fas fa-store-alt"></i> <%-- Different Store Icon --%>
                    <h3 class="card-title">Vendor Portal Login</h3>
                </div>
                <div class="card-body">

                    <%-- Display Login Error Messages (e.g., invalid, not approved) --%>
                    <%@include file="Components/alert_message.jsp"%>

                    <%-- Login Form --%>
                    <form action="VendorLoginServlet" method="post" id="vendor-login-form" class="needs-validation mt-3" novalidate>
                        <%-- Servlet identifies this is vendor login by the action URL --%>

                        <div class="mb-3">
                            <label for="vendorEmailInput" class="form-label">Login Email</label>
                            <input type="email" class="form-control" id="vendorEmailInput" name="user_email" <%-- Use same name as user login for simplicity? Check servlet --%>
                                   placeholder="Enter your registered email" required autocomplete="email">
                            <div class="invalid-feedback">Please enter your email address.</div>
                        </div>

                        <div class="mb-4">
                            <label for="vendorPasswordInput" class="form-label">Password</label>
                            <input type="password" class="form-control" id="vendorPasswordInput" name="user_password" <%-- Use same name as user login? Check servlet --%>
                                   placeholder="Enter your password" required autocomplete="current-password">
                            <div class="invalid-feedback">Please enter your password.</div>
                        </div>

                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa-solid fa-sign-in-alt"></i> Login as Vendor
                            </button>
                        </div>
                    </form>

                    <div class="mt-4 text-center extra-links">
                        <a href="forgot_password.jsp?userType=vendor" class="d-block mb-2">Forgot Password?</a> <%-- Added userType param --%>
                        <span>Not a vendor yet? </span><a href="vendor_register.jsp">Apply to Sell</a>
                    </div>
                    <div class="mt-2 text-center extra-links">
                        <a href="login.jsp">Login as Customer</a>
                    </div>
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