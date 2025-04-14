<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.entities.Admin"%>
<%@page import="com.phong.entities.Product"%>
<%@page import="com.phong.dao.ProductDao"%>


<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check & Data Fetching --%>
<%
	Admin activeAdminForProductUpdate = (Admin) session.getAttribute("activeAdmin");
	if (activeAdminForProductUpdate == null) {
		pageContext.setAttribute("errorMessage", "You are not logged in! Login first!!", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		response.sendRedirect("adminlogin.jsp");
		return;
	}

	// Get Product ID from request and validate
	Product productToUpdate = null;
	int productId = 0;
	String pidParam = request.getParameter("pid");
	String errorMessage = null;

	if (pidParam != null && !pidParam.trim().isEmpty()) {
		try {
			productId = Integer.parseInt(pidParam.trim());
			if (productId > 0) {
				ProductDao productDao = new ProductDao(); // Instantiate DAO here
				productToUpdate = productDao.getProductsByProductId(productId);
				if (productToUpdate == null) {
					errorMessage = "Product with ID " + productId + " not found.";
				}
			} else {
				errorMessage = "Invalid Product ID specified.";
			}
		} catch (NumberFormatException e) {
			errorMessage = "Invalid Product ID format.";
		}
	} else {
		errorMessage = "No Product ID specified.";
	}

	// Redirect if product not found or ID invalid
	if (errorMessage != null) {
		pageContext.setAttribute("errorMessage", errorMessage, PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		response.sendRedirect("display_products.jsp"); // Go back to product list
		return;
	}

	// Make the product object available for EL
	request.setAttribute("product", productToUpdate);
	// Assuming category list is already available from navbar include as 'navbarCategoryList'
	// If not, fetch it here:
    /*
    if (request.getAttribute("navbarCategoryList") == null) {
         com.phong.dao.CategoryDao categoryDao = new com.phong.dao.CategoryDao();
         List<Category> categoryList = categoryDao.getAllCategories();
         request.setAttribute("navbarCategoryList", categoryList != null ? categoryList : Collections.emptyList());
    }
    */

%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Update Product - Phong Shop Admin</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f8f9fa;
		}
		/* Reuse update-card styles from update_category.jsp */
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
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

	<div class="card update-card">
		<div class="card-header">
			<h3>Edit Product Details</h3>
		</div>
		<%-- Form points to servlet, includes product ID --%>
		<form action="AddOperationServlet" method="post" enctype="multipart/form-data" name="updateProductForm" class="needs-validation" novalidate onsubmit="return validateDiscount()">
			<%-- Hidden fields --%>
			<input type="hidden" name="operation" value="updateProduct">
			<input type="hidden" name="pid" value="${product.productId}">
			<%-- Pass existing image name --%>
			<input type="hidden" name="image" value="${product.productImages}">
			<%-- Pass existing category id as fallback --%>
			<input type="hidden" name="category" value="${product.categoryId}">

			<div class="card-body p-4">
				<%-- Display Potential Messages --%>
				<%@include file="Components/alert_message.jsp"%>

				<div class="row">
					<div class="col-md-6 mb-3">
						<label for="productNameInput" class="form-label">Product Name</label>
						<input type="text" class="form-control" id="productNameInput" name="name"
							   value="<c:out value='${product.productName}'/>" required>
						<div class="invalid-feedback">Product name is required.</div>
					</div>
					<div class="col-md-6 mb-3">
						<label for="productPriceInput" class="form-label">Unit Price (£)</label>
						<input type="number" class="form-control" id="productPriceInput" name="price"
							   value="${product.productPrice}" required min="0" step="0.01">
						<div class="invalid-feedback">Please enter a valid price (>= 0).</div>
					</div>
				</div>

				<div class="mb-3">
					<label for="productDescInput" class="form-label">Product Description</label>
					<textarea class="form-control" id="productDescInput" name="description" rows="3" required><c:out value="${product.productDescription}"/></textarea>
					<div class="invalid-feedback">Description is required.</div>
				</div>

				<div class="row">
					<div class="col-md-6 mb-3">
						<label for="productQuantityInput" class="form-label">Stock Quantity</label>
						<input type="number" class="form-control" id="productQuantityInput" name="quantity"
							   value="${product.productQuantity}" required min="0">
						<div class="invalid-feedback">Please enter a valid quantity (>= 0).</div>
					</div>
					<div class="col-md-6 mb-3">
						<label for="productDiscountInput" class="form-label">Discount (%)</label>
						<input type="number" class="form-control" id="productDiscountInput" name="discount"
							   value="${product.productDiscount}" min="0" max="100">
						<div class="invalid-feedback">Discount must be between 0 and 100.</div>
					</div>
				</div>

				<div class="row">
					<div class="col-md-6 mb-3">
						<label for="productImageInput" class="form-label">New Product Image (Optional)</label>
						<input class="form-control" type="file" name="product_img" id="productImageInput" accept="image/*">
						<div class="form-text">Leave blank to keep the current image.</div>
					</div>
					<div class="col-md-6 mb-3">
						<label for="productCategorySelect" class="form-label">Category</label>
						<select name="categoryType" id="productCategorySelect" class="form-select" required>
							<option value="" disabled>-- Select Category --</option>
							<%-- Loop through categories, pre-select current one --%>
							<c:forEach var="cat" items="${navbarCategoryList}"> <%-- Assumes list from navbar --%>
								<option value="${cat.categoryId}" ${product.categoryId == cat.categoryId ? 'selected' : ''}>
									<c:out value="${cat.categoryName}"/>
								</option>
							</c:forEach>
						</select>
						<div class="invalid-feedback">Please select a category.</div>
					</div>
				</div>

				<div class="mb-3">
					<span class="current-img-label">Current Image:</span>
					<c:choose>
						<c:when test="${not empty product.productImages}">
							<img src="${s3BaseUrl}${product.productImages}" <%-- Forward slash --%>
								 alt="Current image for ${product.productName}" class="current-img-preview">
							<span class="ms-2 fst-italic"><c:out value="${product.productImages}"/></span>
						</c:when>
						<c:otherwise>
							<span class="ms-2 text-muted">No image uploaded</span>
						</c:otherwise>
					</c:choose>
				</div>
			</div>

			<div class="card-footer text-center">
				<a href="display_products.jsp" class="btn btn-secondary me-2">
					<i class="fa-solid fa-times"></i> Cancel
				</a>
				<button type="submit" class="btn btn-primary">
					<i class="fa-solid fa-save"></i> Update Product
				</button>
			</div>
		</form>
	</div>

</main> <%-- End main wrapper --%>

<%-- Footer --%>
<%@include file="footer.jsp"%>

<script type="text/javascript">
	// Discount validation function
	function validateDiscount() {
		const discountInput = document.forms["updateProductForm"]["discount"];
		if (!discountInput) return true; // Skip if field doesn't exist
		const discountValue = parseInt(discountInput.value, 10);

		// Allow empty value (treat as 0 discount later maybe?) or check if required
		if (discountInput.value === '' || (!isNaN(discountValue) && discountValue >= 0 && discountValue <= 100)) {
			discountInput.setCustomValidity(""); // Valid
			return true;
		} else {
			discountInput.setCustomValidity("Discount must be a number between 0 and 100.");
			// We don't alert here, rely on Bootstrap validation display
			// discountInput.focus();
			return false;
		}
	}

	// Bootstrap validation script
	(() => {
		'use strict'
		const forms = document.querySelectorAll('.needs-validation')
		Array.from(forms).forEach(form => {
			form.addEventListener('submit', event => {
				// Run discount validation explicitly before checking form validity
				const isDiscountValid = validateDiscount();

				if (!form.checkValidity() || !isDiscountValid) {
					event.preventDefault()
					event.stopPropagation()
				}

				form.classList.add('was-validated')
			}, false)
		})
	})()

	// Also validate discount on blur
	const discountField = document.getElementById('productDiscountInput');
	if(discountField) {
		discountField.addEventListener('blur', validateDiscount);
	}

</script>

</body>
</html>