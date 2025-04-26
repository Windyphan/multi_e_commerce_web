<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.dao.ProductDao"%>
<%@page import="com.phong.dao.CategoryDao"%> <%-- Import CategoryDao --%>
<%@page import="com.phong.entities.Product"%>
<%@page import="com.phong.entities.Category"%> <%-- Import Category --%>
<%@page import="com.phong.entities.Admin"%>
<%@page import="com.phong.entities.Message"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%> <%-- Import Map --%>
<%@page import="java.util.HashMap"%> <%-- Import HashMap --%>
<%@page import="java.util.Collections"%> <%-- Import Collections --%>


<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check & Data Fetching --%>
<%
	Admin activeAdminForProductsDisplay = (Admin) session.getAttribute("activeAdmin");
	if (activeAdminForProductsDisplay == null) {
		pageContext.setAttribute("errorMessage", "You are not logged in! Login first!!", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
		response.sendRedirect("adminlogin.jsp");
		return;
	}

	// Fetch Products
	ProductDao productDao = new ProductDao();
	List<Product> productList = productDao.getAllProducts(); // Get all products

	// Fetch Categories to map names efficiently
	CategoryDao categoryDaoForProductDisplay = new CategoryDao();
	List<Category> categoryListForProductDisplay = categoryDaoForProductDisplay.getAllCategories();
	Map<Integer, String> categoryNameMap = new HashMap<>();
	if(categoryListForProductDisplay != null) {
		for(Category cat : categoryListForProductDisplay) {
			categoryNameMap.put(cat.getCategoryId(), cat.getCategoryName());
		}
	} else {
		// Handle category fetch error if needed
		pageContext.setAttribute("errorMessage", "Could not load category names.", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "warning", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-warning", PageContext.SESSION_SCOPE);
	}


	if (productList == null) { // Handle potential product fetch error
		productList = Collections.emptyList();
		pageContext.setAttribute("errorMessage", "Could not retrieve product list.", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
		pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
	}

	// Make data available for EL
	request.setAttribute("allProducts", productList);
	request.setAttribute("categoryNames", categoryNameMap); // Map of CategoryID -> CategoryName

%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Manage Products - Phong Shop</title>
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
			font-size: 0.95rem; /* Slightly smaller table text */
		}
		.product-img-sm {
			width: 55px; /* Slightly larger image */
			height: 55px;
			object-fit: contain;
			border-radius: 4px;
			background-color: #fff; /* White background if image is transparent */
			padding: 2px;
			border: 1px solid #eee;
		}
		.action-buttons a, .action-buttons button {
			margin: 0 3px;
			font-size: 0.85rem;
			padding: 0.25rem 0.6rem;
		}
		.page-header {
			margin-bottom: 1.5rem;
			display: flex;
			justify-content: space-between;
			align-items: center;
		}
		.product-name {
			font-weight: 500;
			color: #212529;
		}
		.product-category {
			font-size: 0.9em;
			color: #6c757d;
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">

<%-- Main Content Wrapper --%>
<main>

	<div class="page-header">
		<h2>Manage Products</h2>
	</div>

	<div class="card shadow-sm">
		<div class="card-body p-0">
			<div class="table-responsive">
				<table class="table table-hover table-striped mb-0"> <%-- Added table-striped --%>
					<thead>
					<tr class="text-center table-light">
						<th style="width: 10%;">Image</th>
						<th style="width: 30%;" class="text-start">Name</th>
						<th style="width: 15%;" class="text-start">Category</th>
						<th style="width: 10%;">Price</th>
						<th style="width: 10%;">Stock</th>
						<th style="width: 10%;">Discount</th>
						<th style="width: 15%;">Actions</th>
					</tr>
					</thead>
					<tbody>
					<%-- Check if list is empty --%>
					<c:if test="${empty allProducts}">
						<tr>
							<td colspan="7" class="text-center text-muted p-4">No products found. Add one using the button above.</td>
						</tr>
					</c:if>

					<%-- Loop through products using JSTL --%>
					<c:forEach var="product" items="${allProducts}">
						<tr class="text-center">
							<td>
									<%-- Use forward slash for path --%>
								<img src="${s3BaseUrl}${product.productImages}"
									 alt="${product.productName}" class="product-img-sm">
							</td>
							<td class="text-start product-name">
								<c:out value="${product.productName}"/>
									<%-- Optional: Add description tooltip or small text if needed --%>
							</td>
							<td class="text-start product-category">
									<%-- Get category name from the map prepared earlier --%>
								<c:out value="${categoryNames[product.categoryId]}"/>
								<c:if test="${empty categoryNames[product.categoryId]}">
									<span class="text-muted fst-italic">N/A</span>
								</c:if>
							</td>
							<td>
									<%-- Display discounted price --%>
								<fmt:setLocale value="en_GB"/>
								<fmt:formatNumber value="${product.productPriceAfterDiscount}" type="currency" currencySymbol="£"/>
							</td>
							<td><c:out value="${product.productQuantity}"/></td>
							<td><c:out value="${product.productDiscount}"/>%</td>
							<td class="action-buttons">
									<%-- Link to Update Page --%>
									<button type="button" class="btn btn-secondary btn-sm btn-update-product"
											data-bs-toggle="modal"
											data-bs-target="#updateProductModal"
											data-pid="${product.productId}"
											data-name="${product.productName}"
											data-price="${product.productPrice}"
											data-description="<c:out value='${product.productDescription}' escapeXml='true'/>" <%-- Use c:out for description --%>
											data-quantity="${product.productQuantity}"
											data-discount="${product.productDiscount}"
											data-category-id="${product.categoryId}"
											data-image-name="${product.productImages}"> <%-- Pass current image name --%>
										<i class="fa-solid fa-edit"></i> Update
									</button>
									<%-- Link to Delete Servlet with confirmation --%>
								<a href="AddOperationServlet?pid=${product.productId}&operation=deleteProduct"
								   class="btn btn-danger btn-sm" role="button"
								   onclick="return confirm('Are you sure you want to delete product \'${product.productName}\'?');">
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
<script>
	$(document).ready(function() { // Use jQuery ready for simplicity here

		const updateModal = document.getElementById('updateProductModal');
		const updateModalForm = document.getElementById('updateProductModalForm');
		const loadingDiv = document.getElementById('updateProductModalLoading');
		const formContentDiv = document.getElementById('updateProductModalFormContent');
		const s3BaseUrl = '<c:out value="${s3BaseUrl}"/>'; // Make sure s3BaseUrl is available

		if (updateModal) {
			updateModal.addEventListener('show.bs.modal', function (event) {
				// Button that triggered the modal
				const button = event.relatedTarget;

				// Extract info from data-* attributes
				const productId = button.getAttribute('data-pid');
				const name = button.getAttribute('data-name');
				const price = button.getAttribute('data-price');
				const description = button.getAttribute('data-description');
				const quantity = button.getAttribute('data-quantity');
				const discount = button.getAttribute('data-discount');
				const categoryId = button.getAttribute('data-category-id');
				const imageName = button.getAttribute('data-image-name');

				console.log("Populating update modal for PID:", productId);

				// Get the modal's elements
				const modalTitle = updateModal.querySelector('.modal-title');
				const productIdInput = updateModal.querySelector('#updateProductId');
				const existingImageInput = updateModal.querySelector('#updateExistingImage');
				const existingCategoryInput = updateModal.querySelector('#updateExistingCategory');
				const nameInput = updateModal.querySelector('#updateProductName');
				const priceInput = updateModal.querySelector('#updateProductPrice');
				const descInput = updateModal.querySelector('#updateProductDesc');
				const quantityInput = updateModal.querySelector('#updateProductQuantity');
				const discountInput = updateModal.querySelector('#updateProductDiscount');
				const categorySelect = updateModal.querySelector('#updateProductCategory');
				const imagePreview = updateModal.querySelector('#updateCurrentImagePreview');
				const imageNameLabel = updateModal.querySelector('#updateCurrentImageName');
				const imageFileInput = updateModal.querySelector('#updateProductImage');

				// Clear previous validation states
				updateModalForm.classList.remove('was-validated');

				// Reset file input (important!)
				imageFileInput.value = '';

				// --- Populate the form ---
				modalTitle.textContent = 'Edit Product: ' + name; // Update title
				productIdInput.value = productId;
				existingImageInput.value = imageName || '';
				existingCategoryInput.value = categoryId || '';
				nameInput.value = name || '';
				priceInput.value = price || 0;
				descInput.value = description || '';
				quantityInput.value = quantity || 0;
				discountInput.value = discount || 0;

				// Select the correct category in the dropdown
				if(categorySelect){
					if(categoryId){
						categorySelect.value = categoryId;
					} else {
						categorySelect.value = ""; // Select the default disabled option
					}
				}

				// Display current image preview
				if (imageName) {
					imagePreview.src = s3BaseUrl + imageName;
					imagePreview.style.display = 'inline-block';
					imageNameLabel.textContent = imageName;
				} else {
					imagePreview.style.display = 'none';
					imagePreview.src = '';
					imageNameLabel.textContent = 'No image';
				}

				// Optional: Show loading indicator while populating (usually fast enough not to need)
				// formContentDiv.style.display = 'block';
				// loadingDiv.style.display = 'none';
			});

			// Optional: Reset form when modal is hidden
			updateModal.addEventListener('hidden.bs.modal', function (event) {
				// updateModalForm.reset(); // Reset might clear hidden fields unintentionally
				// Clear specific fields if needed or rely on show.bs.modal to repopulate
				const imageFileInput = updateModal.querySelector('#updateProductImage');
				imageFileInput.value = ''; // Clear file input
				updateModalForm.classList.remove('was-validated'); // Remove validation classes
			});
		}

		// Ensure discount validation function exists if modal is used
		function validateModalDiscount(inputElement) {
			const discountValue = parseInt(inputElement.value, 10);
			if (inputElement.value === '' || (!isNaN(discountValue) && discountValue >= 0 && discountValue <= 100)) {
				inputElement.setCustomValidity(''); inputElement.classList.remove('is-invalid');
			} else {
				inputElement.setCustomValidity('Discount must be between 0 and 100.'); inputElement.classList.add('is-invalid');
			}
		}
		const discountFieldModalCheck = document.getElementById('updateProductDiscount');
		if(discountFieldModalCheck) discountFieldModalCheck.addEventListener('blur', () => validateModalDiscount(discountFieldModalCheck));


	});
</script>
</body>
</html>