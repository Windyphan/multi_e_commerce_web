<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@page import="com.phong.entities.User"%> <%-- Keep for session check --%>

<%-- Security Check (already done in provided snippet, kept for context) --%>
<%
	User currentUserForInfo = (User) session.getAttribute("activeUser");
	if (currentUserForInfo == null) {
		// Use JSTL for setting session attributes and redirecting
		pageContext.setAttribute("errorMessage", "You are not logged in! Login first!!", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		response.sendRedirect("login.jsp");
		return;
	}
%>

<%-- Assume ukCountiesList is set as a request attribute earlier on the page --%>

<style>
	/* Reuse styles from other forms or define specific ones */
	.profile-form .form-label {
		font-weight: 600;
		margin-bottom: 0.5rem;
		color: #495057;
	}
	.profile-form .form-control, .profile-form .form-select {
		border-radius: 0.375rem;
		border: 1px solid #ced4da;
	}
	.profile-form .form-control:focus, .profile-form .form-select:focus {
		border-color: #86b7fe;
		outline: 0;
		box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
	}
	.gender-options .form-check {
		display: inline-block; /* Display radio buttons horizontally */
		margin-right: 1.5rem;
	}
	.gender-options .form-check-label {
		font-weight: normal; /* Normal weight for radio labels */
		margin-left: 0.25rem;
	}
	.profile-form .btn {
		padding: 0.5rem 1.2rem;
		font-weight: 500;
	}
</style>

<div class="container px-0 px-md-3 py-3 profile-form"> <%-- Reduced horizontal padding on small screens --%>
	<h3 class="mb-4">Personal Information</h3>
	<%-- Point form to the correct servlet --%>
	<form id="update-user-form" action="UpdateUserServlet" method="post" class="needs-validation" novalidate>
		<input type="hidden" name="operation" value="updateUser">

		<div class="row">
			<div class="col-md-6 mb-3">
				<label for="userNameInput" class="form-label">Your name</label>
				<input type="text" class="form-control" id="userNameInput" name="name"
					   placeholder="First and last name" required
					   value="<c:out value='${sessionScope.activeUser.userName}'/>">
				<div class="invalid-feedback">Please enter your name.</div>
			</div>
			<div class="col-md-6 mb-3">
				<label for="userEmailInput" class="form-label">Email</label>
				<%-- Consider making email read-only if changing email requires verification --%>
				<input type="email" class="form-control" id="userEmailInput" name="email"
					   placeholder="Email address" required
					   value="<c:out value='${sessionScope.activeUser.userEmail}'/>">
				<div class="invalid-feedback">Please enter a valid email address.</div>
			</div>
		</div>

		<div class="row align-items-center"> <%-- Align items vertically --%>
			<div class="col-md-6 mb-3">
				<label for="userMobileInput" class="form-label">Mobile number</label>
				<input type="tel" class="form-control" id="userMobileInput" name="mobile_no"
					   placeholder="Enter mobile number" required pattern="[0-9\s\-+()]*"
					   title="Enter a valid phone number"
					   value="<c:out value='${sessionScope.activeUser.userPhone}'/>">
				<div class="invalid-feedback">Please enter a valid phone number.</div>
			</div>
			<div class="col-md-6 mb-3">
				<label class="form-label d-block mb-2">Gender</label> <%-- Use d-block for spacing --%>
				<div class="gender-options">
					<%-- Use JSTL choose/when/otherwise to check the gender --%>
					<div class="form-check form-check-inline">
						<input class="form-check-input" type="radio" name="gender" id="genderMale" value="Male"
							   <c:if test="${sessionScope.activeUser.userGender == 'Male'}">checked</c:if> required>
						<label class="form-check-label" for="genderMale">Male</label>
					</div>
					<div class="form-check form-check-inline">
						<input class="form-check-input" type="radio" name="gender" id="genderFemale" value="Female"
							   <c:if test="${sessionScope.activeUser.userGender == 'Female'}">checked</c:if> required>
						<label class="form-check-label" for="genderFemale">Female</label>
					</div>
					<div class="form-check form-check-inline">
						<input class="form-check-input" type="radio" name="gender" id="genderOther" value="Other"
							   <c:if test="${sessionScope.activeUser.userGender != 'Male' && sessionScope.activeUser.userGender != 'Female'}">checked</c:if> required>
						<label class="form-check-label" for="genderOther">Other</label>
					</div>
				</div>
			</div>
		</div>

		<div class="mb-3">
			<label for="userAddressInput" class="form-label">Address (Street, House No)</label>
			<%-- Assumes field name is userAddress --%>
			<input type="text" class="form-control" id="userAddressInput" name="address"
				   placeholder="e.g., 10 Downing Street" required
				   value="<c:out value='${sessionScope.activeUser.userAddress}'/>">
			<div class="invalid-feedback">Please enter your street address.</div>
		</div>

		<div class="row">
			<div class="col-md-6 mb-3">
				<label for="cityInput" class="form-label">Town / City</label>
				<%-- Assumes field name is userCity --%>
				<input class="form-control" type="text" name="city" id="cityInput"
					   placeholder="e.g., London" required
					   value="<c:out value='${sessionScope.activeUser.userCity}'/>">
				<div class="invalid-feedback">Please enter your town/city.</div>
			</div>
			<div class="col-md-6 mb-3">
				<label for="postcodeInput" class="form-label">Postcode</label>
				<%-- Assumes field name is userPostcode & form field name is postcode --%>
				<input class="form-control" type="text" name="postcode" id="postcodeInput"
					   placeholder="e.g., SW1A 0AA" required
					   pattern="[A-Za-z]{1,2}[0-9Rr][0-9A-Za-z]? [0-9][A-Za-z]{2}"
					   title="Enter a valid UK Postcode (e.g., SW1A 0AA)"
					   maxlength="9"
					   value="<c:out value='${sessionScope.activeUser.userPostcode}'/>">
				<div class="invalid-feedback">Please enter a valid UK postcode.</div>
			</div>
		</div>

		<div class="mb-4"> <%-- More bottom margin before buttons --%>
			<label for="countySelect" class="form-label">County</label>
			<%-- Assumes field name is userCounty & form field name is county --%>
			<select name="county" id="countySelect" class="form-select" required>
				<option value="" disabled ${empty sessionScope.activeUser.userCounty ? 'selected' : ''}>-- Select County --</option>
				<%-- Loop through counties prepared earlier --%>
				<c:forEach var="county" items="${ukCountiesList}">
					<option value="${county}" ${sessionScope.activeUser.userCounty == county ? 'selected' : ''}>${county}</option>
				</c:forEach>
			</select>
			<div class="invalid-feedback">Please select your county.</div>
		</div>

		<div class="container text-center mt-4">
			<button type="submit" class="btn btn-primary me-2">
				<i class="fa-solid fa-save"></i> Update Profile
			</button>
			<button type="reset" class="btn btn-outline-secondary">
				<i class="fa-solid fa-times"></i> Reset Changes
			</button>
		</div>
	</form>
</div>

<script>
	// Include the Bootstrap validation script here or ensure it runs globally
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