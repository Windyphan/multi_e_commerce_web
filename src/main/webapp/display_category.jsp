<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@page import="com.phong.entities.Admin"%> <%-- Still needed for session type check --%>
<%@page import="com.phong.entities.Message"%> <%-- For potential error message --%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%--
    SECURITY CHECK using JSTL.
    Relies on 'activeAdminForNav' being set correctly in navbar.jsp (or pass activeAdmin directly)
--%>
<c:if test="${empty sessionScope.activeAdmin}"> <%-- Check session directly for security --%>
	<c:set var="errorMessage" value="You are not logged in! Login first!!" scope="session"/>
	<c:set var="errorType" value="error" scope="session"/>
	<c:set var="errorClass" value="alert-danger" scope="session"/>
	<c:redirect url="adminlogin.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Manage Categories - Phong Shop</title>
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
		}
		.category-img {
			width: 50px; /* Slightly smaller image */
			height: 50px;
			object-fit: contain; /* Prevent distortion */
			border-radius: 4px; /* Optional: slight rounding */
		}
		.action-buttons a, .action-buttons button { /* Target buttons/links in action cell */
			margin: 0 3px; /* Add small spacing between buttons */
			font-size: 0.85rem;
			padding: 0.25rem 0.6rem;
		}
		.page-header {
			margin-bottom: 1.5rem;
			display: flex;
			justify-content: space-between;
			align-items: center;
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

	<div class="page-header">
		<h2>Manage Product Categories</h2>
		<%-- Button to trigger the Add Category modal (defined in admin.jsp or navbar.jsp) --%>
		<button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#add-category">
			<i class="fa-solid fa-plus"></i> Add New Category
		</button>
	</div>

	<%-- Display Messages --%>
	<%@include file="Components/alert_message.jsp"%>

	<div class="card shadow-sm">
		<div class="card-body p-0"> <%-- Remove padding if table touches edges --%>
			<div class="table-responsive">
				<table class="table table-hover mb-0"> <%-- remove bottom margin --%>
					<thead>
					<tr class="text-center table-light"> <%-- Use table-light for header --%>
						<th style="width: 15%;">Image</th>
						<th style="width: 55%;" class="text-start">Category Name</th>
						<th style="width: 30%;">Actions</th>
					</tr>
					</thead>
					<tbody>
					<%-- Check if the list (presumably from navbar) is empty --%>
					<c:if test="${empty navbarCategoryList}">
						<tr>
							<td colspan="3" class="text-center text-muted p-4">No categories found. Add one using the button above.</td>
						</tr>
					</c:if>

					<%-- Loop through categories using JSTL --%>
					<c:forEach var="category" items="${navbarCategoryList}">
						<tr class="text-center">
							<td>
									<%-- Use forward slash for path --%>
								<img src="Product_imgs/${category.categoryImage}"
									 alt="${category.categoryName}" class="category-img">
							</td>
							<td class="text-start"> <%-- Align name left --%>
								<c:out value="${category.categoryName}"/>
							</td>
							<td class="action-buttons">
									<%-- Link to Update Page --%>
								<a href="update_category.jsp?cid=${category.categoryId}"
								   role="button" class="btn btn-secondary btn-sm">
									<i class="fa-solid fa-edit"></i> Update
								</a>
									<%-- Link to Delete Servlet with confirmation --%>
								<a href="AddOperationServlet?cid=${category.categoryId}&operation=deleteCategory"
								   class="btn btn-danger btn-sm" role="button"
								   onclick="return confirm('Are you sure you want to delete category \'${category.categoryName}\'? This might affect products in this category.');">
									<i class="fa-solid fa-trash-alt"></i> Delete
								</a>
							</td>
						</tr>
					</c:forEach>
					</tbody>
				</table>
			</div> <%-- End table-responsive --%>
		</div> <%-- End card-body --%>
	</div> <%-- End card --%>

</main> <%-- End main --%>

<%-- Footer --%>
<%@include file="footer.jsp"%>

<%-- Any page-specific JS can go here --%>

</body>
</html>