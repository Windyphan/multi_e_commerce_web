<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@page import="com.phong.dao.AdminDao"%>
<%@page import="com.phong.entities.Admin"%>
<%@page import="com.phong.entities.Message"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Collections"%> <%-- Import Collections --%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check & Data Fetching --%>
<%
	Admin activeAdminForAdminDisplay = (Admin) session.getAttribute("activeAdmin");
	if (activeAdminForAdminDisplay == null) {
		pageContext.setAttribute("errorMessage", "You are not logged in! Login first!!", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		response.sendRedirect("adminlogin.jsp");
		return;
	}

	// Fetch Admin List
	AdminDao adminDaoForAdminDisplay = new AdminDao();
	List<Admin> adminListForAdminDisplay = adminDaoForAdminDisplay.getAllAdmin();
	if (adminListForAdminDisplay == null) { // Handle potential DB error
		adminListForAdminDisplay = Collections.emptyList();
		pageContext.setAttribute("errorMessage", "Could not retrieve admin list.", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
	}

	// Make list available for EL
	request.setAttribute("listOfAdmins", adminListForAdminDisplay);
%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Manage Admins - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f8f9fa;
		}
		.card {
			border: none;
			border-radius: 0.5rem;
			box-shadow: 0 3px 10px rgba(0,0,0,0.07);
			margin-bottom: 1.5rem; /* Add space between cards */
		}
		.card-header {
			background-color: #e9ecef;
			font-weight: 600;
			padding: 1rem 1.25rem;
			border-bottom: 1px solid #dee2e6;
		}
		.form-label {
			font-weight: 600;
			margin-bottom: 0.5rem;
			color: #495057;
		}
		.admin-table th {
			font-weight: 600;
			background-color: #ddeeff; /* Light blue header */
			vertical-align: middle;
		}
		.admin-table td {
			vertical-align: middle;
		}
		.btn-remove {
			font-size: 0.85rem;
			padding: 0.25rem 0.6rem;
		}
		.add-admin-form img {
			max-width: 80px;
			margin-bottom: 1rem;
		}
		.add-admin-form h3 {
			margin-bottom: 1.5rem;
			font-weight: 500;
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">

<%-- Main Content Wrapper --%>
<main>

	<h2 class="mb-4">Manage Administrators</h2>

	<div class="row">
		<%-- Column 1: Add Admin Form --%>
		<div class="col-lg-4">
			<div class="card">
				<div class="card-header">Add New Admin</div>
				<div class="card-body p-4 add-admin-form">
					<div class="text-center">
						<img src="Images/admin.png" alt="Admin Icon">
					</div>
					<%-- Add Admin Form --%>
					<form action="AdminServlet?operation=save" method="post" class="needs-validation" novalidate>
						<div class="mb-3">
							<label for="adminName" class="form-label">Name</label>
							<input type="text" class="form-control" id="adminName" name="name" placeholder="Enter full name" required>
							<div class="invalid-feedback">Please enter the admin's name.</div>
						</div>
						<div class="mb-3">
							<label for="adminEmail" class="form-label">Email</label>
							<input type="email" class="form-control" id="adminEmail" name="email" placeholder="Enter email address" required>
							<div class="invalid-feedback">Please enter a valid email address.</div>
						</div>
						<div class="mb-3">
							<label for="adminPassword" class="form-label">Password</label>
							<input type="password" class="form-control" id="adminPassword" name="password" placeholder="Enter password" required minlength="8"> <%-- Example min length --%>
							<div class="invalid-feedback">Password must be at least 8 characters.</div>
						</div>
						<div class="mb-3">
							<label for="adminPhone" class="form-label">Phone</label>
							<input type="tel" class="form-control" id="adminPhone" name="phone" placeholder="Enter phone number" required pattern="[0-9\s\-+()]*" title="Enter a valid phone number"> <%-- Basic pattern --%>
							<div class="invalid-feedback">Please enter a valid phone number.</div>
						</div>
						<div class="d-grid pt-2"> <%-- Use grid for full width button --%>
							<button type="submit" class="btn btn-primary">
								<i class="fa-solid fa-user-plus"></i> Register Admin
							</button>
						</div>
					</form>
				</div>
			</div>
		</div> <%-- End Add Admin Column --%>

		<%-- Column 2: Admin List Table --%>
		<div class="col-lg-8">
			<div class="card">
				<div class="card-header">Existing Admins</div>
				<div class="card-body p-0"> <%-- Remove padding for table --%>
					<div class="table-responsive">
						<table class="table table-hover admin-table mb-0"> <%-- Remove bottom margin --%>
							<thead>
							<tr class="text-center">
								<th>Name</th>
								<th>Email</th>
								<th>Phone</th>
								<th>Action</th>
							</tr>
							</thead>
							<tbody>
							<%-- Check if list is empty --%>
							<c:if test="${empty listOfAdmins}">
								<tr>
									<td colspan="4" class="text-center text-muted p-4">No admins found.</td>
								</tr>
							</c:if>
							<%-- Loop through admins using JSTL --%>
							<c:forEach var="admin" items="${listOfAdmins}">
								<tr class="text-center">
									<td><c:out value="${admin.name}"/></td>
									<td><c:out value="${admin.email}"/></td>
									<td><c:out value="${admin.phone}"/></td>
									<td>
											<%-- Add confirmation to delete button --%>
										<a href="AdminServlet?operation=delete&id=${admin.id}"
										   role="button"
										   class="btn btn-danger btn-sm btn-remove"
										   onclick="return confirm('Are you sure you want to remove admin \'${admin.name}\'?');">
											<i class="fa-solid fa-trash-alt"></i> Remove
										</a>
									</td>
								</tr>
							</c:forEach>
							</tbody>
						</table>
					</div>
				</div> <%-- End card-body --%>
			</div>
		</div> <%-- End Admin List Column --%>
	</div> <%-- End row --%>
</main> <%-- End main content wrapper --%>

<%-- Conditionally include only if admin is logged in --%>

<script>
	// Example starter JavaScript for disabling form submissions if there are invalid fields
	// (From Bootstrap docs)
	(() => {
		'use strict'

		// Fetch all the forms we want to apply custom Bootstrap validation styles to
		const forms = document.querySelectorAll('.needs-validation')

		// Loop over them and prevent submission
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