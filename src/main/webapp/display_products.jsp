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
		#product-alert-placeholder .alert { display: none; }
	</style>
</head>
<body class="d-flex flex-column min-vh-100">

<%-- Main Content Wrapper --%>
<main>

	<div class="page-header">
		<h2>Manage Products</h2>
	</div>

	<%-- Placeholder for dynamic AJAX messages --%>
	<div id="product-alert-placeholder" class="mb-3">
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
						<th style="width: 10%;">Image</th>
						<th style="width: 30%;" class="text-start">Name</th>
						<th style="width: 15%;" class="text-start">Category</th>
						<th style="width: 10%;">Price</th>
						<th style="width: 10%;">Stock</th>
						<th style="width: 10%;">Discount</th>
						<th style="width: 15%;">Actions</th>
					</tr>
					</thead>
					<%-- ADD ID to tbody --%>
					<tbody id="product-table-body">
					<%-- ADD No Results Row --%>
					<tr id="product-no-results-row" style="${empty allProducts ? '' : 'display: none;'}">
						<td colspan="7" class="text-center text-muted p-4">No products found.</td>
					</tr>

					<c:forEach var="product" items="${allProducts}">
						<%-- ADD data-pid to row --%>
						<tr class="text-center" data-pid="${product.productId}">
							<td class="product-row-image-td"> <%-- Add class to cell --%>
								<img src="${s3BaseUrl}${product.productImages}"
									 alt="${product.productName}" class="product-img-sm product-row-image"> <%-- Add class to image --%>
							</td>
							<td class="text-start product-name product-row-name"> <%-- Add class --%>
								<c:out value="${product.productName}"/>
							</td>
							<td class="text-start product-category product-row-category"> <%-- Add class --%>
								<c:out value="${categoryNames[product.categoryId]}"/>
								<c:if test="${empty categoryNames[product.categoryId]}"><span class="text-muted fst-italic">N/A</span></c:if>
							</td>
							<td class="product-row-price"> <%-- Add class --%>
								<fmt:setLocale value="en_GB"/>
								<fmt:formatNumber value="${product.productPriceAfterDiscount}" type="currency" currencySymbol="£"/>
							</td>
							<td class="product-row-quantity"> <%-- Add class --%>
								<c:out value="${product.productQuantity}"/>
							</td>
							<td class="product-row-discount"> <%-- Add class --%>
								<c:out value="${product.productDiscount}"/>%
							</td>
							<td class="action-buttons">
									<%-- Update button still triggers modal --%>
								<button type="button" class="btn btn-secondary btn-sm btn-update-product"
										data-bs-toggle="modal"
										data-bs-target="#updateProductModal"
										data-pid="${product.productId}"
										data-name="${product.productName}"
										data-price="${product.productPrice}"
										data-description="<c:out value='${product.productDescription}' escapeXml='true'/>"
										data-quantity="${product.productQuantity}"
										data-discount="${product.productDiscount}"
										data-category-id="${product.categoryId}"
										data-image-name="${product.productImages}">
									<i class="fa-solid fa-edit"></i> Update
								</button>
									<%-- MODIFY Delete Link for AJAX --%>
								<a href="javascript:void(0);"
								   class="btn btn-danger btn-sm product-delete-btn" role="button"
								   data-pid="${product.productId}"
								   data-pname="${product.productName}"
								> <%-- Remove onclick --%>
									<i class="fa-solid fa-trash-alt"></i> Delete
								</a>
							</td>
						</tr>
					</c:forEach>
					</tbody>
				</table>
			</div>
		</div>
	</div>
</main>
<script>
	// Make S3 Base URL and Category Names available to JS
	// Convert category map for easier JS use (requires Jackson/Gson on server or manual build)
	// Option 1: If using Jackson/Gson in scriptlet above
	<%--// const categoryNamesJs = JSON.parse('<%= new ObjectMapper().writeValueAsString(categoryNameMap) %>');--%>
	// Option 2: Build manually if map isn't huge (less ideal)
	const categoryNamesJs = {
		<c:forEach var="entry" items="${categoryNames}" varStatus="loop">
		"${entry.key}": "${entry.value}"${!loop.last ? ',' : ''}
		</c:forEach>
	};


	$(document).ready(function() {

		// --- Helper Functions ---
		function showProductAlert(message, type) {
			const alertDiv = $('#product-alert-placeholder .alert');
			const messageSpan = alertDiv.find('.alert-message');
			messageSpan.text(message);
			alertDiv.removeClass('alert-success alert-danger alert-warning alert-info').addClass('alert-' + (type === 'success' ? 'success' : 'danger'));
			alertDiv.fadeIn();
		}

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

		// Get Bootstrap Modal instance for Update Product
		const updateProductModalEl = document.getElementById('updateProductModal');
		const updateProductModal = updateProductModalEl ? new bootstrap.Modal(updateProductModalEl) : null;

		// --- Populate Update Product Modal ---
		// Use jQuery to select the modal element and attach the listener
		$('#updateProductModal').on('show.bs.modal', function (event) {
			console.log(">>> 'show.bs.modal' event FIRED (jQuery)!"); // Log firing

			// Button that triggered the modal
			const button = $(event.relatedTarget); // Use jQuery $(event.relatedTarget)
			if (!button || button.length === 0) { // Check button exists
				console.error("Modal opened without a related target button or button not found.");
				return;
			}

			// Extract info from data-* attributes using jQuery .data()
			const productId = button.data('pid');
			const name = button.data('name');
			const price = button.data('price');
			const description = button.data('description');
			const quantity = button.data('quantity');
			const discount = button.data('discount');
			const categoryId = button.data('category-id');
			const imageName = (button.data('image-name') || '').toString().trim();

			console.log("Populating update modal for PID:", productId, "Data:", button.data()); // Log all data

			// Get the modal's elements using jQuery within the modal scope ('this' refers to the modal here)
			const modal = $(this); // 'this' inside the event handler is the modal div
			const modalTitle = modal.find('.modal-title');
			const productIdInput = modal.find('#updateProductId');
			const existingImageInput = modal.find('#updateExistingImage');
			const nameInput = modal.find('#updateProductName');
			const priceInput = modal.find('#updateProductPrice');
			const descInput = modal.find('#updateProductDesc');
			const quantityInput = modal.find('#updateProductQuantity');
			const discountInput = modal.find('#updateProductDiscount');
			const categorySelect = modal.find('#updateProductCategory');
			const imagePreview = modal.find('#updateCurrentImagePreview');
			const imageNameLabel = modal.find('#updateCurrentImageName');
			const imageFileInput = modal.find('#updateProductImage');
			const form = modal.find('#updateProductModalForm');

			// --- Populate the form ---
			modalTitle.text('Edit Product: ' + (name || '')); // Update title
			productIdInput.val(productId || '');
			existingImageInput.val(imageName || '');
			nameInput.val(name || '');
			priceInput.val(price || 0);
			descInput.val(description || ''); // Use text() or val() based on element? textarea uses val()
			quantityInput.val(quantity || 0);
			discountInput.val(discount || 0);

			// Select the correct category
			if (categorySelect.length) {
				categorySelect.val(categoryId || ""); // Set value, defaults to "" if categoryId is null/undefined
			} else {
				console.error("Category select dropdown #updateProductCategory not found!");
			}

			// Display current image preview
			imagePreview.hide(); // Hide first
			imageNameLabel.text('No image');
			if (imageName && imageName !== 'null') {
				const imgUrl = s3BaseUrlForJs + imageName;
				imagePreview.attr('src', imgUrl).show();
				imageNameLabel.text(escapeHtml(imageName));
			} else {
				imagePreview.attr('src', ''); // Clear src
			}

			// Clear previous validation states
			form.removeClass('was-validated');
			// Reset file input
			imageFileInput.val('');

			console.log("Modal population complete (jQuery).");

		});


		// --- AJAX Update Product ---
		$('#updateProductModalForm').on('submit', function(event) {
			event.preventDefault();
			event.stopPropagation();
			const form = $(this);
			if (!form[0].checkValidity()) { form.addClass('was-validated'); return; }

			const formData = new FormData(this);
			const productId = formData.get('pid'); // Get pid from hidden input
			const submitButton = form.find('button[type="submit"]');

			submitButton.prop('disabled', true); //.html('...');
			$('#product-alert-placeholder .alert').hide();

			$.ajax({
				type: 'POST',
				url: 'AddOperationServlet?operation=updateProduct',
				data: formData,
				processData: false,
				contentType: false,
				dataType: 'json',
				success: function(response) {
					if (response.status === 'success') {
						showProductAlert(response.message, 'success');
						if (updateProductModal) updateProductModal.hide();
						$('.modal-backdrop').remove();
						form.removeClass('was-validated');

						// --- Update table row dynamically ---
						const updatedProd = response.updatedProduct;
						if (updatedProd && updatedProd.productId == productId) {
							const row = $('#product-table-body tr[data-pid="' + productId + '"]');
							if (row.length) {
								console.log("Updating row for PID:", productId);
								const categoryName = categoryNamesJs[updatedProd.categoryId] || 'N/A';
								// Calculate price after discount for display
								const priceAfterDiscount = updatedProd.productPrice * (1 - (updatedProd.productDiscount / 100.0));
								const formatter = new Intl.NumberFormat('en-GB', { style: 'currency', currency: 'GBP' });

								row.find('.product-row-image').attr('src', s3BaseUrlForJs + escapeHtml(updatedProd.productImages)).attr('alt', escapeHtml(updatedProd.productName));
								row.find('.product-row-name').text(updatedProd.productName);
								row.find('.product-row-category').text(categoryName);
								row.find('.product-row-price').text(formatter.format(priceAfterDiscount));
								row.find('.product-row-quantity').text(updatedProd.productQuantity);
								row.find('.product-row-discount').text(updatedProd.productDiscount + '%');

								// Update data attributes on buttons
								const updateBtn = row.find('.btn-update-product');
								updateBtn.data('name', updatedProd.productName);
								updateBtn.data('price', updatedProd.productPrice); // Original price
								updateBtn.data('description', updatedProd.productDescription);
								updateBtn.data('quantity', updatedProd.productQuantity);
								updateBtn.data('discount', updatedProd.productDiscount);
								updateBtn.data('category-id', updatedProd.categoryId);
								updateBtn.data('image-name', updatedProd.productImages);

								row.find('.product-delete-btn').data('pname', updatedProd.productName);
							} else {
								console.warn("Update success, but couldn't find row:", productId);
							}
						} else {
							console.warn("Update success, but data mismatch/missing:", updatedProd);
						}
					} else {
						showProductAlert(response.message || 'Failed to update product.', 'danger');
					}
				},
				error: function() { showProductAlert('Error communicating with server.', 'danger'); },
				complete: function() { submitButton.prop('disabled', false); }
			});
		});


		// --- AJAX Delete Product ---
		$('#product-table-body').on('click', '.product-delete-btn', function(event) {
			event.preventDefault();
			const button = $(this);
			const productId = button.data('pid');
			const productName = button.data('pname');

			if (!confirm('Are you sure you want to delete product \'' + productName + '\'?')) {
				return;
			}

			$('#product-alert-placeholder .alert').hide();
			button.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i>');

			$.ajax({
				type: 'POST',
				url: 'AddOperationServlet?operation=deleteProduct',
				data: { pid: productId }, // Send pid
				dataType: 'json',
				success: function(response) {
					if (response.status === 'success' && response.deletedProductId == productId) {
						showProductAlert(response.message, 'success');
						button.closest('tr').fadeOut(400, function() {
							$(this).remove();
							if ($('#product-table-body tr:not(#product-no-results-row)').length === 0) {
								$('#product-no-results-row').show();
							}
						});
					} else {
						showProductAlert(response.message || 'Could not delete product.', 'danger');
						button.prop('disabled', false).html('<i class="fa-solid fa-trash-alt"></i> Delete');
					}
				},
				error: function() {
					showProductAlert('Error communicating with server.', 'danger');
					button.prop('disabled', false).html('<i class="fa-solid fa-trash-alt"></i> Delete');
				}
			});
		});

	}); // End $(document).ready
</script>
</body>
</html>