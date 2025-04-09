<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@page import="com.phong.entities.Admin"%>
<%@page import="com.phong.entities.Message"%>
<%@page import="com.phong.entities.Category"%>
<%@page import="com.phong.dao.CategoryDao"%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check & Data Fetching --%>
<%
	Admin activeAdminForCategoryDisplay = (Admin) session.getAttribute("activeAdmin");
	if (activeAdminForCategoryDisplay == null) {
		pageContext.setAttribute("errorMessage", "You are not logged in! Login first!!", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		response.sendRedirect("adminlogin.jsp");
		return;
	}

	// Get Category ID from request and validate
	Category categoryToUpdate = null;
	int categoryId = 0;
	String cidParam = request.getParameter("cid");
	String errorMessage = null; // For specific errors on this page

	if (cidParam != null && !cidParam.trim().isEmpty()) {
		try {
			categoryId = Integer.parseInt(cidParam.trim());
			if (categoryId > 0) {
				CategoryDao categoryDao = new CategoryDao(); // Instantiate DAO here
				categoryToUpdate = categoryDao.getCategoryById(categoryId);
				if (categoryToUpdate == null) {
					errorMessage = "Category with ID " + categoryId + " not found.";
				}
			} else {
				errorMessage = "Invalid Category ID specified.";
			}
		} catch (NumberFormatException e) {
			errorMessage = "Invalid Category ID format.";
		}
	} else {
		errorMessage = "No Category ID specified.";
	}

	// Redirect if category not found or ID invalid
	if (errorMessage != null) {
		pageContext.setAttribute("errorMessage", errorMessage, PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		response.sendRedirect("display_category.jsp"); // Go back to list
		return;
	}

	// Make the category object available for EL
	request.setAttribute("category", categoryToUpdate);

%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Update Category - Phong Shop Admin</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f8f9fa;
		}
		.update-card {
			border: none;
			border-radius: 0.5rem;
			box-shadow: 0 3px 10px rgba(0,0,0,0.07);
			max-width: 600px; /* Limit width */
			margin: 2rem auto; /* Center card */
		}
		.update-card .card-header {
			background-color: #e9ecef;
			font-weight: 600;
			padding: 1rem 1.25rem;
			border-bottom: 1px solid #dee2e6;
			text-align: center;
		}
		.update-card .card-header h3 {
			margin-bottom: 0;
			font-size: 1.4rem;
		}
		.form-label {
			font-weight: 600;
			margin-bottom: 0.5rem;
			color: #495057;
		}
		.current-img-preview {
			width: 70px;
			height: 70px;
			object-fit: contain;
			border: 1px solid #eee;
			padding: 3px;
			background-color: #fff;
			border-radius: 4px;
			margin-left: 10px;
			vertical-align: middle;
		}
		.current-img-label {
			font-size: 0.9rem;
			color: #6c757d;
		}
		.update-card .card-footer {
			background-color: #f8f9fa;
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

	<div class="card update-card">
		<div class="card-header">
			<h3>Edit Category</h3>
		</div>
		<%-- Form points to servlet, includes category ID --%>
		<form action="AddOperationServlet" method="post" enctype="multipart/form-data" class="needs-validation" novalidate>
			<%-- Hidden fields --%>
			<input type="hidden" name="operation" value="updateCategory">
			<input type="hidden" name="cid" value="${category.categoryId}">
			<%-- Pass existing image name in case no new file is uploaded --%>
			<input type="hidden" name="image" value="${category.categoryImage}">

			<div class="card-body p-4">
				<%-- Display Potential Messages (e.g., if redirect happens with error) --%>
				<%@include file="Components/alert_message.jsp"%>

				<div class="mb-3">
					<label for="categoryNameInput" class="form-label">Category Name</label>
					<input type="text" class="form-control" id="categoryNameInput" name="category_name"
						   value="<c:out value='${category.categoryName}'/>" required>
					<div class="invalid-feedback">Category name is required.</div>
				</div>

				<div class="mb-3">
					<label for="categoryImageInput" class="form-label">New Category Image (Optional)</label>
					<input class="form-control" type="file" name="category_img" id="categoryImageInput" accept="image/*">
					<div class="form-text">Leave blank to keep the current image.</div>
				</div>

				<div class="mb-3">
					<span class="current-img-label">Current Image:</span>
					<c:choose>
						<c:when test="${not empty category.categoryImage}">
							<img src="Product_imgs/${category.categoryImage}" <%-- Use forward slash --%>
								 alt="Current image for ${category.categoryName}" class="current-img-preview">
							<span class="ms-2 fst-italic"><c:out value="${category.categoryImage}"/></span>
						</c:when>
						<c:otherwise>
							<span class="ms-2 text-muted">No image uploaded</span>
						</c:otherwise>
					</c:choose>
				</div>
			</div>
			<div class="card-footer text-center">
				<a href="display_category.jsp" class="btn btn-secondary me-2">
					<i class="fa-solid fa-times"></i> Cancel
				</a>
				<button type="submit" class="btn btn-primary">
					<i class="fa-solid fa-save"></i> Update Category
				</button>
			</div>
		</form>
	</div>

</main> <%-- End main wrapper --%>

<%-- Footer --%>
<%@include file="footer.jsp"%>

<script>
	// Bootstrap validation script
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

</body>
</html>