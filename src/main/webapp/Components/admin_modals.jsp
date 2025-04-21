<%-- Components/admin_modals.jsp --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%-- Add page directive only if this file is accessed directly (unlikely) --%>
 <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modal - Admin modal</title>
    <%@include file="common_css_js.jsp"%>
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
</head>

<body>
<!-- Add Category Modal -->
<div class="modal fade" id="add-category" tabindex="-1" aria-labelledby="addCategoryModalLabel" aria-hidden="true" data-bs-theme="light">
    <div class="modal-dialog modal-dialog-centered"> <%-- Vertically center --%>
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="addCategoryModalLabel">Add New Category</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="AddOperationServlet" method="post" enctype="multipart/form-data" class="needs-validation" novalidate>
                <div class="modal-body">
                    <input type="hidden" name="operation" value="addCategory">
                    <div class="mb-3">
                        <label for="categoryNameInputModal" class="form-label">Category Name</label> <%-- Unique ID if needed --%>
                        <input type="text" name="category_name" id="categoryNameInputModal" placeholder="Enter category name" class="form-control" required>
                        <div class="invalid-feedback">Please enter a category name.</div>
                    </div>
                    <div class="mb-3">
                        <label for="categoryImageInputModal" class="form-label">Category Image</label> <%-- Unique ID --%>
                        <input class="form-control" type="file" name="category_img" id="categoryImageInputModal" required accept="image/*">
                        <div class="invalid-feedback">Please select an image file.</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-plus"></i> Add Category</button>
                </div>
            </form>
        </div>
    </div>
</div>
<!-- End Add Category Modal -->

<!-- Add Product Modal -->
<div class="modal fade" id="add-product" tabindex="-1" aria-labelledby="addProductModalLabel" aria-hidden="true" data-bs-theme="light">
    <div class="modal-dialog modal-lg modal-dialog-centered"> <%-- Large and centered --%>
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="addProductModalLabel">Add New Product</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="AddOperationServlet" method="post" name="addProductModalForm" enctype="multipart/form-data" class="needs-validation" novalidate>
                <div class="modal-body">
                    <input type="hidden" name="operation" value="addProduct">
                    <div class="mb-3">
                        <label for="productNameInputModal" class="form-label">Product Name</label>
                        <input type="text" name="name" id="productNameInputModal" placeholder="Enter product name" class="form-control" required>
                        <div class="invalid-feedback">Please enter a product name.</div>
                    </div>
                    <div class="mb-3">
                        <label for="productDescInputModal" class="form-label">Product Description</label>
                        <textarea class="form-control" name="description" id="productDescInputModal" rows="3" placeholder="Enter product description" required></textarea>
                        <div class="invalid-feedback">Please enter a description.</div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="productPriceInputModal" class="form-label">Unit Price (£)</label>
                            <input type="number" name="price" id="productPriceInputModal" placeholder="e.g., 49.99" class="form-control" required min="0" step="0.01">
                            <div class="invalid-feedback">Please enter a valid price (0 or more).</div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="productDiscountInputModal" class="form-label">Discount (%)</label>
                            <%-- Using oninput for instant feedback on range --%>
                            <input type="number" name="discount" id="productDiscountInputModal" placeholder="e.g., 10 (0-100)" class="form-control" min="0" max="100" value="0" oninput="validateDiscountInput(this)">
                            <div class="invalid-feedback">Discount must be between 0 and 100.</div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="productQuantityInputModal" class="form-label">Stock Quantity</label>
                            <input type="number" name="quantity" id="productQuantityInputModal" placeholder="Enter stock quantity" class="form-control" required min="0">
                            <div class="invalid-feedback">Please enter a valid quantity (0 or more).</div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="productCategorySelectModal" class="form-label">Category</label>
                            <select name="categoryType" id="productCategorySelectModal" class="form-select" required>
                                <option value="" selected disabled>-- Select Category --</option>
                                <%-- Use JSTL to populate options - Relies on 'navbarCategoryList' being in scope --%>
                                <c:if test="${not empty navbarCategoryList}">
                                    <c:forEach var="cat" items="${navbarCategoryList}">
                                        <option value="${cat.categoryId}">${cat.categoryName}</option>
                                    </c:forEach>
                                </c:if>
                                <%-- Fallback or error if list is empty/null --%>
                                <c:if test="${empty navbarCategoryList}">
                                    <option value="" disabled>Error loading categories</option>
                                </c:if>
                            </select>
                            <div class="invalid-feedback">Please select a category.</div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="productPhotoInputModal" class="form-label">Product Image</label>
                        <input type="file" name="photo" id="productPhotoInputModal" class="form-control" required accept="image/*">
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
<!-- End Add Product Modal -->

<script type="text/javascript">
    // Improved validation function
    function validateDiscountInput(inputElement) {
        // Remove non-digit characters except potential decimal (though type=number helps)
        // inputElement.value = inputElement.value.replace(/[^0-9]/g, '');
        const discountValue = parseInt(inputElement.value, 10);

        // Check if the value is within the range 0-100 OR if the field is empty
        if (inputElement.value === '' || (!isNaN(discountValue) && discountValue >= 0 && discountValue <= 100)) {
            inputElement.setCustomValidity(''); // Field is valid or empty (let 'required' handle empty if needed)
            inputElement.classList.remove('is-invalid'); // Explicitly remove invalid state if correcting
        } else {
            inputElement.setCustomValidity('Discount must be between 0 and 100.');
            inputElement.classList.add('is-invalid'); // Explicitly add invalid state
        }
        // Note: We don't return false/true here, setCustomValidity handles form submission blocking
    }

    // Bootstrap validation trigger (can be placed in common_js file if preferred)
    (() => {
        'use strict'
        const forms = document.querySelectorAll('.needs-validation')
        Array.from(forms).forEach(form => {
            form.addEventListener('submit', event => {
                // Manual check for discount validity just before submit
                const discountInput = form.querySelector('#productDiscountInputModal');
                if (discountInput) {
                    validateDiscountInput(discountInput); // Ensure validity state is set
                }

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