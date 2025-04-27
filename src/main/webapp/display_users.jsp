<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> <%-- For date formatting --%>

<%@page import="com.phong.dao.UserDao"%>
<%@page import="com.phong.entities.User"%>
<%@page import="com.phong.entities.Admin"%>
<%@page import="com.phong.entities.Message"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Collections"%> <%-- Import Collections --%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check & Data Fetching --%>
<%
	Admin activeAdminForUsersDisplay = (Admin) session.getAttribute("activeAdmin");
	if (activeAdminForUsersDisplay == null) {
		pageContext.setAttribute("errorMessage", "You are not logged in! Login first!!", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		response.sendRedirect("adminlogin.jsp");
		return;
	}

	// Fetch User List
	UserDao userDaoForUserDisplay = new UserDao();
	List<User> userListForUserDisplay = userDaoForUserDisplay.getAllUser(); // Get all users

	if (userListForUserDisplay == null) { // Handle potential DB error
		userListForUserDisplay = Collections.emptyList();
		pageContext.setAttribute("errorMessage", "Could not retrieve user list.", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
	}

	// Make list available for EL
	request.setAttribute("allUsers", userListForUserDisplay);
%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Manage Users - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f8f9fa;
		}
		.table th {
			font-weight: 600;
			background-color: #e9ecef;
			vertical-align: middle;
		}
		.table td {
			vertical-align: middle;
			font-size: 0.95rem;
		}
		.action-buttons a, .action-buttons button {
			margin: 0 3px;
			font-size: 0.85rem;
			padding: 0.25rem 0.6rem;
		}
		.page-header {
			margin-bottom: 1.5rem;
		}
		.user-address {
			font-size: 0.9em; /* Smaller font for address */
			color: #495057;
			white-space: pre-line; /* Allow line breaks in address */
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">

<%-- Main Content Wrapper --%>
<main>
	<h2 class="page-header">Manage Registered Users</h2>

	<%-- Placeholder for dynamic AJAX messages --%>
	<div id="user-alert-placeholder" class="mb-3">
		<div class="alert" role="alert">
			<span class="alert-message"></span>
			<button type="button" class="btn-close float-end" aria-label="Close" onclick="$(this).parent().hide();"></button>
		</div>
	</div>

	<div class="card shadow-sm">
		<div class="card-body p-0">
			<div class="table-responsive">
				<table class="table table-hover table-striped mb-0">
					<thead>
					<tr class="text-center table-light">
						<th class="text-start ps-3">Name</th>
						<th>Email</th>
						<th>Phone</th>
						<th>Gender</th>
						<th class="text-start">Address</th>
						<th>Registered</th>
						<th>Action</th>
					</tr>
					</thead>
					<%-- ADD ID to tbody --%>
					<tbody id="user-table-body">
					<%-- ADD No Results Row --%>
					<tr id="user-no-results-row" style="${empty allUsers ? '' : 'display: none;'}">
						<td colspan="7" class="text-center text-muted p-4">No registered users found.</td>
					</tr>

					<c:forEach var="user" items="${allUsers}">
						<%-- ADD data-user-id to row --%>
						<tr data-user-id="${user.userId}">
							<td class="text-start ps-3"><c:out value="${user.userName}"/></td>
							<td class="text-center"><c:out value="${user.userEmail}"/></td>
							<td class="text-center"><c:out value="${user.userPhone}"/></td>
							<td class="text-center"><c:out value="${user.userGender}"/></td>
							<td class="text-start user-address">
								<c:out value="${user.userAddress}"/><br>
								<c:out value="${user.userCity}"/><br>
								<c:out value="${user.userCounty}"/> - <c:out value="${user.userPostcode}"/>
							</td>
							<td class="text-center">
								<fmt:formatDate value="${user.dateTime}" pattern="dd MMM yyyy, hh:mm a"/>
							</td>
							<td class="text-center action-buttons">
									<%-- MODIFY Delete Link --%>
								<a href="javascript:void(0);"
								   role="button" class="btn btn-danger btn-sm user-delete-btn"
								   data-user-id="${user.userId}"
								   data-user-name="${user.userName}"
								> <%-- Remove onclick --%>
									<i class="fa-solid fa-user-slash"></i> Remove
								</a>
							</td>
						</tr>
					</c:forEach>
					</tbody>
				</table>
			</div> <%-- End table-responsive --%>
		</div> <%-- End card-body --%>
	</div> <%-- End card --%>
</main>
<script>
	$(document).ready(function() {

		// --- Function to display alerts ---
		function showUserAlert(message, type) {
			const alertDiv = $('#user-alert-placeholder .alert');
			const messageSpan = alertDiv.find('.alert-message');

			messageSpan.text(message);
			alertDiv.removeClass('alert-success alert-danger alert-warning alert-info').addClass('alert-' + (type === 'success' ? 'success' : 'danger'));
			alertDiv.fadeIn();
			// Optional: Auto-hide
			// setTimeout(() => { alertDiv.fadeOut(); }, 5000);
		}

		// --- AJAX Delete User ---
		$('#user-table-body').on('click', '.user-delete-btn', function(event) {
			event.preventDefault(); // Prevent default link behavior

			const button = $(this);
			const userId = button.data('user-id');
			const userName = button.data('user-name');

			if (!confirm(`Are you sure you want to remove user '${userName}'? This action cannot be undone.`)) {
				return; // Stop if user cancels
			}

			$('#user-alert-placeholder .alert').hide(); // Hide previous alerts
			button.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i>'); // Show loading state

			$.ajax({
				type: 'POST', // Match servlet's expected method (doPost calls processRequest)
				url: 'UpdateUserServlet?operation=deleteUser', // Servlet endpoint
				data: { uid: userId }, // Send user ID as 'uid'
				dataType: 'json', // Expect JSON response
				success: function(response) {
					if (response.status === 'success' && response.deletedId == userId) {
						showUserAlert(response.message, 'success');
						// Remove the row from the table
						button.closest('tr').fadeOut(400, function() {
							$(this).remove();
							// Check if table is now empty
							if ($('#user-table-body tr:not(#user-no-results-row)').length === 0) {
								$('#user-no-results-row').show();
							}
						});
					} else {
						// Handle delete error from servlet response
						showUserAlert(response.message || 'Could not delete user.', 'danger');
						button.prop('disabled', false).html('<i class="fa-solid fa-user-slash"></i> Remove'); // Restore button
					}
				},
				error: function(jqXHR, textStatus, errorThrown) {
					// Handle AJAX communication error
					console.error("AJAX Delete User Error:", textStatus, errorThrown, jqXHR.responseText);
					showUserAlert('Failed to communicate with the server. Please try again.', 'danger');
					button.prop('disabled', false).html('<i class="fa-solid fa-user-slash"></i> Remove'); // Restore button
				}
				// 'complete' callback not strictly needed here as button is removed on success
			});
		});

	}); // End $(document).ready
</script>

</body>
</html>