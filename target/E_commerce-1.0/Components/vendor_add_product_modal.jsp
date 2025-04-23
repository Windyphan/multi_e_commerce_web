<%-- Components/vendor_add_product_modal.jsp --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- No page directives needed for an include file --%>
<%-- Add page directive only if this file is accessed directly (unlikely) --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    body {
        background-color: #f8f9fa;
    }
    .modal-header {
        background-color: #f8f9fa; /* Light grey header */
        border-bottom: 1px solid #dee2e6;
    }
    .modal-title {
        font-weight: 500;
    }
    .modal-body {
        background-color: #ffffff; /* Ensure body is white */
        padding: 1.5rem; /* Add more padding */
    }
    .modal-body .form-label { /* Style labels within modals */
        font-weight: 600;
        font-size: 0.95rem;
        color: #495057;
        margin-bottom: 0.5rem;
    }
    .modal-body .form-control{
        background-color: #ffffff; /* Light grey footer */
        font-size: 0.95rem; /* Slightly smaller font in modals */
        border-radius: 0.375rem;
        border: 1px solid #ced4da;
    }
    .modal-body .form-select {
        background-color:  #ffffff;
        font-size: 0.95rem; /* Slightly smaller font in modals */
        border-radius: 0.375rem;
        border: 1px solid #ced4da;
    }
    .modal-footer {
        background-color: #f8f9fa; /* Light grey footer */
        border-top: 1px solid #dee2e6;
    }
    .modal-footer .btn {
        font-weight: 500;
    }
</style>
<!-- Add Product Modal (Vendor) -->
<div class="modal fade" id="add-product-vendor" tabindex="-1" aria-labelledby="addProductVendorModalLabel" aria-hidden="true" data-bs-theme="light"> <%-- Unique ID, Light theme --%>
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="addProductVendorModalLabel">Add New Product to Your Shop</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <%-- Form posts to VendorProductServlet --%>
            <form action="VendorProductServlet" method="post" name="addProductVendorForm" enctype="multipart/form-data" class="needs-validation" novalidate>
                <div class="modal-body">
                    <input type="hidden" name="operation" value="addProduct">
                    <%-- Vendor ID is automatically added by the servlet based on logged-in vendor --%>

                    <div class="mb-3">
                        <label for="productNameInputModalVendor" class="form-label">Product Name</label>
                        <input type="text" name="name" id="productNameInputModalVendor" placeholder="Enter product name" class="form-control" required>
                        <div class="invalid-feedback">Please enter a product name.</div>
                    </div>
                    <div class="mb-3">
                        <label for="productDescInputModalVendor" class="form-label">Product Description</label>
                        <textarea class="form-control" name="description" id="productDescInputModalVendor" rows="3" placeholder="Enter product description" required></textarea>
                        <div class="invalid-feedback">Please enter a description.</div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="productPriceInputModalVendor" class="form-label">Your Price (£)</label>
                            <input type="number" name="price" id="productPriceInputModalVendor" placeholder="e.g., 49.99" class="form-control" required min="0" step="0.01">
                            <div class="invalid-feedback">Please enter a valid price (0 or more).</div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="productDiscountInputModalVendor" class="form-label">Discount (%)</label>
                            <input type="number" name="discount" id="productDiscountInputModalVendor" placeholder="e.g., 10 (0-100)" class="form-control" min="0" max="100" value="0">
                            <div class="invalid-feedback">Discount must be between 0 and 100.</div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="productQuantityInputModalVendor" class="form-label">Stock Quantity</label>
                            <input type="number" name="quantity" id="productQuantityInputModalVendor" placeholder="Enter stock quantity" class="form-control" required min="0">
                            <div class="invalid-feedback">Please enter a valid quantity (0 or more).</div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="productCategorySelectModalVendor" class="form-label">Category</label>
                            <select name="categoryType" id="productCategorySelectModalVendor" class="form-select" required>
                                <option value="" selected disabled>-- Select Category --</option>
                                <%-- Uses 'vendorCategoryList' attribute set by vendor_products.jsp --%>
                                <c:if test="${not empty vendorCategoryList}">
                                    <c:forEach var="cat" items="${vendorCategoryList}">
                                        <option value="${cat.categoryId}">${cat.categoryName}</option>
                                    </c:forEach>
                                </c:if>
                                <c:if test="${empty vendorCategoryList}">
                                    <option value="" disabled>No categories available</option>
                                </c:if>
                            </select>
                            <div class="invalid-feedback">Please select a category.</div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="productPhotoInputModalVendor" class="form-label">Product Image</label>
                        <input type="file" name="photo" id="productPhotoInputModalVendor" class="form-control" required accept="image/*">
                        <div class="invalid-feedback">Please select an image file.</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-plus"></i> Add Product</button>
                </div>
            </form>
        </div>
    </div>
</div>
<!-- End Add Product Modal (Vendor) -->

<%-- JavaScript validation function (if not global) --%>
<%-- You might move validateDiscountInput to a global script if used elsewhere --%>
<script>
    function validateDiscountInput(inputElement) {
        // ... (Validation logic as before) ...
        if (inputElement.value === '' || (!isNaN(discountValue) && discountValue >= 0 && discountValue <= 100)) {
            inputElement.setCustomValidity('');
            inputElement.classList.remove('is-invalid');
        } else {
            inputElement.setCustomValidity('Discount must be between 0 and 100.');
            inputElement.classList.add('is-invalid');
        }
    }
    // Add listener if needed
    // const discountInputModal = document.getElementById('productDiscountInputModalVendor');
    // if(discountInputModal) discountInputModal.addEventListener('input', () => validateDiscountInput(discountInputModal));
</script>