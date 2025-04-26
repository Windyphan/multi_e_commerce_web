<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Update Product - Phong Shop Admin</title>
	<%@include file="common_css_js.jsp"%>
	<style>
		body {
			background-color: #f8f9fa;
		}
		/* Reuse update-card styles from update_category_modal.jsp */
		.update-card {
			border: none;
			border-radius: 0.5rem;
			box-shadow: 0 3px 10px rgba(0,0,0,0.07);
			max-width: 800px; /* Wider card for more fields */
			margin: 2rem auto;
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

<div class="modal fade" id="updateProductModal" tabindex="-1" aria-labelledby="updateProductModalLabel" aria-hidden="true" data-bs-theme="light">
	<div class="modal-dialog modal-lg modal-dialog-centered">
		<div class="modal-content">
			<div class="modal-header">
				<h1 class="modal-title fs-5" id="updateProductModalLabel">Edit Product Details</h1>
				<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
			</div>
			<%-- Form submits to AddOperationServlet (for Admin) --%>
			<%-- The ACTION might need to be set dynamically if this modal is shared --%>
			<form action="AddOperationServlet" method="post" enctype="multipart/form-data" id="updateProductModalForm" class="needs-validation" novalidate>
				<input type="hidden" name="operation" value="updateProduct">
				<%-- Product ID (pid) will be set dynamically by JavaScript --%>
				<input type="hidden" name="pid" id="updateProductId">
				<%-- Existing image name will be set dynamically by JavaScript --%>
				<input type="hidden" name="image" id="updateExistingImage">
				<%-- Existing category ID (for fallback) will be set dynamically by JavaScript --%>
				<input type="hidden" name="category" id="updateExistingCategory">

				<div class="modal-body">
					<%-- A loading spinner or message while data loads --%>
					<div id="updateProductModalLoading" class="text-center py-5" style="display: none;">
						<div class="spinner-border text-primary" role="status">
							<span class="visually-hidden">Loading...</span>
						</div>
						<p>Loading product details...</p>
					</div>

					<%-- Form content - Hidden initially until data is loaded --%>
					<div id="updateProductModalFormContent">
						<div class="row">
							<div class="col-md-6 mb-3">
								<label for="updateProductName" class="form-label">Product Name</label>
								<input type="text" class="form-control" id="updateProductName" name="name" required>
								<div class="invalid-feedback">Name is required.</div>
							</div>
							<div class="col-md-6 mb-3">
								<label for="updateProductPrice" class="form-label">Unit Price (£)</label>
								<input type="number" class="form-control" id="updateProductPrice" name="price" required min="0" step="0.01">
								<div class="invalid-feedback">Valid price required (>= 0).</div>
							</div>
						</div>
						<div class="mb-3">
							<label for="updateProductDesc" class="form-label">Description</label>
							<textarea class="form-control" id="updateProductDesc" name="description" rows="3" required></textarea>
							<div class="invalid-feedback">Description is required.</div>
						</div>
						<div class="row">
							<div class="col-md-6 mb-3">
								<label for="updateProductQuantity" class="form-label">Stock Quantity</label>
								<input type="number" class="form-control" id="updateProductQuantity" name="quantity" required min="0">
								<div class="invalid-feedback">Valid quantity required (>= 0).</div>
							</div>
							<div class="col-md-6 mb-3">
								<label for="updateProductDiscount" class="form-label">Discount (%)</label>
								<input type="number" class="form-control" id="updateProductDiscount" name="discount" min="0" max="100" oninput="validateModalDiscount(this)">
								<div class="invalid-feedback">Discount must be 0-100.</div>
							</div>
						</div>
						<div class="row">
							<div class="col-md-6 mb-3">
								<label for="updateProductImage" class="form-label">New Image (Optional)</label>
								<input class="form-control" type="file" name="product_img" id="updateProductImage" accept="image/*">
								<div class="form-text">Leave blank to keep current image.</div>
							</div>
							<div class="col-md-6 mb-3">
								<label for="updateProductCategory" class="form-label">Category</label>
								<select name="categoryType" id="updateProductCategory" class="form-select" required>
									<option value="" disabled>-- Select Category --</option>
									<%-- Options populated by JavaScript or passed via request scope--%>
									<c:forEach var="cat" items="${navbarCategoryList}"> <%-- Needs this list! --%>
										<option value="${cat.categoryId}">${cat.categoryName}</option>
									</c:forEach>
								</select>
								<div class="invalid-feedback">Please select a category.</div>
							</div>
						</div>
						<div class="mb-3">
							<span class="current-img-label">Current Image:</span>
							<img src="" <%-- Src set by JS --%>
								 alt="Current product image" class="current-img-preview" id="updateCurrentImagePreview" style="display:none;">
							<span class="ms-2 fst-italic" id="updateCurrentImageName">No image</span>
						</div>
					</div> <%-- End Form Content --%>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
					<button type="submit" class="btn btn-primary"><i class="fa-solid fa-save"></i> Update Product</button>
				</div>
			</form>
		</div>
	</div>
</div>

</body>
</html>