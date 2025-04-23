<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- No errorPage needed typically, but can add if desired --%>
<%-- <%@page errorPage="error_exception.jsp"%> --%>

<%-- No Java imports needed directly on this page if using JSTL --%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Forgot Password - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f4f7f6; /* Light neutral background */
			display: flex;
			flex-direction: column;
			min-height: 100vh;
		}
		.forgot-container {
			flex-grow: 1;
			display: flex;
			align-items: center;
			padding-top: 2rem;
			padding-bottom: 2rem;
		}
		.forgot-card {
			border: none;
			border-radius: 0.75rem;
			box-shadow: 0 5px 25px rgba(0, 0, 0, 0.1);
			overflow: hidden;
		}
		.forgot-card .card-header {
			background-color: #ffc107; /* Warning color */
			color: #333; /* Dark text on yellow */
			padding: 1.5rem 1rem;
			border-bottom: none;
			text-align: center;
		}
		.forgot-card .card-header img {
			max-width: 80px;
			margin-bottom: 0.75rem;
		}
		.forgot-card .card-title {
			margin-bottom: 0;
			font-weight: 500;
			font-size: 1.5rem;
		}
		.forgot-card .card-body {
			padding: 2rem 2.5rem;
		}
		.forgot-card .card-text {
			font-size: 0.95rem;
			color: #6c757d; /* Muted text color */
			margin-bottom: 1.5rem;
			text-align: center;
		}
		.forgot-card .form-label {
			font-weight: 600;
			margin-bottom: 0.5rem;
			color: #495057;
		}
		.forgot-card .form-control {
			height: calc(1.5em + 1rem + 2px);
			border-radius: 0.375rem;
			border: 1px solid #ced4da;
		}
		.forgot-card .form-control:focus {
			border-color: #86b7fe;
			outline: 0;
			box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
		}
		.forgot-card .btn-primary {
			padding: 0.6rem 1.5rem;
			font-size: 1.05rem;
			font-weight: 500;
			border-radius: 50px;
			width: 100%;
			background-color: #0d6efd;
			border: none;
		}
		.forgot-card .btn-primary:hover {
			background-color: #0b5ed7;
		}
		.forgot-card .alert {
			margin-bottom: 1.5rem; /* Space above form */
		}
		.forgot-card .back-link {
			margin-top: 1.5rem;
			font-size: 0.9rem;
		}

	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<main class="container forgot-container flex-grow-1">
	<div class="row w-100 justify-content-center">
		<div class="col-11 col-sm-8 col-md-6 col-lg-5 col-xl-4">
			<div class="card forgot-card">
				<div class="card-header">
					<img src="Images/forgot-password.png" alt="Forgot Password Icon">
					<h3 class="card-title">Forgot Your Password?</h3>
				</div>
				<div class="card-body">

					<p class="card-text">
						Enter your email address below and we'll send you a code to reset your password.
					</p>

					<%-- Display Messages (e.g., "Email not found") --%>
					<%@include file="Components/alert_message.jsp"%>

					<%-- Email Form --%>
					<form action="ChangePasswordServlet" method="post" class="needs-validation" novalidate>
						<%-- No hidden operation needed if servlet logic checks referrer --%>

						<div class="mb-4"> <%-- More bottom margin --%>
							<label for="emailInput" class="form-label">Email Address</label>
							<input type="email" class="form-control" id="emailInput" name="email"
								   placeholder="Enter your registered email" required
								   autocomplete="email">
							<div class="invalid-feedback">
								Please enter a valid email address.
							</div>
						</div>

						<div class="d-grid">
							<button type="submit" class="btn btn-primary">
								<i class="fa-solid fa-paper-plane"></i> Send Reset Code
							</button>
						</div>
					</form>

					<div class="text-center back-link">
						<a href="login.jsp"><i class="fa-solid fa-arrow-left"></i> Back to Login</a>
					</div>

				</div>
			</div>
		</div>
	</div>
</main>

<%-- Footer --%>
<%@include file="footer.jsp"%>

<script>
	// Optional: Add Bootstrap validation script if not already global
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