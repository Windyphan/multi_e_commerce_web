<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.entities.User"%> <%-- Still need User for type casting below --%>
<%@page import="com.phong.entities.Message"%> <%-- For potential error messages --%>
<%@page import="com.phong.entities.Product"%> <%-- For product list --%>
<%@page import="com.phong.dao.ProductDao"%> <%-- Needed for buy now price lookup (fallback) --%>
<%@page import="java.util.Collections"%> <%-- For state list example --%>
<%@page import="java.util.Arrays"%> <%-- For state list example --%>
<%@page import="java.util.List"%> <%-- For state list example --%>


<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check & Initial Data Setup --%>
<%
	User currentUserForCheckout = (User) session.getAttribute("activeUser"); // Keep this for direct access if needed
	if (currentUserForCheckout == null) {
		pageContext.setAttribute("errorMessage", "You are not logged in! Login first!!", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		response.sendRedirect("login.jsp");
		return;
	}

	// Fetch 'from' attribute
	String fromAttr = (String) session.getAttribute("from");
	request.setAttribute("orderSource", fromAttr); // Make available to EL

	// Prepare price details based on source - Default to 0 if session attributes missing
	float itemTotalPrice = 0;
	int itemCount = 0;
	float deliveryCharge = 4.99f; // Make these configurable if possible
	float packagingCharge = 1.49f;

	if ("cart".equals(fromAttr)) {
		Float totalPriceFromSession = (Float) session.getAttribute("totalPrice");
		itemTotalPrice = (totalPriceFromSession != null) ? totalPriceFromSession : 0;
		// Get item count - assuming navbar might have set it? Or fetch again if needed.
		Integer cartCountFromSession = (Integer) request.getAttribute("navbarCartCount"); // Check if navbar set it
		if (cartCountFromSession != null) {
			itemCount = cartCountFromSession;
		} else {
			// Fallback: Fetch again (less efficient)
			// com.phong.dao.CartDao cartDao = new com.phong.dao.CartDao();
			// itemCount = cartDao.getCartCountByUserId(activeUser.getUserId());
			// Better to ensure it's passed via session/request attribute
			System.err.println("Warning: Cart count not found in request attributes for checkout from cart.");
		}

	} else if ("buy".equals(fromAttr)) {
		itemCount = 1;
		Float buyNowPriceFromSession = (Float) session.getAttribute("buyNowPrice");
		if (buyNowPriceFromSession != null) {
			itemTotalPrice = buyNowPriceFromSession;
		} else {
			// Fallback: Fetch price again if not set in session (less ideal)
			Integer pid = (Integer) session.getAttribute("pid");
			if (pid != null) {
				ProductDao pDao = new ProductDao();
				Product p = pDao.getProductsByProductId(pid);
				if(p != null) {
					itemTotalPrice = p.getProductPriceAfterDiscount();
				} else {
					System.err.println("Error: Product for 'buy now' (PID: " + pid + ") not found.");
					// Handle error - maybe redirect with message
				}
			} else {
				System.err.println("Error: Missing 'pid' or 'buyNowPrice' in session for 'buy now'.");
				// Handle error
			}
		}
	}

	float totalAmountPayable = itemTotalPrice + deliveryCharge + packagingCharge;

	// Make calculated values available to EL
	request.setAttribute("itemCount", itemCount);
	request.setAttribute("itemTotalPrice", itemTotalPrice);
	request.setAttribute("deliveryCharge", deliveryCharge);
	request.setAttribute("packagingCharge", packagingCharge);
	request.setAttribute("totalAmountPayable", totalAmountPayable);

	// List of UK Counties / Areas (Add/Refine as needed)
	List<String> ukCounties = Arrays.asList(
			// England Ceremonial Counties (Common for Addressing)
			"Avon", "Bedfordshire", "Berkshire", "Bristol", "Buckinghamshire", "Cambridgeshire",
			"Cheshire", "Cleveland", "Cornwall", "Cumbria", "Derbyshire", "Devon",
			"Dorset", "Durham", "East Riding of Yorkshire", "East Sussex", "Essex", "Gloucestershire", "Greater London",
			"Greater Manchester", "Hampshire", "Herefordshire", "Hertfordshire", "Isle of Wight",
			"Kent", "Lancashire", "Leicestershire", "Lincolnshire", "Merseyside", "Norfolk",
			"North Yorkshire", "Northamptonshire", "Northumberland", "Nottinghamshire",
			"Oxfordshire", "Rutland", "Shropshire", "Somerset", "South Yorkshire", "Staffordshire",
			"Suffolk", "Surrey", "Tyne and Wear", "Warwickshire", "West Midlands",
			"West Sussex", "West Yorkshire", "Wiltshire", "Worcestershire",
			// Scotland Council Areas
			"Aberdeenshire", "City of Edinburgh", "Glasgow City", "Highland", "Fife", "Stirling",
			// Wales Principal Areas
			"Cardiff", "Swansea", "Gwynedd", "Powys", "Pembrokeshire",
			// Northern Ireland Counties
			"County Antrim", "County Armagh", "County Down", "County Fermanagh", "County Londonderry", "County Tyrone"
			// Add others if needed
	);
	Collections.sort(ukCounties); // Sort the list alphabetically

	// Set attribute with a suitable name for UK
	request.setAttribute("ukCountiesList", ukCounties);
%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Checkout - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f8f9fa;
		}
		.checkout-section {
			background-color: #fff;
			padding: 1.5rem;
			border-radius: 0.5rem;
			box-shadow: 0 2px 8px rgba(0,0,0,0.08);
			margin-bottom: 1.5rem;
		}
		.section-header {
			background-color: #0d6efd; /* Primary blue */
			color: white;
			padding: 0.75rem 1.25rem;
			margin: -1.5rem -1.5rem 1.5rem -1.5rem; /* Extend to edges */
			border-top-left-radius: 0.5rem;
			border-top-right-radius: 0.5rem;
		}
		.section-header h4 {
			margin-bottom: 0;
			font-size: 1.2rem;
			font-weight: 500;
		}
		.address-details h5 {
			font-size: 1.1rem;
			font-weight: 600;
			margin-bottom: 0.25rem;
		}
		.address-details p {
			color: #495057;
			margin-bottom: 1rem;
			line-height: 1.6;
		}
		.payment-options .form-check {
			padding: 1rem;
			border: 1px solid #e0e0e0;
			border-radius: 0.375rem;
			margin-bottom: 1rem;
			transition: background-color 0.2s ease;
		}
		.payment-options .form-check:has(input:checked) { /* Style parent when radio is checked */
			background-color: #e7f1ff;
			border-color: #a9cbf7;
		}
		.payment-options .form-check-label {
			font-weight: 500;
			cursor: pointer;
		}
		.card-details {
			margin-left: 1.5rem; /* Indent card details */
			padding-left: 1rem;
			border-left: 3px solid #e0e0e0;
			margin-top: 0.5rem;
			display: none; /* Hide by default */
		}
		.payment-options .form-check:has(input[value='Card Payment']:checked) ~ .card-details {
			display: block; /* Show when card payment is selected */
		}

		.price-details-card .card-body {
			padding: 1.5rem;
		}
		.price-details-card h4 {
			margin-bottom: 1rem;
			font-weight: 600;
			color: #343a40;
		}
		.price-details-table td {
			padding: 0.5rem 0;
			border: none;
			color: #495057;
		}
		.price-details-table tr:last-child td {
			padding-top: 1rem;
			border-top: 1px solid #e9ecef;
			font-weight: 700;
			color: #212529;
			font-size: 1.1rem;
		}
		.modal-header {
			background-color: #f1f1f1;
		}
		.modal-footer {
			background-color: #f8f9fa;
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content - Use flex-grow-1 --%>
<main class="container flex-grow-1 my-4">

	<%-- Display Messages --%>
	<%@include file="Components/alert_message.jsp"%>

	<div class="row">
		<%-- Left Column: Address and Payment --%>
		<div class="col-lg-8 mb-4 mb-lg-0">
			<div class="checkout-section">
				<div class="section-header">
					<h4><i class="fa-solid fa-location-dot"></i> Delivery Address</h4>
				</div>
				<div class="address-details">
					<h5>
						<c:out value="${sessionScope.activeUser.userName}"/>
						(<c:out value="${sessionScope.activeUser.userPhone}"/>)
					</h5>
					<p>
						<c:out value="${sessionScope.activeUser.userAddress}"/>, <c:out value="${sessionScope.activeUser.userCity}"/><br>
						<c:out value="${sessionScope.activeUser.userCounty}"/> - <c:out value="${sessionScope.activeUser.userPostcode}"/>
					</p>
					<div class="text-end">
						<button type="button" class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#changeAddressModal">
							<i class="fa-solid fa-edit"></i> Change Address
						</button>
					</div>
				</div>
			</div> <%-- End address section --%>

			<div class="checkout-section payment-options">
				<div class="section-header">
					<h4><i class="fa-solid fa-credit-card"></i> Payment Options</h4>
				</div>
				<%-- Action points to the final order placement servlet --%>
				<form action="OrderOperationServlet" method="post" id="paymentForm">
					<%-- paymentMode radio buttons --%>
					<div class="form-check">
						<input class="form-check-input" type="radio" name="paymentMode" id="codRadio" value="Cash on Delivery" required checked> <%-- Default checked --%>
						<label class="form-check-label" for="codRadio">
							Cash on Delivery (COD)
						</label>
					</div>

					<div class="form-check">
						<input class="form-check-input" type="radio" name="paymentMode" id="cardRadio" value="Card Payment" required>
						<label class="form-check-label" for="cardRadio">
							Credit / Debit / ATM Card
						</label>
					</div>

					<%-- Card details div (shown only when cardRadio is checked) --%>
					<div class="card-details mt-3">
						<div class="mb-3">
							<label for="cardNoInput" class="form-label small">Card Number</label>
							<input class="form-control form-control-sm" type="text" id="cardNoInput" inputmode="numeric" pattern="[0-9\s]{13,19}" autocomplete="cc-number" maxlength="19" placeholder="xxxx xxxx xxxx xxxx" name="cardno">
						</div>
						<div class="row">
							<div class="col-md-7 mb-3">
								<label for="cardExpInput" class="form-label small">Valid Through (MM/YY)</label>
								<input class="form-control form-control-sm" type="text" id="cardExpInput" pattern="^(0[1-9]|1[0-2])\/?([0-9]{2})$" placeholder="MM/YY" autocomplete="cc-exp" name="cardExp">
							</div>
							<div class="col-md-5 mb-3">
								<label for="cardCvvInput" class="form-label small">CVV</label>
								<input class="form-control form-control-sm" type="text" id="cardCvvInput" pattern="[0-9]{3,4}" autocomplete="cc-csc" placeholder="CVV" name="cvv">
							</div>
						</div>
						<div class="mb-3">
							<label for="cardNameInput" class="form-label small">Card Holder Name</label>
							<input class="form-control form-control-sm" type="text" id="cardNameInput" placeholder="Name as on card" autocomplete="cc-name" name="name">
						</div>
					</div>

					<%-- Place Order Button (part of the form) --%>
					<div class="text-end mt-4">
						<button type="submit" class="btn btn-lg btn-primary">
							<i class="fa-solid fa-check"></i> Place Order
						</button>
					</div>
				</form>
			</div> <%-- End payment section --%>
		</div> <%-- End left column --%>

		<%-- Right Column: Price Details --%>
		<div class="col-lg-4">
			<div class="card price-details-card shadow-sm">
				<div class="card-body">
					<h4>Price Details</h4>
					<hr>
					<table class="table price-details-table">
						<tbody>
						<tr>
							<td>Price (<c:out value="${itemCount}"/> item<c:if test="${itemCount != 1}">s</c:if>)</td>
							<td class="text-end">
								<fmt:setLocale value="en_GB"/>
								<fmt:formatNumber value="${itemTotalPrice}" type="currency" currencySymbol="£" />
							</td>
						</tr>
						<tr>
							<td>Delivery Charges</td>
							<td class="text-end"><fmt:formatNumber value="${deliveryCharge}" type="currency" currencySymbol="£" /></td>
						</tr>
						<tr>
							<td>Packaging Charges</td>
							<td class="text-end"><fmt:formatNumber value="${packagingCharge}" type="currency" currencySymbol="£" /></td>
						</tr>
						<tr> <%-- Final Amount Row --%>
							<td><strong>Amount Payable</strong></td>
							<td class="text-end"><strong><fmt:formatNumber value="${totalAmountPayable}" type="currency" currencySymbol="£" /></strong></td>
						</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div> <%-- End right column --%>
	</div> <%-- End row --%>
</main> <%-- End main content wrapper --%>


<!-- Change Address Modal -->
<div class="modal fade" id="changeAddressModal" tabindex="-1" aria-labelledby="changeAddressModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h1 class="modal-title fs-5" id="changeAddressModalLabel">Change Delivery Address</h1>
				<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
			</div>
			<%-- Action points to the UpdateUserServlet --%>
			<form action="UpdateUserServlet" method="post">
				<input type="hidden" name="operation" value="changeAddress">
				<div class="modal-body">
					<div class="mb-3">
						<label for="userAddressInput" class="form-label">Address</label>
						<%-- Populate with current address using EL --%>
						<textarea name="user_address" id="userAddressInput" rows="3" placeholder="Enter Address (House No, Street, Area)" class="form-control" required>${sessionScope.activeUser.userAddress}</textarea>
					</div>
					<div class="mb-3">
						<label for="cityInput" class="form-label">City</label>
						<input class="form-control" type="text" name="city" id="cityInput" placeholder="City/District/Town" required value="${sessionScope.activeUser.userCity}">
					</div>
					<div class="row">
						<div class="col-md-6 mb-3">
							<label for="postcodeInput" class="form-label">Postcode</label>
							<%-- Use text for postcode to allow leading zeros if needed, add pattern --%>
							<input class="form-control" type="text" inputmode="numeric" pattern="[0-9]{6}" name="postcode" id="postcodeInput" placeholder="6-digit Postcode" maxlength="6" required value="${sessionScope.activeUser.userPostcode}">
						</div>
						<div class="col-md-6 mb-3">
							<label for="countySelect" class="form-label">County</label>
							<select name="county" id="countySelect" class="form-select" required>
								<option value="" disabled ${empty sessionScope.activeUser.userCounty ? 'selected' : ''}>-- Select County --</option>
								<%-- Use JSTL to populate countys --%>
								<c:forEach var="county" items="${ukCountiesList}">
									<option value="${county}" ${sessionScope.activeUser.userCounty == county ? 'selected' : ''}>${county}</option>
								</c:forEach>
							</select>
						</div>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
					<button type="submit" class="btn btn-primary"><i class="fa-solid fa-save"></i> Save Address</button>
				</div>
			</form>
		</div>
	</div>
</div>
<!-- End Change Address Modal -->

<%-- Footer --%>
<%@include file="footer.jsp"%>

<script>
	// Simple JS to require card details only if card payment is selected
	const paymentForm = document.getElementById('paymentForm');
	const cardRadio = document.getElementById('cardRadio');
	const cardDetailInputs = paymentForm.querySelectorAll('.card-details input');

	function toggleCardDetailsRequirement() {
		const requireCardDetails = cardRadio.checked;
		cardDetailInputs.forEach(input => {
			input.required = requireCardDetails;
		});
	}

	// Add event listeners to radio buttons
	paymentForm.querySelectorAll('input[name="paymentMode"]').forEach(radio => {
		radio.addEventListener('change', toggleCardDetailsRequirement);
	});

	// Initial check in case the page loads with card payment pre-selected (unlikely here)
	// toggleCardDetailsRequirement();

	// Optional: Add event listener for form submission to ensure card details are required if needed
	// paymentForm.addEventListener('submit', (event) => {
	//     toggleCardDetailsRequirement(); // Ensure requirements are set before validation
	//     if (!paymentForm.checkValidity() && cardRadio.checked) {
	//          // Optionally focus first invalid card field
	//     }
	// });

</script>

</body>
</html>