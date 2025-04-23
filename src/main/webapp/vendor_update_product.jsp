<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.entities.Vendor"%>
<%@page import="com.phong.entities.Message"%>
<%@page import="com.phong.entities.Product"%>
<%@page import="com.phong.dao.ProductDao"%>
<%@page import="com.phong.entities.Category"%>
<%@page import="com.phong.dao.CategoryDao"%> <%-- Need CategoryDao --%>
<%@page import="java.util.List"%>
<%@page import="java.util.Collections"%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check & Data Fetching --%>
<%
    Vendor activeVendor = (Vendor) session.getAttribute("activeVendor");
    // Redirect if not logged in as vendor or if vendor is not approved
    if (activeVendor == null || !activeVendor.isApproved()) {
        pageContext.setAttribute("errorMessage", "Access Denied. Please log in as an approved vendor.", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
        response.sendRedirect("vendor_login.jsp");
        return;
    }

    // Get Product ID from request and validate
    Product productToUpdate = null;
    int productId = 0;
    String pidParam = request.getParameter("pid");
    String errorMessage = null;
    List<Category> categoryListForVendorUpdateProducts = Collections.emptyList(); // Initialize

    if (pidParam != null && !pidParam.trim().isEmpty()) {
        try {
            productId = Integer.parseInt(pidParam.trim());
            if (productId > 0) {
                ProductDao productDao = new ProductDao();
                productToUpdate = productDao.getProductsByProductId(productId);

                // *** CRITICAL OWNERSHIP CHECK ***
                if (productToUpdate == null) {
                    errorMessage = "Product not found.";
                } else if (productToUpdate.getVendorId() != activeVendor.getVendorId()) {
                    errorMessage = "You do not have permission to edit this product.";
                    productToUpdate = null; // Prevent display/edit
                } else {
                    // Product found and belongs to vendor, fetch categories for dropdown
                    CategoryDao categoryDaoForVendorUpdateProducts = new CategoryDao();
                    categoryListForVendorUpdateProducts = categoryDaoForVendorUpdateProducts.getAllCategories();
                    if (categoryListForVendorUpdateProducts == null) categoryListForVendorUpdateProducts = Collections.emptyList();
                }
            } else {
                errorMessage = "Invalid Product ID specified.";
            }
        } catch (NumberFormatException e) {
            errorMessage = "Invalid Product ID format.";
        } catch (Exception e) {
            System.err.println("Error fetching product/categories for update: " + e.getMessage());
            e.printStackTrace();
            errorMessage = "Could not load product details or categories.";
        }
    } else {
        errorMessage = "No Product ID specified.";
    }

    // Redirect if product not found/invalid/not owned
    if (productToUpdate == null) { // Redirect if product is null (covers not found, permission denied, error)
        pageContext.setAttribute("errorMessage", (errorMessage != null ? errorMessage : "Could not load product for update."), PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
        response.sendRedirect("vendor_products.jsp"); // Go back to vendor product list
        return;
    }

    // Make data available for EL
    request.setAttribute("product", productToUpdate);
    request.setAttribute("vendorCategoryList", categoryListForVendorUpdateProducts); // Use same name as modal for consistency

%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Product - <c:out value="${product.productName}"/> - Phong Shop</title>
    <%@include file="Components/common_css_js.jsp"%>
    <style>
        /* Reuse styles from admin update/add pages or define new ones */
        body { background-color: #f8f9fa; }
        .update-card {
            border: none; border-radius: 0.5rem; box-shadow: 0 3px 10px rgba(0,0,0,0.07);
            max-width: 800px; margin: 2rem auto;
        }
        .update-card .card-header { background-color: #e9ecef; font-weight: 600; padding: 1rem 1.25rem; border-bottom: 1px solid #dee2e6; text-align: center; }
        .update-card .card-header h3 { margin-bottom: 0; font-size: 1.4rem; }
        .form-label { font-weight: 600; margin-bottom: 0.5rem; color: #495057; }
        .current-img-preview { width: 70px; height: 70px; object-fit: contain; border: 1px solid #eee; padding: 3px; background-color: #fff; border-radius: 4px; margin-left: 10px; vertical-align: middle; }
        .current-img-label { font-size: 0.9rem; color: #6c757d; }
        .update-card .card-footer { background-color: #f8f9fa; }
    </style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Vendor Navbar --%>
<%@include file="Components/navbar.jsp"%> <%-- Make sure navbar adapts --%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

    <div class="card update-card">
        <div class="card-header">
            <h3>Edit Product Details</h3>
        </div>
        <%-- Form posts to VendorProductServlet --%>
        <form action="VendorProductServlet" method="post" enctype="multipart/form-data" name="updateVendorProductForm" class="needs-validation" novalidate onsubmit="return validateDiscountUpdate()">
            <%-- Hidden fields --%>
            <input type="hidden" name="operation" value="updateProduct">
            <input type="hidden" name="pid" value="${product.productId}">
            <input type="hidden" name="image" value="${product.productImages}"> <%-- Existing image name --%>
            <input type="hidden" name="category" value="${product.categoryId}"> <%-- Existing category --%>

            <div class="card-body p-4">
                <%-- Display Potential Messages --%>
                <%@include file="Components/alert_message.jsp"%>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="productNameInput" class="form-label">Product Name</label>
                        <input type="text" class="form-control" id="productNameInput" name="name" value="<c:out value='${product.productName}'/>" required>
                        <div class="invalid-feedback">Product name is required.</div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="productPriceInput" class="form-label">Unit Price (£)</label>
                        <input type="number" class="form-control" id="productPriceInput" name="price" value="${product.productPrice}" required min="0" step="0.01">
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
                        <input type="number" class="form-control" id="productQuantityInput" name="quantity" value="${product.productQuantity}" required min="0">
                        <div class="invalid-feedback">Please enter a valid quantity (>= 0).</div>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="productDiscountInputUpdate" class="form-label">Discount (%)</label>
                        <input type="number" class="form-control" id="productDiscountInputUpdate" name="discount" value="${product.productDiscount}" min="0" max="100" oninput="validateDiscountInputUpdate(this)">
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
                        <label for="productCategorySelectUpdate" class="form-label">Category</label>
                        <select name="categoryType" id="productCategorySelectUpdate" class="form-select" required>
                            <option value="" disabled>-- Select Category --</option>
                            <c:forEach var="cat" items="${vendorCategoryList}"> <%-- Use list prepared earlier --%>
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
                            <img src="${s3BaseUrl}${product.productImages}"
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
                <a href="vendor_products.jsp" class="btn btn-secondary me-2">
                    <i class="fa-solid fa-times"></i> Cancel
                </a>
                <button type="submit" class="btn btn-primary">
                    <i class="fa-solid fa-save"></i> Update Product
                </button>
            </div>
        </form>
    </div>
</main>

<%-- Footer --%>
<%@include file="footer.jsp"%>

<script>
    // Validation function for discount (can be shared)
    function validateDiscountInputUpdate(inputElement) {
        const discountValue = parseInt(inputElement.value, 10);
        if (inputElement.value === '' || (!isNaN(discountValue) && discountValue >= 0 && discountValue <= 100)) {
            inputElement.setCustomValidity('');
            inputElement.classList.remove('is-invalid');
        } else {
            inputElement.setCustomValidity('Discount must be between 0 and 100.');
            inputElement.classList.add('is-invalid');
        }
    }

    // Bootstrap validation trigger
    (() => {
        'use strict'
        const forms = document.querySelectorAll('.needs-validation')
        Array.from(forms).forEach(form => {
            form.addEventListener('submit', event => {
                const discountInput = form.querySelector('#productDiscountInputUpdate');
                if (discountInput) validateDiscountInputUpdate(discountInput);

                if (!form.checkValidity()) {
                    event.preventDefault()
                    event.stopPropagation()
                }
                form.classList.add('was-validated')
            }, false)
        })
    })()

    const discountFieldUpdate = document.getElementById('productDiscountInputUpdate');
    if(discountFieldUpdate) discountFieldUpdate.addEventListener('blur', () => validateDiscountInputUpdate(discountFieldUpdate));
</script>

</body>
</html>