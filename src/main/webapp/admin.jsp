<%-- JSTL Core tag library --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Import necessary entity (only Message used directly here, others via session EL) --%>

<%-- Set Error Page --%>
<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%--
    SECURITY CHECK using JSTL and redirecting immediately if not admin.
    This replaces the scriptlet check.
--%>
<c:if test="${empty sessionScope.activeAdmin}">
	<c:set var="errorMessage" value="You are not logged in! Login first!!" scope="session"/>
	<c:set var="errorType" value="error" scope="session"/>
	<c:set var="errorClass" value="alert-danger" scope="session"/>
	<c:redirect url="adminlogin.jsp"/>
	<%-- Use c:redirect which handles response commit; no 'return' needed --%>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Admin Dashboard - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f8f9fa; /* Light background for the whole page */
		}
		.admin-welcome {
			margin-bottom: 2rem;
		}
		.admin-welcome img {
			max-width: 150px;
			margin-bottom: 1rem;
		}
		.admin-welcome h3 {
			font-weight: 500;
			color: #343a40;
		}

		/* Dashboard Cards Styling */
		.dashboard-card {
			transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
			border: none; /* Remove default card border */
			border-radius: 0.5rem; /* Slightly more rounded */
			background-color: #ffffff; /* White background */
			box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
		}
		.dashboard-card:hover {
			transform: translateY(-5px);
			box-shadow: 0 6px 15px rgba(0, 0, 0, 0.12);
		}
		.dashboard-card a {
			text-decoration: none;
			color: #343a40; /* Dark text for title */
		}
		.dashboard-card .card-body {
			padding: 1.5rem;
		}
		.dashboard-card img {
			max-width: 65px; /* Slightly smaller icons */
			margin-bottom: 0.75rem;
			opacity: 0.8;
		}
		.dashboard-card .card-title {
			font-size: 1.2rem;
			font-weight: 600;
			margin-top: 0.5rem;
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<div class="container mt-4"> <%-- Use container for padding --%>

	<%-- Display Messages --%>
	<%@include file="Components/alert_message.jsp"%>
	<%@include file="Components/admin_modals.jsp"%>

	<%-- Welcome Section --%>
	<div class="text-center admin-welcome">
		<img src="Images/admin.png" class="img-fluid rounded-circle mb-3" alt="Admin Icon">
		<%-- Access admin name safely from session scope --%>
		<h3>Welcome, <c:out value="${sessionScope.activeAdmin.name}"/>!</h3>
	</div>

	<%-- Dashboard Links --%>
	<div class="row g-4 justify-content-center"> <%-- g-4 for gap, justify-content-center --%>
		<div class="col-12 col-sm-6 col-md-4 col-lg-3">
			<div class="card dashboard-card text-center h-100">
				<a href="display_category.jsp">
					<div class="card-body">
						<img src="Images/categories.png" alt="Category Icon">
						<h4 class="card-title">Categories</h4>
					</div>
				</a>
			</div>
		</div>
		<div class="col-12 col-sm-6 col-md-4 col-lg-3">
			<div class="card dashboard-card text-center h-100">
				<a href="display_products.jsp">
					<div class="card-body">
						<img src="Images/products.png" alt="Product Icon">
						<h4 class="card-title">Products</h4>
					</div>
				</a>
			</div>
		</div>
		<div class="col-12 col-sm-6 col-md-4 col-lg-3">
			<div class="card dashboard-card text-center h-100">
				<a href="display_orders.jsp">
					<div class="card-body">
						<img src="Images/order.png" alt="Order Icon">
						<h4 class="card-title">Orders</h4>
					</div>
				</a>
			</div>
		</div>
		<div class="col-12 col-sm-6 col-md-4 col-lg-3">
			<div class="card dashboard-card text-center h-100">
				<a href="display_users.jsp">
					<div class="card-body">
						<img src="Images/users.png" alt="User Icon">
						<h4 class="card-title">Users</h4>
					</div>
				</a>
			</div>
		</div>
		<div class="col-12 col-sm-6 col-md-4 col-lg-3">
			<div class="card dashboard-card text-center h-100">
				<a href="display_admin.jsp">
					<div class="card-body">
						<img src="Images/add-admin.png" alt="Admin Icon">
						<h4 class="card-title">Admins</h4>
					</div>
				</a>
			</div>
		</div>
		<%-- Add more cards here if needed --%>
	</div>
	<hr class="my-4"> <%-- Add a separator --%>
</div>

<%-- Footer --%>
 <%@include file="footer.jsp"%>
</body>
</html>