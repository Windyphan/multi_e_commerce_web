<%-- JSTL Core tag library --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Set Error Page and Content Type --%>
<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%--
    SECURITY CHECK: Ensure user arrived here legitimately via OTP process.
    Check for the presence of the 'email' attribute set during OTP verification.
    Redirect if missing.
--%>
<c:if test="${empty sessionScope.email}">
	<c:set var="errorMessage" value="Invalid password reset sequence. Please start over." scope="session"/>
	<c:set var="errorType" value="error" scope="session"/>
	<c:set var="errorClass" value="alert-danger" scope="session"/>
	<c:redirect url="forgot_password.jsp"/>
	<%-- Use c:redirect; no 'return' needed --%>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Create New Password - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f4f7f6; /* Light neutral background */
			display: flex;
			flex-direction: column;
			min-height: 100vh;
		}
		.reset-container {
			flex-grow: 1;
			display: flex;
			align-items: center;
			padding-top: 2rem;
			padding-bottom: 2rem;
		}
		.reset-card {
			border: none;
			border-radius: 0.75rem;
			box-shadow: 0 5px 25px rgba(0, 0, 0, 0.1);
			overflow: hidden;
		}
		.reset-card .card-header {
			/* Use a slightly different header style if desired */
			background-color: #0dcaf0; /* Info color variant */
			color: #fff;
			padding: 1.5rem 1rem;
			border-bottom: none;
			text-align: center;
		}
		.reset-card .card-header img {
			max-width: 80px;
			margin-bottom: 0.75rem;
			/* Optional styling */
		}
		.reset-card .card-title {
			margin-bottom: 0;
			font-weight: 500;
			font-size: 1.5rem;
		}
		.reset-card .card-body {
			padding: 2rem 2.5rem;
		}
		.reset-card .form-label {
			font-weight: 600;
			margin-bottom: 0.5rem;
			color: #495057;
		}
		.reset-card .form-control {
			height: calc(1.5em + 1rem + 2px);
			border-radius: 0.375rem;
			border: 1px solid #ced4da;
			transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
		}
		.reset-card .form-control:focus {
			border-color: #86b7fe;
			outline: 0;
			box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
		}
		.reset-card .btn-primary {
			padding: 0.6rem 1.5rem;
			font-size: 1.05rem;
			font-weight: 500;
			border-radius: 50px;
			width: 100%;
			background-color: #0d6efd;
			border: none;
			transition: background-color 0.2s ease;
		}
		.reset-card .btn-primary:hover {
			background-color: #0b5ed7;
		}
		.reset-card .alert {
			margin-top: 1rem;
			margin-bottom: 0;
		}
		/* Password validation feedback styling */
		input:invalid {
			border-color: #dc3545; /* Red border for invalid state */
		}
		input:focus:invalid {
			box-shadow: 0 0 0 0.25rem rgba(220, 53, 69, 0.25);
		}
		.invalid-feedback { /* Style for potential future JS feedback */
			display: none; /* Hide by default */
			width: 100%;
			margin-top: 0.25rem;
			font-size: .875em;
			color: #dc3545;
		}
		input:invalid ~ .invalid-feedback,
		input.is-invalid ~ .invalid-feedback {
			display: block; /* Show feedback when input is invalid */
		}

	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<div class="container reset-container">
	<div class="row w-100 justify-content-center">
		<div class="col-11 col-sm-8 col-md-6 col-lg-5 col-xl-4">
			<div class="card reset-card">
				<div class="card-header">
					<%-- Changed icon slightly --%>
					<img src="Images/forgot-password.png" alt="Password Reset Icon">
					<h3 class="card-title">Create New Password</h3>
				</div>
				<div class="card-body">

					<%-- Display Messages (e.g., if validation fails server-side, though unlikely here) --%>
					<%@include file="Components/alert_message.jsp"%>

					<%-- Password Reset Form --%>
					<form action="ChangePasswordServlet" method="post" id="changePasswordForm" class="mt-3 needs-validation" novalidate>
						<%-- operation parameter might not be needed if servlet only does one thing --%>
						<%-- <input type="hidden" name="operation" value="changePassword"> --%>

						<div class="mb-3">
							<label for="password" class="form-label">New Password</label>
							<%-- Added pattern for basic complexity, adjust as needed --%>
							<input type="password" class="form-control" id="password" name="password"
								   placeholder="Enter new password" required
								   minlength="8" <%-- Example minimum length --%>
								   pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}" <%-- Example: digit, lower, upper, 8+ chars --%>
								   title="Must contain at least one number, one uppercase and lowercase letter, and at least 8 characters">
							<div class="invalid-feedback">
								Please enter a valid password (min. 8 chars, incl. number, uppercase, lowercase).
							</div>
						</div>

						<div class="mb-4">
							<label for="confirm_password" class="form-label">Confirm New Password</label>
							<input type="password" class="form-control" id="confirm_password" name="confirm_password" <%-- Ensure name matches servlet --%>
								   placeholder="Confirm new password" required>
							<div class="invalid-feedback" id="confirmPasswordFeedback">
								Passwords do not match.
							</div>
						</div>

						<div class="d-grid">
							<button type="submit" class="btn btn-primary">
								<i class="fa-solid fa-key"></i> Update Password
							</button>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>

<%-- Footer --%>
 <%@include file="footer.jsp"%>

<script type="text/javascript">
	const passwordInput = document.getElementById("password");
	const confirmPasswordInput = document.getElementById("confirm_password");
	const confirmPasswordFeedback = document.getElementById("confirmPasswordFeedback");
	const form = document.getElementById('changePasswordForm');

	function validatePasswords() {
		if (passwordInput.value !== confirmPasswordInput.value) {
			confirmPasswordInput.setCustomValidity("Passwords do not match.");
			// Optionally show visual feedback immediately
			confirmPasswordInput.classList.add('is-invalid');
			confirmPasswordFeedback.style.display = 'block'; // Show custom feedback message
			return false;
		} else {
			confirmPasswordInput.setCustomValidity("");
			confirmPasswordInput.classList.remove('is-invalid');
			confirmPasswordFeedback.style.display = 'none'; // Hide custom feedback message
			return true;
		}
	}

	// Validate on input in confirm field for immediate feedback
	confirmPasswordInput.addEventListener('input', validatePasswords);

	// Also validate on password field input (in case user changes it after confirming)
	passwordInput.addEventListener('input', () => {
		// Re-validate confirm password only if it has content
		if (confirmPasswordInput.value) {
			validatePasswords();
		}
	});


	// Optional: Use Bootstrap's built-in validation feedback on submit
	// This works well with the `required` attribute and the CSS classes
	form.addEventListener('submit', event => {
		// First validate password match
		if (!validatePasswords()) {
			event.preventDefault(); // Prevent submission if passwords don't match
			event.stopPropagation();
			confirmPasswordInput.focus(); // Focus the problematic field
			return; // Stop here
		}

		// Then check overall form validity (including required, pattern, minlength)
		if (!form.checkValidity()) {
			event.preventDefault();
			event.stopPropagation();
		}

		form.classList.add('was-validated'); // Add Bootstrap class to show validation styles
	}, false);

</script>
</body>
</html>