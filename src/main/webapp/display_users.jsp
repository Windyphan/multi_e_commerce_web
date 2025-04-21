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
	UserDao userDao = new UserDao();
	List<User> userList = userDao.getAllUser(); // Get all users

	if (userList == null) { // Handle potential DB error
		userList = Collections.emptyList();
		pageContext.setAttribute("errorMessage", "Could not retrieve user list.", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
	}

	// Make list available for EL
	request.setAttribute("allUsers", userList);
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
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

	<h2 class="page-header">Manage Registered Users</h2>

	<%-- Display Messages --%>
	<%@include file="Components/alert_message.jsp"%>

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
					<tbody>
					<%-- Check if list is empty --%>
					<c:if test="${empty allUsers}">
						<tr>
							<td colspan="7" class="text-center text-muted p-4">No registered users found.</td>
						</tr>
					</c:if>

					<%-- Loop through users using JSTL --%>
					<c:forEach var="user" items="${allUsers}">
						<tr>
							<td class="text-start ps-3"><c:out value="${user.userName}"/></td>
							<td class="text-center"><c:out value="${user.userEmail}"/></td>
							<td class="text-center"><c:out value="${user.userPhone}"/></td>
							<td class="text-center"><c:out value="${user.userGender}"/></td>
							<td class="text-start user-address">
									<%-- Reconstruct address using individual fields for clarity --%>
								<c:out value="${user.userAddress}"/><br>
								<c:out value="${user.userCity}"/><br>
								<c:out value="${user.userCounty}"/> - <c:out value="${user.userPostcode}"/>
							</td>
							<td class="text-center">
									<%-- Format the registration date/time --%>
								<fmt:formatDate value="${user.dateTime}" pattern="dd MMM yyyy, hh:mm a"/>
							</td>
							<td class="text-center action-buttons">
									<%-- Delete User Link/Button --%>
								<a href="UpdateUserServlet?operation=deleteUser&uid=${user.userId}"
								   role="button" class="btn btn-danger btn-sm"
								   onclick="return confirm('Are you sure you want to remove user \'${user.userName}\'? This action cannot be undone.');">
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

</main> <%-- End main wrapper --%>


<%-- Footer --%>
<%@include file="footer.jsp"%>
<%@include file="Components/admin_modals.jsp"%>

</body>
</html>