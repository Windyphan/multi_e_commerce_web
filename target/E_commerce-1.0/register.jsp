<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Registration</title>
<%@include file="Components/common_css_js.jsp"%>
<style>
label {
	font-weight: bold;
}
</style>
</head>
<body>
	<!--navbar -->
	<%@include file="Components/navbar.jsp"%>

	<div class="container-fluid mt-4">
		<div class="row g-0">
			<div class="col-md-6 offset-md-3">
				<div class="card">
					<div class="card-body px-5">

						<div class="container text-center">
							<img src="Images/signUp.png" style="max-width: 80px;"
								class="img-fluid">
						</div>
						<h3 class="text-center">Create Account</h3>
						<%@include file="Components/alert_message.jsp"%>

						<!--registration-form-->
						<form id="register-form" action="RegisterServlet" method="post">
							<div class="row">
								<div class="col-md-6 mt-2">
									<label class="form-label">Your name</label> <input type="text"
										name="user_name" class="form-control"
										placeholder="First and last name" required>
								</div>
								<div class="col-md-6 mt-2">
									<label class="form-label">Email</label> <input type="email"
										name="user_email" placeholder="Email address"
										class="form-control" required>
								</div>
							</div>
							<div class="row">
								<div class="col-md-6 mt-2">
									<label class="form-label">Mobile number</label> <input
										type="number" name="user_mobile_no"
										placeholder="Mobile number" class="form-control">
								</div>
								<div class="col-md-6 mt-5">
									<label class="form-label pe-3">Gender</label> <input
										class="form-check-input" type="radio" name="gender"
										value="Male"> <span class="form-check-label pe-3 ps-1">
										Male </span> <input class="form-check-input" type="radio"
										name="gender" value="Female"> <span
										class="form-check-label ps-1"> Female </span>
								</div>
							</div>
							<div class="mt-2">
								<label class="form-label">Address</label> <input type="text"
									name="user_address"
									placeholder="Enter Address(Area and Street))"
									class="form-control" required>
							</div>  
							<div class="row">
								<div class="col-md-6 mt-2">
									<label class="form-label">City</label> <input
										class="form-control" type="text" name="city"
										placeholder="City/District/Town" required>
								</div>
								<div class="col-md-6 mt-2">
									<label class="form-label">Postcode</label> <input
										class="form-control" type="number" name="pincode"
										placeholder="Postcode" maxlength="6" required>
								</div>  
							</div>
							<div class="row">
								<div class="col-md-6 mt-2">
									<label class="form-label">County</label>
									<select name="county" class="form-select">
										<option selected>--Select County--</option>
										<optgroup label="England">
											<option value="Bedfordshire">Bedfordshire</option>
											<option value="Berkshire">Berkshire</option>
											<option value="Bristol">Bristol</option>
											<option value="Buckinghamshire">Buckinghamshire</option>
											<option value="Cambridgeshire">Cambridgeshire</option>
											<option value="Cheshire">Cheshire</option>
											<option value="Cornwall">Cornwall</option>
											<option value="Cumbria">Cumbria</option>
											<option value="Derbyshire">Derbyshire</option>
											<option value="Devon">Devon</option>
											<option value="Dorset">Dorset</option>
											<option value="Durham">Durham</option>
											<option value="East Riding of Yorkshire">East Riding of Yorkshire</option>
											<option value="East Sussex">East Sussex</option>
											<option value="Essex">Essex</option>
											<option value="Gloucestershire">Gloucestershire</option>
											<option value="Greater London">Greater London</option>
											<option value="Greater Manchester">Greater Manchester</option>
											<option value="Hampshire">Hampshire</option>
											<option value="Herefordshire">Herefordshire</option>
											<option value="Hertfordshire">Hertfordshire</option>
											<option value="Isle of Wight">Isle of Wight</option>
											<option value="Kent">Kent</option>
											<option value="Lancashire">Lancashire</option>
											<option value="Leicestershire">Leicestershire</option>
											<option value="Lincolnshire">Lincolnshire</option>
											<option value="Merseyside">Merseyside</option>
											<option value="Norfolk">Norfolk</option>
											<option value="North Yorkshire">North Yorkshire</option>
											<option value="Northamptonshire">Northamptonshire</option>
											<option value="Northumberland">Northumberland</option>
											<option value="Nottinghamshire">Nottinghamshire</option>
											<option value="Oxfordshire">Oxfordshire</option>
											<option value="Rutland">Rutland</option>
											<option value="Shropshire">Shropshire</option>
											<option value="Somerset">Somerset</option>
											<option value="South Yorkshire">South Yorkshire</option>
											<option value="Staffordshire">Staffordshire</option>
											<option value="Suffolk">Suffolk</option>
											<option value="Surrey">Surrey</option>
											<option value="Tyne and Wear">Tyne and Wear</option>
											<option value="Warwickshire">Warwickshire</option>
											<option value="West Midlands">West Midlands</option>
											<option value="West Sussex">West Sussex</option>
											<option value="West Yorkshire">West Yorkshire</option>
											<option value="Wiltshire">Wiltshire</option>
											<option value="Worcestershire">Worcestershire</option>


										</optgroup>
										<optgroup label="Scotland">
											<option value="Aberdeenshire">Aberdeenshire</option>
											<option value="Angus">Angus</option>
											<option value="Argyll and Bute">Argyll and Bute</option>
											<option value="Clackmannanshire">Clackmannanshire</option>
											<option value="Dumfries and Galloway">Dumfries and Galloway</option>
											<option value="Dundee">Dundee</option>
											<option value="East Ayrshire">East Ayrshire</option>
											<option value="East Dunbartonshire">East Dunbartonshire</option>
											<option value="East Lothian">East Lothian</option>
											<option value="Edinburgh">Edinburgh</option>
											<option value="Falkirk">Falkirk</option>
											<option value="Fife">Fife</option>
											<option value="Glasgow">Glasgow</option>
											<option value="Highland">Highland</option>
											<option value="Inverclyde">Inverclyde</option>
											<option value="Midlothian">Midlothian</option>
											<option value="Moray">Moray</option>
											<option value="North Ayrshire">North Ayrshire</option>
											<option value="North Lanarkshire">North Lanarkshire</option>
											<option value="Orkney">Orkney</option>
											<option value="Perth and Kinross">Perth and Kinross</option>
											<option value="Renfrewshire">Renfrewshire</option>
											<option value="Scottish Borders">Scottish Borders</option>
											<option value="Shetland">Shetland</option>
											<option value="South Ayrshire">South Ayrshire</option>
											<option value="South Lanarkshire">South Lanarkshire</option>
											<option value="Stirling">Stirling</option>
											<option value="West Dunbartonshire">West Dunbartonshire</option>
											<option value="West Lothian">West Lothian</option>

										</optgroup>
										<optgroup label="Wales">
											<option value="Anglesey">Anglesey</option>
											<option value="Blaenau Gwent">Blaenau Gwent</option>
											<option value="Bridgend">Bridgend</option>
											<option value="Caerphilly">Caerphilly</option>
											<option value="Cardiff">Cardiff</option>
											<option value="Carmarthenshire">Carmarthenshire</option>
											<option value="Ceredigion">Ceredigion</option>
											<option value="Conwy">Conwy</option>
											<option value="Denbighshire">Denbighshire</option>
											<option value="Flintshire">Flintshire</option>
											<option value="Gwynedd">Gwynedd</option>
											<option value="Merthyr Tydfil">Merthyr Tydfil</option>
											<option value="Monmouthshire">Monmouthshire</option>
											<option value="Neath Port Talbot">Neath Port Talbot</option>
											<option value="Newport">Newport</option>
											<option value="Pembrokeshire">Pembrokeshire</option>
											<option value="Powys">Powys</option>
											<option value="Rhondda Cynon Taf">Rhondda Cynon Taf</option>
											<option value="Swansea">Swansea</option>
											<option value="Torfaen">Torfaen</option>
											<option value="Vale of Glamorgan">Vale of Glamorgan</option>
											<option value="Wrexham">Wrexham</option>
										</optgroup>
										<optgroup label="Northern Ireland">
											<option value="Antrim">Antrim</option>
											<option value="Armagh">Armagh</option>
											<option value="Down">Down</option>
											<option value="Fermanagh">Fermanagh</option>
											<option value="Londonderry">Londonderry</option>
											<option value="Tyrone">Tyrone</option>
										</optgroup>
									</select>
								</div>
								<div class="col-md-6 mt-2">
									<label class="form-label">Password</label> <input
										type="password" name="user_password"
										placeholder="Enter Password" class="form-control" required>
								</div>
							</div>

							<div id="submit-btn" class="container text-center mt-4">
								<button type="submit" class="btn btn-outline-primary me-3">Submit</button>
								<button type="reset" class="btn btn-outline-primary">Reset</button>
							</div>
							<div class="mt-3 text-center">
								<h6>
									Already have an account?<a href="login.jsp"
										style="text-decoration: none"> Sign in</a>
								</h6>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>

</body>
</html>