<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Optional: Add errorPage directive --%>
<%-- <%@page errorPage="error_exception.jsp"%> --%>

<%-- No specific Java imports needed directly here unless pre-populating counties --%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Register - Phong Shop</title>
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
			background-color: #198754; /* Success color */
			color: #fff;
			padding: 1.5rem 1rem;
			border-bottom: none;
			text-align: center;
		}
		.register-card .card-header img {
			max-width: 70px; /* Slightly smaller icon */
			margin-bottom: 0.75rem;
		}
		.register-card .card-title {
			margin-bottom: 0;
			font-weight: 500;
			font-size: 1.5rem;
		}
		.register-card .card-body {
			padding: 1.5rem 2rem; /* Adjust padding */
		}
		.register-card .form-label {
			font-weight: 600;
			margin-bottom: 0.5rem;
			color: #495057;
			font-size: 0.95rem; /* Slightly smaller label */
		}
		.register-card .form-control, .register-card .form-select {
			height: calc(1.5em + 0.9rem + 2px); /* Adjusted height */
			border-radius: 0.375rem;
			border: 1px solid #ced4da;
			font-size: 0.95rem; /* Match label */
		}
		.register-card .form-control:focus, .register-card .form-select:focus {
			border-color: #86b7fe;
			outline: 0;
			box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
		}
		.register-card .btn-primary {
			padding: 0.6rem 1.5rem;
			font-size: 1.05rem;
			font-weight: 500;
			border-radius: 50px;
			width: 100%; /* Full width */
			background-color: #0d6efd;
			border: none;
		}
		.register-card .btn-primary:hover {
			background-color: #0b5ed7;
		}
		.register-card .btn-outline-secondary { /* Style reset button */
			padding: 0.6rem 1.5rem;
			font-size: 1.05rem;
			font-weight: 500;
			border-radius: 50px;
			width: 100%;
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
		.gender-options .form-check {
			display: inline-block;
			margin-right: 1.5rem;
		}
		.gender-options .form-check-label {
			font-weight: normal;
			margin-left: 0.25rem;
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<main class="container register-container flex-grow-1">
	<div class="row w-100 justify-content-center">
		<%-- Adjusted column width slightly --%>
		<div class="col-11 col-sm-10 col-md-8 col-lg-7 col-xl-6">
			<div class="card register-card">
				<div class="card-header">
					<i class="fas fa-user-plus fa-3x mb-3"></i>
					<h3 class="card-title">Create Your Account</h3>
				</div>
				<div class="card-body">

					<%-- Display Messages (e.g., registration success/failure) --%>
					<%@include file="Components/alert_message.jsp"%>

					<%-- Registration Form --%>
					<form action="RegisterServlet" method="post" id="register-form" class="needs-validation" novalidate>
						<div class="row">
							<div class="col-md-6 mb-3">
								<label for="regUserName" class="form-label">Your Name</label>
								<input type="text" class="form-control" id="regUserName" name="user_name" placeholder="Enter full name" required>
								<div class="invalid-feedback">Please enter your name.</div>
							</div>
							<div class="col-md-6 mb-3">
								<label for="regUserEmail" class="form-label">Email</label>
								<input type="email" class="form-control" id="regUserEmail" name="user_email" placeholder="Enter email address" required>
								<div class="invalid-feedback">Please enter a valid email.</div>
							</div>
						</div>

						<div class="row align-items-center"> <%-- Align items for gender --%>
							<div class="col-md-6 mb-3">
								<label for="regUserMobile" class="form-label">Mobile Number</label>
								<input type="tel" class="form-control" id="regUserMobile" name="user_mobile_no" placeholder="Enter mobile number" required pattern="[0-9\s\-+()]*">
								<div class="invalid-feedback">Please enter a valid phone number.</div>
							</div>
							<div class="col-md-6 mb-3">
								<label class="form-label d-block mb-2">Gender</label>
								<div class="gender-options">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="gender" id="regGenderMale" value="Male" required>
										<label class="form-check-label" for="regGenderMale">Male</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="gender" id="regGenderFemale" value="Female" required>
										<label class="form-check-label" for="regGenderFemale">Female</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="gender" id="regGenderOther" value="Other" required>
										<label class="form-check-label" for="regGenderOther">Other</label>
									</div>
								</div>
								<div class="invalid-feedback d-block">Please select a gender.</div> <%-- Feedback for radio group --%>
							</div>
						</div>

						<div class="mb-3">
							<label for="regUserAddress" class="form-label">Address (Street, House No)</label>
							<input type="text" class="form-control" id="regUserAddress" name="user_address" placeholder="e.g., 10 Downing Street" required>
							<div class="invalid-feedback">Please enter your street address.</div>
						</div>

						<div class="row">
							<div class="col-md-6 mb-3">
								<label for="regUserCity" class="form-label">Town / City</label>
								<input class="form-control" type="text" name="city" id="regUserCity" placeholder="e.g., London" required>
								<div class="invalid-feedback">Please enter your town/city.</div>
							</div>
							<div class="col-md-6 mb-3">
								<label for="regUserPostcode" class="form-label">Postcode</label>
								<input class="form-control" type="text" name="postcode" <%-- Using 'postcode' as name based on previous context --%>
									   id="regUserPostcode" placeholder="e.g., SW1A 0AA" required
									   pattern="[A-Za-z]{1,2}[0-9Rr][0-9A-Za-z]? [0-9][A-Za-z]{2}"
									   title="Enter a valid UK Postcode (e.g., SW1A 0AA)"
									   maxlength="9">
								<div class="invalid-feedback">Please enter a valid UK postcode.</div>
							</div>
						</div>

						<div class="row">
							<div class="col-md-6 mb-3">
								<label for="regUserCounty" class="form-label">County</label>
								<select name="county" <%-- Using 'county' as name based on previous context --%>
										id="regUserCounty" class="form-select" required>
									<option value="" selected disabled>-- Select County --</option>
									<%-- Static List - Consider loading dynamically if very long --%>
									<optgroup label="England">
										<option value="Avon">Avon</option><option value="Bedfordshire">Bedfordshire</option><option value="Berkshire">Berkshire</option><option value="Buckinghamshire">Buckinghamshire</option><option value="Cambridgeshire">Cambridgeshire</option><option value="Cheshire">Cheshire</option><option value="Cleveland">Cleveland</option><option value="Cornwall">Cornwall</option><option value="Cumbria">Cumbria</option><option value="Derbyshire">Derbyshire</option><option value="Devon">Devon</option><option value="Dorset">Dorset</option><option value="Durham">Durham</option><option value="East Riding of Yorkshire">East Riding of Yorkshire</option><option value="East Sussex">East Sussex</option><option value="Essex">Essex</option><option value="Gloucestershire">Gloucestershire</option><option value="Greater London">Greater London</option><option value="Greater Manchester">Greater Manchester</option><option value="Hampshire">Hampshire</option><option value="Herefordshire">Herefordshire</option><option value="Hertfordshire">Hertfordshire</option><option value="Isle of Wight">Isle of Wight</option><option value="Kent">Kent</option><option value="Lancashire">Lancashire</option><option value="Leicestershire">Leicestershire</option><option value="Lincolnshire">Lincolnshire</option><option value="Merseyside">Merseyside</option><option value="Norfolk">Norfolk</option><option value="North Yorkshire">North Yorkshire</option><option value="Northamptonshire">Northamptonshire</option><option value="Northumberland">Northumberland</option><option value="Nottinghamshire">Nottinghamshire</option><option value="Oxfordshire">Oxfordshire</option><option value="Rutland">Rutland</option><option value="Shropshire">Shropshire</option><option value="Somerset">Somerset</option><option value="South Yorkshire">South Yorkshire</option><option value="Staffordshire">Staffordshire</option><option value="Suffolk">Suffolk</option><option value="Surrey">Surrey</option><option value="Tyne and Wear">Tyne and Wear</option><option value="Warwickshire">Warwickshire</option><option value="West Midlands">West Midlands</option><option value="West Sussex">West Sussex</option><option value="West Yorkshire">West Yorkshire</option><option value="Wiltshire">Wiltshire</option><option value="Worcestershire">Worcestershire</option>
									</optgroup>
									<optgroup label="Scotland">
										<option value="Aberdeenshire">Aberdeenshire</option><option value="Angus">Angus</option><option value="Argyll and Bute">Argyll and Bute</option><option value="Clackmannanshire">Clackmannanshire</option><option value="Dumfries and Galloway">Dumfries and Galloway</option><option value="Dundee">Dundee</option><option value="East Ayrshire">East Ayrshire</option><option value="East Dunbartonshire">East Dunbartonshire</option><option value="East Lothian">East Lothian</option><option value="Edinburgh">Edinburgh</option><option value="Falkirk">Falkirk</option><option value="Fife">Fife</option><option value="Glasgow">Glasgow</option><option value="Highland">Highland</option><option value="Inverclyde">Inverclyde</option><option value="Midlothian">Midlothian</option><option value="Moray">Moray</option><option value="North Ayrshire">North Ayrshire</option><option value="North Lanarkshire">North Lanarkshire</option><option value="Orkney">Orkney</option><option value="Perth and Kinross">Perth and Kinross</option><option value="Renfrewshire">Renfrewshire</option><option value="Scottish Borders">Scottish Borders</option><option value="Shetland">Shetland</option><option value="South Ayrshire">South Ayrshire</option><option value="South Lanarkshire">South Lanarkshire</option><option value="Stirling">Stirling</option><option value="West Dunbartonshire">West Dunbartonshire</option><option value="West Lothian">West Lothian</option>
									</optgroup>
									<optgroup label="Wales">
										<option value="Anglesey">Anglesey</option><option value="Blaenau Gwent">Blaenau Gwent</option><option value="Bridgend">Bridgend</option><option value="Caerphilly">Caerphilly</option><option value="Cardiff">Cardiff</option><option value="Carmarthenshire">Carmarthenshire</option><option value="Ceredigion">Ceredigion</option><option value="Conwy">Conwy</option><option value="Denbighshire">Denbighshire</option><option value="Flintshire">Flintshire</option><option value="Gwynedd">Gwynedd</option><option value="Merthyr Tydfil">Merthyr Tydfil</option><option value="Monmouthshire">Monmouthshire</option><option value="Neath Port Talbot">Neath Port Talbot</option><option value="Newport">Newport</option><option value="Pembrokeshire">Pembrokeshire</option><option value="Powys">Powys</option><option value="Rhondda Cynon Taf">Rhondda Cynon Taf</option><option value="Swansea">Swansea</option><option value="Torfaen">Torfaen</option><option value="Vale of Glamorgan">Vale of Glamorgan</option><option value="Wrexham">Wrexham</option>
									</optgroup>
									<optgroup label="Northern Ireland">
										<option value="Antrim">Antrim</option><option value="Armagh">Armagh</option><option value="Down">Down</option><option value="Fermanagh">Fermanagh</option><option value="Londonderry">Londonderry</option><option value="Tyrone">Tyrone</option>
									</optgroup>
								</select>
								<div class="invalid-feedback">Please select your county.</div>
							</div>
							<div class="col-md-6 mb-3">
								<label for="regUserPassword" class="form-label">Password</label>
								<input type="password" class="form-control" id="regUserPassword" name="user_password"
									   placeholder="Create a password" required minlength="8"
									   pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}"
									   title="Must contain at least one number, one uppercase and lowercase letter, and at least 8 characters">
								<div class="invalid-feedback">Password must meet complexity requirements (see title).</div>
							</div>
						</div>


						<div class="d-grid gap-2 mt-4"> <%-- Use grid for button sizing --%>
							<button type="submit" class="btn btn-primary">
								<i class="fa-solid fa-user-plus"></i> Create Account
							</button>
							<%-- Maybe remove reset button? Often causes more harm than good.
                            <button type="reset" class="btn btn-outline-secondary">Reset Form</button>
                            --%>
						</div>

						<div class="mt-3 text-center extra-links">
							<span>Already have an account? </span><a href="login.jsp">Sign in</a>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</main>

<%-- Footer --%>
<%@include file="Components/footer.jsp"%>

<script>
	// Bootstrap validation script
	(() => {
		'use strict'
		const forms = document.querySelectorAll('.needs-validation')
		Array.from(forms).forEach(form => {
			form.addEventListener('submit', event => {
				// Extra check: Ensure at least one gender radio is checked
				const genderRadios = form.querySelectorAll('input[name="gender"]');
				let genderChecked = false;
				genderRadios.forEach(radio => {
					if(radio.checked) genderChecked = true;
				});
				if (!genderChecked) {
					// Optionally add a visual cue near the gender section
					console.log("Gender not selected");
				}

				if (!form.checkValidity() || !genderChecked) {
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