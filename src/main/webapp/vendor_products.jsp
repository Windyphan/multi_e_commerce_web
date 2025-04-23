<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.dao.ProductDao"%>
<%@page import="com.phong.dao.CategoryDao"%>
<%@page import="com.phong.entities.Product"%>
<%@page import="com.phong.entities.Category"%>
<%@page import="com.phong.entities.Vendor"%>
<%@page import="com.phong.entities.Message"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
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

    int vendorId = activeVendor.getVendorId();

    // Fetch THIS vendor's products
    ProductDao productDao = new ProductDao();
    List<Product> vendorProductList = productDao.getAllProductsByVendorId(vendorId);

    // Fetch Categories FOR THE ADD PRODUCT MODAL dropdown
    CategoryDao categoryDaoForVendorProductsPage = new CategoryDao();
    List<Category> categoryListForVendorProducts = categoryDaoForVendorProductsPage.getAllCategories();
    Map<Integer, String> categoryNameMap = new HashMap<>(); // Also build map for display

    if(categoryListForVendorProducts != null) {
        for(Category cat : categoryListForVendorProducts) {
            categoryNameMap.put(cat.getCategoryId(), cat.getCategoryName());
        }
    } else {
        categoryListForVendorProducts = Collections.emptyList(); // Ensure not null for modal loop
        pageContext.setAttribute("errorMessage", "Could not load category list for adding products.", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorType", "warning", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorClass", "alert-warning", PageContext.SESSION_SCOPE);
    }

    // Handle product fetch error
    if (vendorProductList == null) {
        vendorProductList = Collections.emptyList();
        pageContext.setAttribute("errorMessage", "Could not retrieve your product list.", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
        pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
    }

    // Make data available for EL
    request.setAttribute("vendorProducts", vendorProductList);
    request.setAttribute("vendorCategoryList", categoryListForVendorProducts); // For the modal dropdown
    request.setAttribute("categoryNames", categoryNameMap); // For displaying category name in table

%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Your Products - Phong Shop Vendor</title>
    <%@include file="Components/common_css_js.jsp"%>
    <style>
        /* Reuse styles from admin display pages if desired */
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
            font-size: 0.95rem;
        }
        .product-img-sm {
            width: 55px;
            height: 55px;
            object-fit: contain;
            border-radius: 4px;
            background-color: #fff;
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
        .no-products-found {
            padding: 3rem 1rem;
            text-align: center;
        }
        .no-products-found img {
            max-width: 150px;
            opacity: 0.7;
            margin-bottom: 1rem;
        }
        .no-products-found h4 {
            color: #6c757d;
        }
    </style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar (Ensure it adapts for vendor context) --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

    <div class="page-header">
        <h2>Manage Your Products</h2>
        <%-- Button to trigger the Add Product modal --%>
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#add-product-vendor"> <%-- Use unique ID --%>
            <i class="fa-solid fa-plus"></i> Add New Product
        </button>
    </div>

    <%-- Display Messages --%>
    <%@include file="Components/alert_message.jsp"%>

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
                    <tbody>
                    <%-- Check if list is empty --%>
                    <c:if test="${empty vendorProducts}">
                        <tr>
                            <td colspan="7" class="text-center text-muted p-4">You haven't added any products yet.</td>
                        </tr>
                    </c:if>

                    <%-- Loop through vendor's products --%>
                    <c:forEach var="product" items="${vendorProducts}">
                        <tr class="text-center">
                            <td>
                                <img src="${s3BaseUrl}${product.productImages}"
                                     alt="${product.productName}" class="product-img-sm">
                            </td>
                            <td class="text-start product-name">
                                <c:out value="${product.productName}"/>
                            </td>
                            <td class="text-start product-category">
                                <c:out value="${categoryNames[product.categoryId]}"/>
                                <c:if test="${empty categoryNames[product.categoryId]}">
                                    <span class="text-muted fst-italic">N/A</span>
                                </c:if>
                            </td>
                            <td>
                                <fmt:setLocale value="en_GB"/>
                                <fmt:formatNumber value="${product.productPrice}" type="currency" currencySymbol="£"/> <%-- Display original price --%>
                            </td>
                            <td><c:out value="${product.productQuantity}"/></td>
                            <td><c:out value="${product.productDiscount}"/>%</td>
                            <td class="action-buttons">
                                    <%-- Link to VENDOR Update Page --%>
                                <a href="vendor_update_product.jsp?pid=${product.productId}"
                                   role="button" class="btn btn-secondary btn-sm">
                                    <i class="fa-solid fa-edit"></i> Edit
                                </a>
                                    <%-- Link to VENDOR Delete Servlet with confirmation --%>
                                <a href="VendorProductServlet?pid=${product.productId}&operation=deleteProduct" <%-- Point to Vendor servlet --%>
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
</main>

<%-- Footer --%>
<%@include file="footer.jsp"%>

<%-- Include the Add Product Modal (using a unique ID) --%>
<%-- This requires 'vendorCategoryList' to be available --%>
<%@include file="Components/vendor_add_product_modal.jsp"%>

<script>
    // Standard Bootstrap validation script
    (() => {
        'use strict'
        const forms = document.querySelectorAll('.needs-validation')
        Array.from(forms).forEach(form => {
            form.addEventListener('submit', event => {
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