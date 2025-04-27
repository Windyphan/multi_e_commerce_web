<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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

<%-- Main Content Wrapper --%>
<main>

	<div class="page-header">
		<h2>Manage Product Categories</h2>
		<button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#add-category">
			<i class="fa-solid fa-plus"></i> Add New Category
		</button>
	</div>

	<%-- Placeholder for dynamic AJAX messages --%>
	<div id="category-alert-placeholder" class="mb-3">
		<div class="alert" role="alert">
			<span class="alert-message"></span>
			<button type="button" class="btn-close float-end" aria-label="Close" onclick="$(this).parent().hide();"></button>
		</div>
	</div>

	<div class="card shadow-sm">
		<div class="card-body p-0">
			<div class="table-responsive">
				<table class="table table-hover mb-0">
					<thead>
					<tr class="text-center table-light">
						<th style="width: 15%;">Image</th>
						<th style="width: 55%;" class="text-start">Category Name</th>
						<th style="width: 30%;">Actions</th>
					</tr>
					</thead>
					<%-- ADD ID to tbody --%>
					<tbody id="category-table-body">
					<%-- Add No Results Row --%>
					<tr id="category-no-results-row" style="${empty navbarCategoryList ? '' : 'display: none;'}">
						<td colspan="3" class="text-center text-muted p-4">No categories found. Add one using the button above.</td>
					</tr>

					<c:forEach var="category" items="${navbarCategoryList}">
						<%-- ADD data-category-id to row --%>
						<tr class="text-center" data-category-id="${category.categoryId}">
							<td>
									<%-- Add class to image for easier selection --%>
								<img src="${s3BaseUrl}${category.categoryImage}"
									 alt="${category.categoryName}" class="category-img category-row-image">
							</td>
							<td class="text-start category-row-name"> <%-- Add class --%>
								<c:out value="${category.categoryName}"/>
							</td>
							<td class="action-buttons">
									<%-- Update button still triggers modal, data is used by modal JS --%>
								<button type="button" class="btn btn-secondary btn-sm btn-update-category"
										data-bs-toggle="modal" data-bs-target="#updateCategoryModal"
										data-category-id="${category.categoryId}"
										data-category-name="${category.categoryName}"
										data-category-image="${category.categoryImage}">
									<i class="fa-solid fa-edit"></i> Update
								</button>
									<%-- MODIFY Delete Link for AJAX --%>
								<a href="javascript:void(0);"
								   class="btn btn-danger btn-sm category-delete-btn" role="button"
								   data-category-id="${category.categoryId}"
								   data-category-name="${category.categoryName}"
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
	// Make S3 Base URL available to JS
	const s3BaseUrlForJs = '<c:out value="${s3BaseUrl}"/>';

	$(document).ready(function() {

		// --- Helper Functions ---
		function showCategoryAlert(message, type) {
			const alertDiv = $('#category-alert-placeholder .alert');
			const messageSpan = alertDiv.find('.alert-message');
			messageSpan.text(message);
			alertDiv.removeClass('alert-success alert-danger alert-warning alert-info').addClass('alert-' + (type === 'success' ? 'success' : 'danger'));
			alertDiv.fadeIn();
			// setTimeout(() => { alertDiv.fadeOut(); }, 5000);
		}

		function escapeHtml(unsafe) {
			if (unsafe === null || typeof unsafe === 'undefined') return '';
			// Use toString() to handle potential non-string inputs safely
			const safeString = unsafe.toString();

			// Perform replacements
			return safeString
					.replace(/&/g, '&') // Replace & with & (Correct HTML entity)
					.replace(/</g, '<')  // Replace < with <
					.replace(/>/g, '>')  // Replace > with >
					.replace(/"/g, '"') // Replace " with "
					.replace(/'/g, '\'') // Replace " with "
		}

		// Get Bootstrap Modal instances
		const addCategoryModalEl = document.getElementById('add-category');
		const addCategoryModal = addCategoryModalEl ? new bootstrap.Modal(addCategoryModalEl) : null;
		const updateCategoryModalEl = document.getElementById('updateCategoryModal');
		const updateCategoryModal = updateCategoryModalEl ? new bootstrap.Modal(updateCategoryModalEl) : null;


		// --- Populate Update Modal ---
		$('#category-table-body').on('click', '.btn-update-category', function() {
			const button = $(this);
			const categoryId = button.data('category-id');
			const categoryName = button.data('category-name');
			const categoryImage = (button.data('category-image') || '').toString().trim();

			if (updateCategoryModal) {
				const modal = $('#updateCategoryModal');
				const previewContainer = modal.find('#current-image-preview-container');
				modal.find('.modal-title').text('Edit Category - ID ' + categoryId);
				modal.find('input[name="cid"]').val(categoryId); // Set hidden category ID
				modal.find('input[name="image"]').val(categoryImage); // Set hidden existing image name
				modal.find('#updateCategoryNameInputModal').val(categoryName);
				modal.find('#updateCategoryImageInputModal').val(''); // Clear file input
				previewContainer.empty(); // Clear previous preview content reliably

				if (categoryImage && categoryImage !== 'null') { // Check if not empty and not the literal string "null"
					// Assuming s3BaseUrlForJs has trailing slash and categoryImage does not start with one
					const imgUrl = s3BaseUrlForJs + categoryImage;

					let imgHtml = '<img src="' + imgUrl + '" alt="Current image" class="current-img-preview" onerror="this.style.display=\'none\';this.nextSibling.textContent=\' (image load failed)\';">'; // Added simple error handling
					let spanHtml = '<span class="ms-2 fst-italic">' + escapeHtml(categoryImage) + '</span>';
					previewContainer.append(imgHtml).append(spanHtml);
				} else {
					console.log("No valid image name found for preview."); // Debug
					previewContainer.append('<span class="ms-2 text-muted">No image uploaded</span>');
				}
				modal.find('form').removeClass('was-validated'); // Reset validation
			}
		});

		// --- AJAX Add Category ---
		$('#add-category-form').on('submit', function(event) {
			event.preventDefault();
			event.stopPropagation();
			const form = $(this);
			if (!form[0].checkValidity()) { form.addClass('was-validated'); return; }

			const formData = new FormData(this); // Use FormData for file uploads
			const submitButton = form.find('button[type="submit"]');
			// Add loader if desired

			submitButton.prop('disabled', true); //.html('...');
			$('#category-alert-placeholder .alert').hide();

			$.ajax({
				type: 'POST',
				url: 'AddOperationServlet?operation=addCategory',
				data: formData,
				processData: false, // Important for FormData
				contentType: false, // Important for FormData
				dataType: 'json',
				success: function(response) {
					if (response.status === 'success') {
						showCategoryAlert(response.message, 'success');
						if (addCategoryModal) addCategoryModal.hide(); // Close modal
						$('.modal-backdrop').remove(); // Remove any elements with this class
						form[0].reset();
						form.removeClass('was-validated');

						// Add new row
						const newCat = response.newCategory;
						if (newCat && newCat.categoryId) {
							let newRowHtml = '';
							newRowHtml += '<tr class="text-center" data-category-id="' + newCat.categoryId + '">';
							newRowHtml +=   '<td><img src="' + s3BaseUrlForJs + escapeHtml(newCat.categoryImage) + '" alt="' + escapeHtml(newCat.categoryName) + '" class="category-img category-row-image"></td>';
							newRowHtml +=   '<td class="text-start category-row-name">' + escapeHtml(newCat.categoryName) + '</td>';
							newRowHtml +=   '<td class="action-buttons">';
							newRowHtml +=     '<button type="button" class="btn btn-secondary btn-sm btn-update-category" data-bs-toggle="modal" data-bs-target="#updateCategoryModal" data-category-id="' + newCat.categoryId + '" data-category-name="' + escapeHtml(newCat.categoryName) + '" data-category-image="' + escapeHtml(newCat.categoryImage) + '"><i class="fa-solid fa-edit"></i> Update</button>';
							newRowHtml +=     ' <a href="javascript:void(0);" class="btn btn-danger btn-sm category-delete-btn" role="button" data-category-id="' + newCat.categoryId + '" data-category-name="' + escapeHtml(newCat.categoryName) + '"><i class="fa-solid fa-trash-alt"></i> Delete</a>';
							newRowHtml +=   '</td>';
							newRowHtml += '</tr>';
							$('#category-table-body').append(newRowHtml);
							$('#category-no-results-row').hide();
						}
					} else {
						showCategoryAlert(response.message || 'Failed to add category.', 'danger');
					}
				},
				error: function() { showCategoryAlert('Error communicating with server.', 'danger'); },
				complete: function() { submitButton.prop('disabled', false); /* Restore button text */ }
			});
		});


		// --- AJAX Update Category ---
		$('#update-category-form').on('submit', function(event) {
			event.preventDefault();
			event.stopPropagation();
			const form = $(this);
			if (!form[0].checkValidity()) { form.addClass('was-validated'); return; }

			const formData = new FormData(this);
			const categoryId = formData.get('cid'); // Get ID from hidden input
			const submitButton = form.find('button[type="submit"]');
			// Add loader if desired

			submitButton.prop('disabled', true); //.html('...');
			$('#category-alert-placeholder .alert').hide();

			$.ajax({
				type: 'POST',
				url: 'AddOperationServlet?operation=updateCategory',
				data: formData,
				processData: false,
				contentType: false,
				dataType: 'json',
				success: function(response) {
					if (response.status === 'success') {
						showCategoryAlert(response.message, 'success');
						if (updateCategoryModal) updateCategoryModal.hide();
						$('.modal-backdrop').remove(); // Remove any elements with this class
						form.removeClass('was-validated');

						// Update table row
						const updatedCat = response.updatedCategory;
						if (updatedCat && updatedCat.categoryId == categoryId) {
							const row = $('#category-table-body tr[data-category-id="' + categoryId + '"]');
							if (row.length) {
								row.find('.category-row-name').text(updatedCat.categoryName);
								row.find('.category-row-image').attr('src', s3BaseUrlForJs + updatedCat.categoryImage).attr('alt', updatedCat.categoryName);
								// Update data attributes on buttons within the row too!
								const updateBtn = row.find('.btn-update-category');
								updateBtn.data('category-name', updatedCat.categoryName);
								updateBtn.data('category-image', updatedCat.categoryImage);
								row.find('.category-delete-btn').data('category-name', updatedCat.categoryName);
							}
						} else {
							console.warn("Update success but couldn't find row or data mismatch.");
							// Maybe force a table refresh here?
						}
					} else {
						showCategoryAlert(response.message || 'Failed to update category.', 'danger');
					}
				},
				error: function() { showCategoryAlert('Error communicating with server.', 'danger'); },
				complete: function() { submitButton.prop('disabled', false); /* Restore button text */ }
			});
		});


		// --- AJAX Delete Category ---
		$('#category-table-body').on('click', '.category-delete-btn', function(event) {
			event.preventDefault();
			const button = $(this);
			const categoryId = button.data('category-id');
			const categoryName = button.data('category-name');

			if (!confirm('Are you sure you want to delete category \'' + categoryName + '\'? This might affect products.')) {
				return;
			}

			$('#category-alert-placeholder .alert').hide();
			button.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i>');

			$.ajax({
				type: 'POST', // Or GET if your servlet handles delete via GET
				url: 'AddOperationServlet?operation=deleteCategory',
				data: { cid: categoryId },
				dataType: 'json',
				success: function(response) {
					if (response.status === 'success' && response.deletedCategoryId == categoryId) {
						showCategoryAlert(response.message, 'success');
						button.closest('tr').fadeOut(400, function() {
							$(this).remove();
							if ($('#category-table-body tr:not(#category-no-results-row)').length === 0) {
								$('#category-no-results-row').show();
							}
						});
					} else {
						showCategoryAlert(response.message || 'Could not delete category.', 'danger');
						button.prop('disabled', false).html('<i class="fa-solid fa-trash-alt"></i> Delete');
					}
				},
				error: function() {
					showCategoryAlert('Error communicating with server.', 'danger');
					button.prop('disabled', false).html('<i class="fa-solid fa-trash-alt"></i> Delete');
				}
			});
		});


	}); // End $(document).ready
</script>

</body>
</html>