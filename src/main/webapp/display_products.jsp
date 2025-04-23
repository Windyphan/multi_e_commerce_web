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
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

	<div class="page-header">
		<h2>Manage Products</h2>
	</div>

	<%-- Display Messages --%>
	<%@include file="Components/alert_message.jsp"%>

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
								<a href="update_product.jsp?pid=${product.productId}"
								   role="button" class="btn btn-secondary btn-sm">
									<i class="fa-solid fa-edit"></i> Update
								</a>
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

<%-- Footer --%>
<%@include file="footer.jsp"%>

</body>
</html>