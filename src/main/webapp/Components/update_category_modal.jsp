<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Update Category - Phong Shop Admin</title>
	<%@include file="common_css_js.jsp"%>
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

<%-- Main Content Wrapper --%>
<div class="modal fade" id="updateCategoryModal" tabindex="-1" aria-labelledby="updateCategoryModalLabel" aria-hidden="true" data-bs-theme="light">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title" id="updateCategoryModalLabel">Edit Category Details</h5>
				<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
			</div>
			<form action="AddOperationServlet" method="post" enctype="multipart/form-data" class="needs-validation" novalidate>
				<%-- Hidden fields --%>
				<input type="hidden" name="operation" value="updateCategory">
				<input type="hidden" name="cid" value="${category.categoryId}">
				<input type="hidden" name="image" value="${category.categoryImage}">

				<div class="modal-body">

					<div class="mb-3">
						<label for="updateCategoryNameInputModal" class="form-label">Category Name</label>
						<input type="text" class="form-control" id="updateCategoryNameInputModal" name="category_name"
							   value="<c:out value='${category.categoryName}'/>" required>
						<div class="invalid-feedback">Category name is required.</div>
					</div>

					<div class="mb-3">
						<label for="updateCategoryImageInputModal" class="form-label">New Category Image (Optional)</label>
						<input class="form-control" type="file" name="category_img" id="updateCategoryImageInputModal" accept="image/*">
						<div class="form-text">Leave blank to keep the current image.</div>
					</div>

					<div class="mb-3">
						<span class="current-img-label">Current Image:</span>
						<c:choose>
							<c:when test="${not empty category.categoryImage}">
								<img src="${s3BaseUrl}${category.categoryImage}" <%-- Forward slash --%>
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
					<button type="button" class="btn btn-secondary me-2" data-bs-dismiss="modal">
						<i class="fa-solid fa-times"></i> Cancel
					</button>
					<button type="submit" class="btn btn-primary">
						<i class="fa-solid fa-save"></i> Update Category
					</button>
				</div>
			</form>
		</div>
	</div>
</div>

</body>
</html>