<%-- JSTL Core tag library --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Import necessary entity (only Message used directly here, others via session EL) --%>

<%-- Set Error Page --%>
<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%--
    SECURITY CHECK using JSTL and redirecting immediately if not admin.
    This replaces the scriptlet check.
--%>
<c:if test="${empty sessionScope.activeAdmin}">
	<c:set var="errorMessage" value="You are not logged in! Login first!!" scope="session"/>
	<c:set var="errorType" value="error" scope="session"/>
	<c:set var="errorClass" value="alert-danger" scope="session"/>
	<c:redirect url="adminlogin.jsp"/>
	<%-- Use c:redirect which handles response commit; no 'return' needed --%>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Admin Dashboard - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f8f9fa; /* Light background for the whole page */
		}
		.admin-welcome {
			margin-bottom: 2rem;
		}
		.admin-welcome img {
			max-width: 150px;
			margin-bottom: 1rem;
		}
		.admin-welcome h3 {
			font-weight: 500;
			color: #343a40;
		}

		/* Dashboard Cards Styling */
		.dashboard-card {
			transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
			border: none; /* Remove default card border */
			border-radius: 0.5rem; /* Slightly more rounded */
			background-color: #ffffff; /* White background */
			box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
		}
		.dashboard-card:hover {
			transform: translateY(-5px);
			box-shadow: 0 6px 15px rgba(0, 0, 0, 0.12);
		}
		.dashboard-card a {
			text-decoration: none;
			color: #343a40; /* Dark text for title */
		}
		.dashboard-card .card-body {
			padding: 1.5rem;
		}
		.dashboard-card img {
			max-width: 65px; /* Slightly smaller icons */
			margin-bottom: 0.75rem;
			opacity: 0.8;
		}
		.dashboard-card .card-title {
			font-size: 1.2rem;
			font-weight: 600;
			margin-top: 0.5rem;
		}
		.modal-header {
			background-color: #f1f1f1; /* Light header for modals */
		}
		.modal-footer {
			background-color: #f8f9fa;
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<div class="container mt-4"> <%-- Use container for padding --%>

	<%-- Display Messages --%>
	<%@include file="Components/alert_message.jsp"%>

	<%-- Welcome Section --%>
	<div class="text-center admin-welcome">
		<img src="Images/admin.png" class="img-fluid rounded-circle mb-3" alt="Admin Icon">
		<%-- Access admin name safely from session scope --%>
		<h3>Welcome, <c:out value="${sessionScope.activeAdmin.name}"/>!</h3>
	</div>

	<%-- Dashboard Links --%>
	<div class="row g-4 justify-content-center"> <%-- g-4 for gap, justify-content-center --%>
		<div class="col-12 col-sm-6 col-md-4 col-lg-3">
			<div class="card dashboard-card text-center h-100">
				<a href="display_category.jsp">
					<div class="card-body">
						<img src="Images/categories.png" alt="Category Icon">
						<h4 class="card-title">Categories</h4>
					</div>
				</a>
			</div>
		</div>
		<div class="col-12 col-sm-6 col-md-4 col-lg-3">
			<div class="card dashboard-card text-center h-100">
				<a href="display_products.jsp">
					<div class="card-body">
						<img src="Images/products.png" alt="Product Icon">
						<h4 class="card-title">Products</h4>
					</div>
				</a>
			</div>
		</div>
		<div class="col-12 col-sm-6 col-md-4 col-lg-3">
			<div class="card dashboard-card text-center h-100">
				<a href="display_orders.jsp">
					<div class="card-body">
						<img src="Images/order.png" alt="Order Icon">
						<h4 class="card-title">Orders</h4>
					</div>
				</a>
			</div>
		</div>
		<div class="col-12 col-sm-6 col-md-4 col-lg-3">
			<div class="card dashboard-card text-center h-100">
				<a href="display_users.jsp">
					<div class="card-body">
						<img src="Images/users.png" alt="User Icon">
						<h4 class="card-title">Users</h4>
					</div>
				</a>
			</div>
		</div>
		<div class="col-12 col-sm-6 col-md-4 col-lg-3">
			<div class="card dashboard-card text-center h-100">
				<a href="display_admin.jsp">
					<div class="card-body">
						<img src="Images/add-admin.png" alt="Admin Icon">
						<h4 class="card-title">Admins</h4>
					</div>
				</a>
			</div>
		</div>
		<%-- Add more cards here if needed --%>
	</div>
	<hr class="my-4"> <%-- Add a separator --%>
</div>

<%-- Modals (Keep the existing structure, but ensure categoryList is available for Add Product) --%>

<!-- Add Category Modal -->
<div class="modal fade" id="add-category" tabindex="-1" aria-labelledby="addCategoryModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h1 class="modal-title fs-5" id="addCategoryModalLabel">Add New Category</h1>
				<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
			</div>
			<%-- Action points to the servlet --%>
			<form action="AddOperationServlet" method="post" enctype="multipart/form-data">
				<div class="modal-body">
					<input type="hidden" name="operation" value="addCategory">
					<div class="mb-3">
						<label for="categoryNameInput" class="form-label"><b>Category Name</b></label>
						<input type="text" name="category_name" id="categoryNameInput" placeholder="Enter category name" class="form-control" required>
					</div>
					<div class="mb-3">
						<label for="categoryImageInput" class="form-label"><b>Category Image</b></label>
						<input class="form-control" type="file" name="category_img" id="categoryImageInput" required accept="image/*">
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
<div class="modal fade" id="add-product" tabindex="-1" aria-labelledby="addProductModalLabel" aria-hidden="true">
	<div class="modal-dialog modal-lg">
		<div class="modal-content">
			<div class="modal-header">
				<h1 class="modal-title fs-5" id="addProductModalLabel">Add New Product</h1>
				<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
			</div>
			<%-- Action points to the servlet --%>
			<form action="AddOperationServlet" method="post" name="addProductForm" enctype="multipart/form-data" onsubmit="return validateDiscount()">
				<div class="modal-body">
					<input type="hidden" name="operation" value="addProduct">
					<div class="mb-3"> <%-- Changed to mb-3 --%>
						<label for="productNameInput" class="form-label"><b>Product Name</b></label>
						<input type="text" name="name" id="productNameInput" placeholder="Enter product name" class="form-control" required>
					</div>
					<div class="mb-3"> <%-- Changed to mb-3 --%>
						<label for="productDescInput" class="form-label"><b>Product Description</b></label>
						<textarea class="form-control" name="description" id="productDescInput" rows="4" placeholder="Enter product description" required></textarea>
					</div>
					<div class="row">
						<div class="col-md-6 mb-3"> <%-- Changed to mb-3 --%>
							<label for="productPriceInput" class="form-label"><b>Unit Price (£)</b></label>
							<input type="number" name="price" id="productPriceInput" placeholder="e.g., 199.99" class="form-control" required min="0" step="0.01">
						</div>
						<div class="col-md-6 mb-3"> <%-- Changed to mb-3 --%>
							<label for="productDiscountInput" class="form-label"><b>Discount (%)</b></label>
							<input type="number" name="discount" id="productDiscountInput" placeholder="e.g., 10 (0-100)" class="form-control" min="0" max="100" value="0">
						</div>
					</div>
					<div class="row">
						<div class="col-md-6 mb-3"> <%-- Changed to mb-3 --%>
							<label for="productQuantityInput" class="form-label"><b>Stock Quantity</b></label>
							<input type="number" name="quantity" id="productQuantityInput" placeholder="Enter stock quantity" class="form-control" required min="0">
						</div>
						<div class="col-md-6 mb-3"> <%-- Changed to mb-3 --%>
							<label for="productCategorySelect" class="form-label"><b>Category</b></label>
							<select name="categoryType" id="productCategorySelect" class="form-select" required> <%-- Use form-select --%>
								<option value="" selected disabled>-- Select Category --</option>
								<%-- Use JSTL to populate options --%>
								<c:if test="${not empty navbarCategoryList}">
									<c:forEach var="cat" items="${navbarCategoryList}">
										<option value="${cat.categoryId}">${cat.categoryName}</option>
									</c:forEach>
								</c:if>
							</select>
						</div>
					</div>
					<div class="mb-3"> <%-- Changed to mb-3 --%>
						<label for="productPhotoInput" class="form-label"><b>Product Image</b></label>
						<input type="file" name="photo" id="productPhotoInput" class="form-control" required accept="image/*">
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
	// Renamed function for clarity and improved validation logic
	function validateDiscount() {
		const discountInput = document.forms["addProductForm"]["discount"];
		const discountValue = parseInt(discountInput.value, 10); // Always specify radix

		if (isNaN(discountValue) || discountValue < 0 || discountValue > 100) {
			alert("Discount must be a number between 0 and 100!");
			discountInput.focus(); // Focus the input field
			discountInput.value = "0"; // Optionally reset to 0
			return false; // Prevent form submission if validation added to onsubmit
		}
		return true; // Allow form submission
	}

	// Optional: Add this validation to the form's onsubmit event
	// document.forms["addProductForm"].onsubmit = validateDiscount;
	// Or modify the input tag: <input type="number" name="discount" onblur="validateDiscount()" ...>
	// Note: onblur only validates when leaving the field, onsubmit validates before sending.

</script>
<%-- Footer --%>
 <%@include file="footer.jsp"%>
</body>
</html>