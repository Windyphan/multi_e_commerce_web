<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.dao.VendorDao"%>
<%@page import="com.phong.dao.ProductDao"%>
<%@page import="com.phong.dao.WishlistDao"%>
<%@page import="com.phong.entities.Vendor"%>
<%@page import="com.phong.entities.Product"%>
<%@page import="com.phong.entities.User"%>
<%@page import="com.phong.entities.Wishlist"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.stream.Collectors"%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Data Fetching and Validation --%>
<%
    // Get active user (if any) for wishlist check
    User activeUserForVendorStore = (User) session.getAttribute("activeUser");

    // Get Vendor ID from request and validate
    Vendor vendor = null;
    int vendorId = 0;
    String vidParam = request.getParameter("vid");
    String errorMessage = null;
    List<Product> vendorProductList = Collections.emptyList(); // Default to empty

    if (vidParam != null && !vidParam.trim().isEmpty()) {
        try {
            vendorId = Integer.parseInt(vidParam.trim());
            if (vendorId > 0) {
                VendorDao vendorDao = new VendorDao();
                vendor = vendorDao.getVendorById(vendorId);

                if (vendor == null) {
                    errorMessage = "Vendor not found.";
                } else if (!vendor.isApproved()) {
                    // Optional: Decide if you want to show unapproved vendor pages?
                    // For now, treat as not found for public view
                    errorMessage = "Vendor not found."; // Or "Vendor not active."
                    vendor = null; // Don't display details
                } else {
                    // Vendor found and approved, now fetch their products
                    ProductDao productDao = new ProductDao();
                    List<Product> fetchedList = productDao.getAllProductsByVendorId(vendorId);
                    if (fetchedList != null) {
                        vendorProductList = fetchedList;
                    } else {
                        // Error fetching products, vendor details still available
                        pageContext.setAttribute("errorMessage", "Could not load products for this vendor.", PageContext.SESSION_SCOPE);
                        pageContext.setAttribute("errorType", "warning", PageContext.SESSION_SCOPE);
                        pageContext.setAttribute("errorClass", "alert-warning", PageContext.SESSION_SCOPE);
                    }
                }
            } else {
                errorMessage = "Invalid Vendor ID specified.";
            }
        } catch (NumberFormatException e) {
            errorMessage = "Invalid Vendor ID format.";
        } catch (Exception e) {
            System.err.println("Error fetching vendor/product details: " + e.getMessage());
            e.printStackTrace();
            errorMessage = "Could not load vendor details or products.";
        }
    } else {
        errorMessage = "No Vendor ID specified.";
    }

    // If vendor wasn't found/approved, set vendor object to null for EL checks
    if (vendor == null && errorMessage != null) {
        pageContext.setAttribute("errorMessage", errorMessage, PageContext.SESSION_SCOPE);
        // Optionally redirect immediately, or let the JSP handle the empty vendor case
        // response.sendRedirect("index.jsp");
        // return;
    }


    // Fetch user's wishlist efficiently (only if logged in)
    Set<Integer> userWishlistProductIds = new HashSet<>();
    if (activeUserForVendorStore != null) {
        WishlistDao wishlistDao = new WishlistDao();
        List<Wishlist> userWishlist = wishlistDao.getListByUserId(activeUserForVendorStore.getUserId());
        if (userWishlist != null) {
            userWishlistProductIds = userWishlist.stream()
                    .map(Wishlist::getProductId)
                    .collect(Collectors.toSet());
        }
    }

    // Set attributes for EL access
    request.setAttribute("vendor", vendor); // This might be null if not found/approved
    request.setAttribute("vendorProducts", vendorProductList);
    request.setAttribute("userWishlistPids", userWishlistProductIds);

%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%-- Dynamic Title --%>
    <title>
        <c:choose>
            <c:when test="${not empty vendor}"><c:out value="${vendor.shopName}"/> - Vendor Storefront</c:when>
            <c:otherwise>Vendor Not Found</c:otherwise>
        </c:choose>
        - Phong Shop
    </title>
    <%@include file="Components/common_css_js.jsp"%>
    <style>
        /* Reuse styles from previous refactors or add specific ones */
        body { background-color: #f8f9fa; }
        .vendor-header {
            background-color: #ffffff;
            padding: 2rem;
            margin-bottom: 2rem;
            border-radius: 0.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            text-align: center; /* Center header content */
        }
        .vendor-header h2 {
            font-weight: 600;
            color: #343a40;
            margin-bottom: 0.5rem;
        }
        .vendor-header p { /* For optional description */
            color: #6c757d;
            max-width: 600px;
            margin: 0 auto 1rem auto; /* Center description */
        }
        /* Reuse product card styles */
        .product-card { position: relative; border: 1px solid #e9ecef; transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out; background-color: #fff; border-radius: 0.375rem; overflow: hidden; }
        .product-card:hover { transform: translateY(-5px); box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1); }
        .product-card a { text-decoration: none; color: #212529; }
        .product-card a:hover { text-decoration: none; }
        .product-card .card-img-container { height: 220px; display: flex; align-items: center; justify-content: center; padding: 15px; overflow: hidden; background-color: #f8f9fa; }
        .product-card .card-img-top { max-height: 100%; max-width: 100%; object-fit: contain; transition: transform 0.3s ease; }
        .product-card:hover .card-img-top { transform: scale(1.05); }
        .product-card .card-body { padding: 1rem; text-align: center; }
        .product-card .card-title { font-size: 1rem; font-weight: 600; margin-bottom: 0.5rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #343a40; }
        .product-card .card-title:hover { color: #0d6efd; }
        .product-card .price-container { margin-top: 0.75rem; font-size: 0.9rem; line-height: 1.5; }
        .product-card .price-discounted { font-size: 1.15rem; font-weight: 700; color: #dc3545; }
        .product-card .price-original { text-decoration: line-through; color: #6c757d; margin-left: 0.5rem; font-size: 0.9em; }
        .product-card .discount-badge { color: #198754; font-weight: 600; margin-left: 0.5rem; font-size: 0.85em; }
        /* Wishlist styles */
        .wishlist-icon-container { position: absolute; top: 10px; right: 10px; z-index: 10; }
        .wishlist-btn { background-color: rgba(255, 255, 255, 0.8); border: 1px solid #eee; border-radius: 50%; width: 35px; height: 35px; display: inline-flex; align-items: center; justify-content: center; padding: 0; box-shadow: 0 1px 3px rgba(0,0,0,0.1); transition: background-color 0.2s ease; }
        .wishlist-btn:hover { background-color: rgba(255, 255, 255, 1); border-color: #ddd; }
        .wishlist-btn i { font-size: 1rem; line-height: 1; }
        .wishlist-btn .fa-heart.in-wishlist { color: #dc3545; }
        .wishlist-btn .fa-heart.not-in-wishlist { color: #adb5bd; }
        .wishlist-btn:hover .fa-heart.not-in-wishlist { color: #6c757d; }
        .no-products-found { padding: 3rem 1rem; text-align: center; }
        .no-products-found img { max-width: 150px; opacity: 0.7; margin-bottom: 1rem; }
        .no-products-found h4 { color: #6c757d; }
    </style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

    <%-- Display Messages --%>
    <%@include file="Components/alert_message.jsp"%>

    <%-- Check if Vendor was found and approved --%>
    <c:choose>
        <c:when test="${not empty vendor}">
            <%-- Vendor Header --%>
            <div class="vendor-header">
                    <%-- Optional Vendor Logo:
                    <c:if test="${not empty vendor.logoImage}">
                       <img src="${s3BaseUrl}${vendor.logoImage}" alt="${vendor.shopName} Logo" style="max-width: 100px; margin-bottom: 1rem;">
                    </c:if>
                    --%>
                <h2><c:out value="${vendor.shopName}"/></h2>
                    <%-- Optional Vendor Description:
                    <c:if test="${not empty vendor.description}">
                        <p><c:out value="${vendor.description}"/></p>
                    </c:if>
                     --%>
                    <%-- Optional Contact Info--%>
                        <p class="small">
                            Contact: <c:out value="${not empty vendor.businessEmail ? vendor.businessEmail : 'N/A'}"/>
                            <c:if test="${not empty vendor.businessPhone}"> | Phone: <c:out value="${vendor.businessPhone}"/></c:if>
                        </p>
            </div>

            <%-- Product Grid for this Vendor --%>
            <h4 class="mb-3">Products from <c:out value="${vendor.shopName}"/></h4>
            <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
                <c:if test="${empty vendorProducts}">
                    <div class="col-12">
                        <div class="no-products-found">
                                <%-- Use a slightly different icon/message --%>
                            <i class="fas fa-search fa-4x text-muted mb-3"></i>
                            <h4>This vendor currently has no products listed.</h4>
                            <a href="products.jsp" class="btn btn-outline-primary mt-3">View All Products</a>
                        </div>
                    </div>
                </c:if>

                    <%-- Loop through vendor's products --%>
                <c:forEach var="product" items="${vendorProducts}">
                    <div class="col">
                        <div class="card h-100 product-card">
                            <div class="wishlist-icon-container">
                                <c:choose>
                                    <c:when test="${empty sessionScope.activeUser}"><a href="login.jsp" class="btn wishlist-btn" title="Login to add to wishlist"><i class="fa-regular fa-heart not-in-wishlist"></i></a></c:when>
                                    <c:otherwise>
                                        <c:set var="isInWishlist" value="${userWishlistPids.contains(product.productId)}"/>
                                        <c:choose>
                                            <c:when test="${isInWishlist}"><a href="WishlistServlet?pid=${product.productId}&op=remove" class="btn wishlist-btn" title="Remove from Wishlist"><i class="fa-solid fa-heart in-wishlist"></i></a></c:when>
                                            <c:otherwise><a href="WishlistServlet?pid=${product.productId}&op=add" class="btn wishlist-btn" title="Add to Wishlist"><i class="fa-regular fa-heart not-in-wishlist"></i></a></c:otherwise>
                                        </c:choose>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <a href="viewProduct.jsp?pid=${product.productId}">
                                <div class="card-img-container">
                                    <img src="${s3BaseUrl}${product.productImages}" class="card-img-top" alt="${product.productName}">
                                </div>
                                <div class="card-body">
                                    <h5 class="card-title" title="${product.productName}"><c:out value="${product.productName}"/></h5>
                                    <div class="price-container">
                                        <span class="price-discounted"><fmt:formatNumber value="${product.productPriceAfterDiscount}" type="currency" currencySymbol="£"/></span>
                                        <c:if test="${product.productDiscount > 0}">
                                            <span class="price-original"><fmt:formatNumber value="${product.productPrice}" type="currency" currencySymbol="£"/></span>
                                            <span class="discount-badge">${product.productDiscount}% off</span>
                                        </c:if>
                                    </div>
                                </div>
                            </a>
                        </div> <%-- End card --%>
                    </div> <%-- End col --%>
                </c:forEach> <%-- End product loop --%>
            </div> <%-- End row --%>

        </c:when>
        <c:otherwise>
            <%-- Vendor not found or not approved - Display error message if set --%>
            <div class="alert alert-warning text-center" role="alert">
                Sorry, the requested vendor could not be found or is not currently active.
                <a href="index.jsp" class="alert-link">Return to Homepage</a>.
            </div>
        </c:otherwise>
    </c:choose>

</main> <%-- End main wrapper --%>

<%-- Footer --%>
<%@include file="Components/footer.jsp"%>

</body>
</html>