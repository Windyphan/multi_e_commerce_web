<%-- JSTL Core tag library (Good practice, even if minimally used here) --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Set Error Page and Content Type --%>
<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Admin Login - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f4f7f6; /* Light neutral background */
			display: flex;
			flex-direction: column;
			min-height: 100vh; /* Ensure footer sticks to bottom if added */
		}
		.login-container {
			flex-grow: 1; /* Allow container to grow and push footer down */
			display: flex;
			align-items: center; /* Vertically center the card */
			padding-top: 2rem;
			padding-bottom: 2rem;
		}
		.login-card {
			border: none; /* Remove default border */
			border-radius: 0.75rem; /* More rounded corners */
			box-shadow: 0 5px 25px rgba(0, 0, 0, 0.1); /* Softer, larger shadow */
			overflow: hidden; /* Ensure child elements conform to border-radius */
		}
		.login-card .card-header {
			background-color: #343a40; /* Dark header */
			color: #fff;
			padding: 1.5rem 1rem; /* More padding */
			border-bottom: none; /* Remove bottom border */
			text-align: center;
		}
		.login-card .card-header img {
			max-width: 80px; /* Adjust icon size */
			margin-bottom: 0.75rem;
			background-color: rgba(255,255,255,0.1); /* Subtle background for icon */
			padding: 5px;
			border-radius: 50%;
		}
		.login-card .card-title {
			margin-bottom: 0;
			font-weight: 500;
			font-size: 1.5rem;
		}
		.login-card .card-body {
			padding: 2rem 2.5rem; /* Generous padding */
		}
		.login-card .form-label {
			font-weight: 600; /* Slightly bolder labels */
			margin-bottom: 0.5rem;
			color: #495057;
		}
		.login-card .form-control {
			height: calc(1.5em + 1rem + 2px); /* Taller input fields */
			border-radius: 0.375rem;
			border: 1px solid #ced4da;
			transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
		}
		.login-card .form-control:focus {
			border-color: #86b7fe;
			outline: 0;
			box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
		}
		.login-card .btn-primary {
			padding: 0.6rem 1.5rem; /* Larger button */
			font-size: 1.05rem;
			font-weight: 500;
			border-radius: 50px; /* Pill shape */
			width: 100%; /* Full width button */
			background-color: #0d6efd;
			border: none;
			transition: background-color 0.2s ease;
		}
		.login-card .btn-primary:hover {
			background-color: #0b5ed7;
		}

		/* Style for alert message positioning if needed */
		.login-card .alert {
			margin-top: 1rem;
			margin-bottom: 0; /* Adjust spacing as needed */
		}

	</style>
</head>
<body>
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<div class="container login-container">
	<div class="row w-100 justify-content-center"> <%-- Center the column --%>
		<div class="col-11 col-sm-8 col-md-6 col-lg-5 col-xl-4"> <%-- Responsive column width --%>
			<div class="card login-card">
				<div class="card-header">
					<img src="Images/admin.png" alt="Admin Icon">
					<h3 class="card-title">Admin Login</h3>
				</div>
				<div class="card-body">

					<%-- Display Login Error Messages --%>
					<%@include file="Components/alert_message.jsp"%>

					<%-- Login Form --%>
					<form action="LoginServlet" method="post" id="admin-login-form" class="mt-3">
						<%-- Hidden field to identify login type --%>
						<input type="hidden" name="login" value="admin">

						<div class="mb-3">
							<label for="adminEmailInput" class="form-label">Email Address</label>
							<input type="email" class="form-control" id="adminEmailInput" name="email" placeholder="Enter your email" required autocomplete="email">
						</div>

						<div class="mb-4"> <%-- Increased bottom margin --%>
							<label for="adminPasswordInput" class="form-label">Password</label>
							<input type="password" class="form-control" id="adminPasswordInput" name="password" placeholder="Enter your password" required autocomplete="current-password">
						</div>

						<div class="d-grid"> <%-- Use grid for full-width button --%>
							<button type="submit" class="btn btn-primary">
								<i class="fa-solid fa-sign-in-alt"></i> Login
							</button>
						</div>

						<%-- Optional: Add forgot password link --%>
						<%--
                        <div class="text-center mt-3">
                            <a href="forgot_password.jsp?userType=admin" class="small">Forgot Password?</a>
                        </div>
                        --%>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>

<%-- Footer --%>
 <%@include file="footer.jsp"%>

</body>
</html>