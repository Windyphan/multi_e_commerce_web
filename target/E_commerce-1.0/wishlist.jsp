<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.dao.WishlistDao"%>
<%@page import="com.phong.dao.ProductDao"%>
<%@page import="com.phong.entities.Wishlist"%>
<%@page import="com.phong.entities.Product"%>
<%@page import="com.phong.entities.User"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Security Check & Data Fetching --%>
<%
  User currentUserForWishlist = (User) session.getAttribute("activeUser");
  // Security check should ideally be done on the main page including this snippet (e.g., profile.jsp)
  // If this can be accessed directly, uncomment the check:

  if (currentUserForWishlist == null) {
    pageContext.setAttribute("errorMessage", "You are not logged in! Login first!!", PageContext.SESSION_SCOPE);
    pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
    pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
    response.sendRedirect("login.jsp");
    return;
  }


  // Fetch Wishlist Items and Product Details
  List<Product> wishlistProducts = new ArrayList<>(); // List to hold full Product objects
  int wishlistSize = 0;

  if (currentUserForWishlist != null) { // Only proceed if user is logged in
    WishlistDao wishlistDao = new WishlistDao();
    ProductDao productDao = new ProductDao();
    List<Wishlist> wishlistItems = wishlistDao.getListByUserId(currentUserForWishlist.getUserId());

    if (wishlistItems != null) {
      wishlistSize = wishlistItems.size();
      for (Wishlist item : wishlistItems) {
        Product product = productDao.getProductsByProductId(item.getProductId());
        if (product != null) { // Add only if product still exists
          wishlistProducts.add(product);
        } else {
          System.err.println("Warning: Wishlist item for user " + currentUserForWishlist.getUserId() + " refers to non-existent product ID " + item.getProductId());
          // Optionally remove this stale wishlist item here?
          // wishlistDao.deleteWishlist(activeUser.getUserId(), item.getProductId());
        }
      }
    } else {
      // Handle DAO error for wishlist fetch
      pageContext.setAttribute("errorMessage", "Could not retrieve wishlist items.", PageContext.SESSION_SCOPE);
      pageContext.setAttribute("errorType", "error", PageContext.SESSION_SCOPE);
      pageContext.setAttribute("errorClass", "alert-danger", PageContext.SESSION_SCOPE);
    }
  }

  // Set attributes for EL
  request.setAttribute("wishlistProducts", wishlistProducts);
  request.setAttribute("wishlistCount", wishlistSize); // Pass the original count

%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Wishlist - Phong Shop</title>
  <%@include file="Components/common_css_js.jsp"%>
  <style>
    /* Styles specific to wishlist display */
    .wishlist-item-row td {
      vertical-align: middle;
    }
    .wishlist-item-img {
      width: 60px;
      height: 60px;
      object-fit: contain;
      margin-right: 15px;
      border: 1px solid #eee;
      padding: 3px;
      background-color: #fff;
      border-radius: 4px;
    }
    .wishlist-item-name {
      font-weight: 500;
      color: #333;
    }
    .wishlist-item-price {
      font-weight: 600;
    }
    .btn-remove-wishlist {
      font-size: 0.85rem;
      padding: 0.25rem 0.6rem;
    }
    .empty-wishlist img {
      max-width: 150px;
      opacity: 0.7;
    }
    .empty-wishlist h4 {
      margin-top: 1rem;
      color: #6c757d;
    }
  </style>
</head>

<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>
<div class="container px-0 px-md-3 py-3"> <%-- Adjust padding --%>
  <%-- Optional: Display messages if set by wishlist actions --%>
  <%-- <%@include file="Components/alert_message.jsp"%> --%>

  <%-- Check if wishlist is empty --%>
  <c:choose>
    <c:when test="${empty wishlistProducts}">
      <div class="text-center p-5 empty-wishlist">
        <img src="Images/wishlist.png" alt="Empty Wishlist"> <%-- Use forward slash --%>
        <h4 class="mt-3">Your Wishlist is Empty</h4>
        <p class="text-muted">Add items you love to your wishlist!</p>
        <a href="products.jsp" class="btn btn-outline-primary mt-3">Browse Products</a>
      </div>
    </c:when>
    <c:otherwise>
      <h4 class="mb-3">My Wishlist (<c:out value="${wishlistCount}"/>)</h4>
      <hr class="mb-4">
      <div class="table-responsive">
        <table class="table table-hover align-middle"> <%-- Use align-middle --%>
            <%-- No header needed maybe? Or a simple one --%>
            <%--
            <thead>
                 <tr class="table-light">
                      <th style="width: 10%"></th>
                      <th>Product</th>
                      <th class="text-end">Price</th>
                      <th class="text-center">Action</th>
                 </tr>
            </thead>
            --%>
          <tbody>
            <%-- Loop through products using JSTL --%>
          <c:forEach var="product" items="${wishlistProducts}">
            <tr class="wishlist-item-row">
              <td class="text-center">
                <a href="viewProduct.jsp?pid=${product.productId}">
                  <img src="${s3BaseUrl}${product.productImages}" <%-- Forward slash --%>
                       alt="${product.productName}" class="wishlist-item-img">
                </a>
              </td>
              <td>
                <a href="viewProduct.jsp?pid=${product.productId}" class="text-decoration-none wishlist-item-name">
                  <c:out value="${product.productName}"/>
                </a>
                  <%-- Optional: Add category or brief description --%>
                  <%-- <small class="d-block text-muted">Category Name</small> --%>
              </td>
              <td class="text-end wishlist-item-price">
                <fmt:setLocale value="en_GB"/>
                <fmt:formatNumber value="${product.productPriceAfterDiscount}" type="currency" currencySymbol="£"/>
              </td>
              <td class="text-center">
                  <%-- Remove button - uses JSTL for URL --%>
                  <%-- NOTE: op=delete used based on profile.jsp context, change to op=remove if needed --%>
                <a href="WishlistServlet?pid=${product.productId}&op=delete"
                   class="btn btn-outline-danger btn-sm btn-remove-wishlist" role="button"
                   title="Remove from Wishlist">
                  <i class="fa-solid fa-trash-alt"></i>
                    <%-- <span class="d-none d-md-inline">Remove</span> --%>
                </a>
              </td>
            </tr>
          </c:forEach>
          </tbody>
        </table>
      </div> <%-- End table-responsive --%>
    </c:otherwise>
  </c:choose>
</div>
<%-- Footer --%>
<%@include file="Components/footer.jsp"%>
</body>
</html>