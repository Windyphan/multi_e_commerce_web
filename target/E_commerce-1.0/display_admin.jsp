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
		/* Style for AJAX loading indicator (optional) */
		.ajax-loader {
			display: none; /* Hidden by default */
			/* Add styles for a spinner or loading text */
			font-style: italic;
			color: #6c757d;
		}
		/* Simple alert styling for dynamic messages */
		#admin-alert-placeholder .alert {
			display: none; /* Hidden initially */
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">

<%-- Main Content Wrapper --%>
<main>
	<h2 class="mb-4">Manage Administrators</h2>

	<%-- Placeholder for dynamic AJAX messages --%>
	<div id="admin-alert-placeholder" class="mb-3">
		<div class="alert" role="alert">
			<span class="alert-message"></span>
			<button type="button" class="btn-close float-end" aria-label="Close" onclick="$(this).parent().hide();"></button>
		</div>
	</div>

	<div class="row">
		<%-- Column 1: Add Admin Form --%>
		<div class="col-lg-4">
			<div class="card">
				<div class="card-header">Add New Admin</div>
				<div class="card-body p-4 add-admin-form">
					<div class="text-center">
						<img src="Images/admin.png" alt="Admin Icon">
					</div>
					<%-- ADD ID TO FORM --%>
					<form id="add-admin-form" action="AdminServlet?operation=save" method="post" class="needs-validation" novalidate>
						<%-- ... (form inputs remain the same) ... --%>
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
							<input type="password" class="form-control" id="adminPassword" name="password" placeholder="Enter password" required minlength="8">
							<div class="invalid-feedback">Password must be at least 8 characters.</div>
						</div>
						<div class="mb-3">
							<label for="adminPhone" class="form-label">Phone</label>
							<input type="tel" class="form-control" id="adminPhone" name="phone" placeholder="Enter phone number" required pattern="[0-9\s\-+()]*" title="Enter a valid phone number">
							<div class="invalid-feedback">Please enter a valid phone number.</div>
						</div>
						<div class="d-grid pt-2">
							<button type="submit" class="btn btn-primary">
								<i class="fa-solid fa-user-plus"></i> Register Admin
							</button>
							<span class="ajax-loader mt-2 text-center">Processing...</span> <%-- Optional loader --%>
						</div>
					</form>
				</div>
			</div>
		</div> <%-- End Add Admin Column --%>

		<%-- Column 2: Admin List Table --%>
		<div class="col-lg-8">
			<div class="card">
				<div class="card-header">Existing Admins</div>
				<div class="card-body p-0">
					<div class="table-responsive">
						<table class="table table-hover admin-table mb-0">
							<thead>
							<tr class="text-center">
								<th>Name</th>
								<th>Email</th>
								<th>Phone</th>
								<th>Action</th>
							</tr>
							</thead>
							<%-- ADD ID TO TABLE BODY --%>
							<tbody id="admin-table-body">
							<%-- Placeholder for empty state, handled dynamically now --%>
							<tr id="admin-no-results-row" style="${empty listOfAdmins ? '' : 'display: none;'}">
								<td colspan="4" class="text-center text-muted p-4">No admins found.</td>
							</tr>
							<c:forEach var="admin" items="${listOfAdmins}">
								<%-- ADD data-admin-id to the row --%>
								<tr class="text-center" data-admin-id="${admin.id}">
									<td><c:out value="${admin.name}"/></td>
									<td><c:out value="${admin.email}"/></td>
									<td><c:out value="${admin.phone}"/></td>
									<td>
											<%-- CHANGE href to # or javascript:void(0) and add class for JS hook --%>
										<a href="javascript:void(0);"
										   role="button"
										   class="btn btn-danger btn-sm btn-remove admin-delete-btn"
										   data-admin-id="${admin.id}"  <%-- Store ID here --%>
										   data-admin-name="${admin.name}" <%-- Store name for confirmation --%>
										> <%-- Remove onclick confirmation --%>
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
</main>


<%-- Conditionally include only if admin is logged in --%>
<%-- JavaScript for AJAX --%>
<script>
	$(document).ready(function() {

		// --- Function to display alerts ---
		function showAdminAlert(message, type) {
			const alertDiv = $('#admin-alert-placeholder .alert');
			const messageSpan = alertDiv.find('.alert-message');

			messageSpan.text(message);
			alertDiv.removeClass('alert-success alert-danger alert-warning alert-info').addClass('alert-' + (type === 'success' ? 'success' : 'danger')); // Simplified types
			alertDiv.fadeIn();

			// Optional: Auto-hide after a few seconds
			// setTimeout(() => { alertDiv.fadeOut(); }, 5000);
		}

		// --- AJAX Form Submission ---
		$('#add-admin-form').on('submit', function(event) {
			event.preventDefault(); // Prevent default page reload
			event.stopPropagation();

			const form = $(this);

			// Basic client-side validation check (Bootstrap's)
			if (!form[0].checkValidity()) {
				form.addClass('was-validated');
				return; // Stop if form is invalid
			}
			form.removeClass('was-validated'); // Reset validation state

			const formData = form.serialize(); // Collect form data
			const submitButton = form.find('button[type="submit"]');
			const loader = form.find('.ajax-loader');

			// Disable button and show loader
			submitButton.prop('disabled', true);
			loader.show();
			$('#admin-alert-placeholder .alert').hide(); // Hide previous alerts

			$.ajax({
				type: 'POST', // Or 'GET' if your servlet uses doGet for save
				url: 'AdminServlet?operation=save', // Servlet endpoint
				data: formData,
				dataType: 'json', // Expect JSON response
				success: function(response) {
					if (response.status === 'success') {
						showAdminAlert(response.message, 'success');
						form[0].reset(); // Clear the form

						// --- Add new row to the table ---
						const newAdmin = response.newAdmin; // Get data from response
						if (newAdmin && newAdmin.id) {
							let newRowHtml = ''; // Initialize empty string
							newRowHtml += '<tr class="text-center" data-admin-id="' + newAdmin.id + '">';
							newRowHtml +=   '<td>' + escapeHtml(newAdmin.name) + '</td>';
							newRowHtml +=   '<td>' + escapeHtml(newAdmin.email) + '</td>';
							newRowHtml +=   '<td>' + escapeHtml(newAdmin.phone) + '</td>';
							newRowHtml +=   '<td>';
							newRowHtml +=     '<a href="javascript:void(0);" ';
							newRowHtml +=        'role="button" ';
							newRowHtml +=        'class="btn btn-danger btn-sm btn-remove admin-delete-btn" ';
							newRowHtml +=        'data-admin-id="' + newAdmin.id + '" ';
							newRowHtml +=        'data-admin-name="' + escapeHtml(newAdmin.name) + '"'; // Ensure name is escaped here too
							newRowHtml +=        '>';
							newRowHtml +=       '<i class="fa-solid fa-trash-alt"></i> Remove';
							newRowHtml +=     '</a>';
							newRowHtml +=   '</td>';
							newRowHtml += '</tr>';
							// --- End of Replacement ---

							$('#admin-table-body').append(newRowHtml);
							$('#admin-no-results-row').hide(); // Hide 'no results' row if it was visible
						} else {
							console.warn("Save successful, but no new admin data received to update table.");
							// Consider reloading the whole table list via another AJAX call if needed
						}

					} else {
						// Handle error response from servlet
						showAdminAlert(response.message || 'An unknown error occurred.', 'danger');
					}
				},
				error: function(jqXHR, textStatus, errorThrown) {
					// Handle AJAX communication error
					console.error("AJAX Error:", textStatus, errorThrown, jqXHR.responseText);
					showAdminAlert('Failed to communicate with server. Please try again.', 'danger');
				},
				complete: function() {
					// Re-enable button and hide loader regardless of success/error
					submitButton.prop('disabled', false);
					loader.hide();
				}
			});
		});

		// --- AJAX Delete ---
		// Use event delegation for dynamically added rows
		$('#admin-table-body').on('click', '.admin-delete-btn', function() {
			const button = $(this);
			const adminId = button.data('admin-id');
			const adminName = button.data('admin-name');

			// Confirmation dialog
			if (!confirm(`Are you sure you want to remove admin '${adminName}'?`)) {
				return; // Stop if user cancels
			}

			$('#admin-alert-placeholder .alert').hide(); // Hide previous alerts
			button.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i>'); // Show loading state

			$.ajax({
				type: 'POST', // Or 'GET' if your servlet uses doGet for delete
				url: 'AdminServlet?operation=delete',
				data: { id: adminId }, // Send ID as data
				dataType: 'json',
				success: function(response) {
					if (response.status === 'success' && response.deletedId == adminId) {
						showAdminAlert(response.message, 'success');
						// --- Remove row from table ---
						button.closest('tr').fadeOut(400, function() {
							$(this).remove();
							// Check if table is now empty
							if ($('#admin-table-body tr:not(#admin-no-results-row)').length === 0) {
								$('#admin-no-results-row').show();
							}
						});
					} else {
						// Handle delete error
						showAdminAlert(response.message || 'Could not delete admin.', 'danger');
						button.prop('disabled', false).html('<i class="fa-solid fa-trash-alt"></i> Remove'); // Restore button
					}
				},
				error: function(jqXHR, textStatus, errorThrown) {
					console.error("AJAX Delete Error:", textStatus, errorThrown, jqXHR.responseText);
					showAdminAlert('Failed to communicate with server for delete.', 'danger');
					button.prop('disabled', false).html('<i class="fa-solid fa-trash-alt"></i> Remove'); // Restore button
				}
				// No 'complete' needed here as button is removed on success
			});
		});

		// Helper function to escape HTML for safely injecting into table
		function escapeHtml(unsafe) {
			if (unsafe === null || typeof unsafe === 'undefined') return '';
			return unsafe
					.toString()
					.replace(/&/g, "&")
					.replace(/</g, "<")
					.replace(/>/g, ">")
					.replace(/"/g, '"')
					.replace(/'/g, "'");
		}

		// Bootstrap validation script
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

	}); // End $(document).ready
</script>

</body>
</html>