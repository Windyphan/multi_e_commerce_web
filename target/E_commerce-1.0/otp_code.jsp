<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Optional: Add errorPage directive --%>
<%-- <%@page errorPage="error_exception.jsp"%> --%>

<%--
    SECURITY CHECK: Ensure user arrived here legitimately via the forgot password process.
    Check for the presence of the 'otp' and 'email' attributes.
    Redirect if missing.
--%>
<c:if test="${empty sessionScope.otp or empty sessionScope.email}">
	<%-- Don't set an error message here usually, just redirect silently --%>
	<%-- User might have refreshed or bookmarked this page --%>
	<c:redirect url="forgot_password.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Enter Verification Code - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f4f7f6;
			display: flex;
			flex-direction: column;
			min-height: 100vh;
		}
		.otp-container {
			flex-grow: 1;
			display: flex;
			align-items: center;
			padding-top: 2rem;
			padding-bottom: 2rem;
		}
		.otp-card {
			border: none;
			border-radius: 0.75rem;
			box-shadow: 0 5px 25px rgba(0, 0, 0, 0.1);
			overflow: hidden;
		}
		.otp-card .card-header {
			background-color: #0dcaf0; /* Info color */
			color: #fff;
			padding: 1.5rem 1rem;
			border-bottom: none;
			text-align: center;
		}
		.otp-card .card-header img {
			max-width: 80px;
			margin-bottom: 0.75rem;
		}
		.otp-card .card-title {
			margin-bottom: 0;
			font-weight: 500;
			font-size: 1.5rem;
		}
		.otp-card .card-body {
			padding: 2rem 2.5rem;
		}
		.otp-card .card-text {
			font-size: 0.95rem;
			color: #6c757d;
			margin-bottom: 1.5rem;
			text-align: center;
		}
		.otp-card .form-label {
			font-weight: 600;
			margin-bottom: 0.5rem;
			color: #495057;
		}
		.otp-card .form-control {
			height: calc(1.5em + 1rem + 2px);
			border-radius: 0.375rem;
			border: 1px solid #ced4da;
			text-align: center; /* Center OTP input */
			font-size: 1.1rem; /* Larger font for code */
			letter-spacing: 0.2em; /* Space out digits slightly */
		}
		.otp-card .form-control:focus {
			border-color: #86b7fe;
			outline: 0;
			box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
		}
		.otp-card .btn-primary {
			padding: 0.6rem 1.5rem;
			font-size: 1.05rem;
			font-weight: 500;
			border-radius: 50px;
			width: 100%;
			background-color: #0d6efd;
			border: none;
		}
		.otp-card .btn-primary:hover {
			background-color: #0b5ed7;
		}
		.otp-card .alert {
			margin-bottom: 1.5rem;
		}
		.otp-card .back-link {
			margin-top: 1.5rem;
			font-size: 0.9rem;
		}

	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<main class="container otp-container flex-grow-1">
	<div class="row w-100 justify-content-center">
		<div class="col-11 col-sm-8 col-md-6 col-lg-5 col-xl-4">
			<div class="card otp-card">
				<div class="card-header">
					<img src="Images/forgot-password.png" alt="Verification Icon">
					<h3 class="card-title">Enter Verification Code</h3>
				</div>
				<div class="card-body">

					<p class="card-text">
						Please check your email for a 5-digit verification code sent to
						<%-- Mask the email slightly for privacy --%>
						<c:set var="email" value="${sessionScope.email}"/>
						<c:set var="emailParts" value="${email.split('@')}"/>
						<c:set var="userPart" value="${emailParts[0]}"/>
						<c:set var="domainPart" value="${emailParts[1]}"/>
						<c:out value="${userPart.substring(0, 2)}"/>***<c:out value="${userPart.substring(userPart.length() - 1)}"/>@<c:out value="${domainPart}"/>
					</p>

					<%-- Display Messages (e.g., "Invalid code") --%>
					<%@include file="Components/alert_message.jsp"%>

					<%-- OTP Form --%>
					<form action="ChangePasswordServlet" method="post" class="needs-validation" novalidate>
						<%-- Servlet identifies this stage by referrer or presence of 'code' param --%>

						<div class="mb-4"> <%-- More bottom margin --%>
							<label for="otpCodeInput" class="form-label">Verification Code</label>
							<input type="text" <%-- Use text to allow leading zeros easily --%>
								   class="form-control" id="otpCodeInput" name="code"
								   placeholder="Enter 5-digit code" required
								   maxlength="5" <%-- Limit length --%>
								   pattern="[0-9]{5}" <%-- Basic pattern for 5 digits --%>
								   inputmode="numeric" <%-- Hint for numeric keyboard on mobile --%>
								   autocomplete="one-time-code">
							<div class="invalid-feedback">
								Please enter the 5-digit code sent to your email.
							</div>
						</div>

						<div class="d-grid">
							<button type="submit" class="btn btn-primary">
								<i class="fa-solid fa-check"></i> Verify Code
							</button>
						</div>
					</form>

					<div class="text-center back-link">
						<a href="forgot_password.jsp"><i class="fa-solid fa-arrow-left"></i> Didn't get a code?</a>
					</div>
				</div>
			</div>
		</div>
	</div>
</main>

<%-- Footer --%>
<%@include file="Components/footer.jsp"%>

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