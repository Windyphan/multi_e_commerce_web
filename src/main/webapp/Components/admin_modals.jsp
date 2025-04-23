<%-- Components/admin_modals.jsp --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
        // Note: don't return false/true here, setCustomValidity handles form submission blocking
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