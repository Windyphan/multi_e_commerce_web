<%-- admin.jsp --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@page import="com.phong.entities.Admin"%>
<%@page import="com.phong.entities.Category"%>
<%@page import="com.phong.entities.Message"%>
<%-- Add other imports needed for fetching data for included pages if not done within includes --%>
<%@page import="com.phong.dao.*" %> <%-- Example wildcard import --%>
<%@page import="java.util.*" %>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check --%>
<c:set var="activeAdmin" value="${sessionScope.activeAdmin}" />
<c:if test="${empty activeAdmin}">
	<c:set var="errorMessage" value="You are not logged in! Login first!!" scope="session"/>
	<c:set var="errorType" value="error" scope="session"/>
	<c:set var="errorClass" value="alert-danger" scope="session"/>
	<c:redirect url="adminlogin.jsp"/>
</c:if>

<%--
    Data Preparation:
    - Fetch data needed for the DEFAULT tab (e.g., maybe some dashboard stats?)
    - Fetch data needed by ALL includes (like category list for product modal)
    - Determine active tab based on parameter or default
--%>
<c:set var="activeAdminTab" value="${empty param.tab ? 'dashboard' : param.tab}" scope="request"/>

<%-- Fetch category list needed by add_category_modal.jsp --%>
<%
	CategoryDao categoryDaoForAdminPage = new CategoryDao();
	List <Category> categoryListForAdminPage = categoryDaoForAdminPage.getAllCategories();
	if (categoryListForAdminPage == null) categoryListForAdminPage = Collections.emptyList();
	request.setAttribute("navbarCategoryList", categoryListForAdminPage); // Name expected by modal
%>


<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Admin Dashboard - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body { background-color: #f8f9fa; }
		/* Styles similar to profile.jsp sidebar/content */
		.admin-sidebar .card { border: none; box-shadow: 0 2px 8px rgba(0,0,0,0.06); border-radius: 0.375rem; }
		.admin-greeting { padding: 1rem; border-bottom: 1px solid #eee; display: flex; align-items: center; background-color: #e9ecef;}
		.admin-greeting i { font-size: 1.8rem; margin-right: 15px; color: #495057; }
		.admin-greeting h5 { margin-bottom: 0; font-size: 1.1rem; font-weight: 600; color: #343a40; }
		.admin-greeting span { font-size: 0.9rem; color: #6c757d; }

		.admin-nav .list-group-item { border: none; border-radius: 0 !important; padding: 0.9rem 1.25rem; font-size: 1rem; font-weight: 500; color: #495057; transition: background-color 0.2s ease, color 0.2s ease, border-left 0.2s ease; border-left: 4px solid transparent; }
		.admin-nav .list-group-item:hover { background-color: #f1f3f5; color: #0d6efd; }
		.admin-nav .list-group-item.active { background-color: #e7f1ff; color: #0d6efd; border-left: 4px solid #0d6efd; font-weight: 600; }
		.admin-nav .list-group-item i { margin-right: 12px; width: 22px; text-align: center; color: #6c757d; }
		.admin-nav .list-group-item.active i { color: #0d6efd; }
		.admin-nav a.list-group-item { color: #495057; text-decoration: none;} /* Ensure links look like buttons */
		.admin-nav a.list-group-item:hover { color: #0d6efd; }
		.admin-nav a.list-group-item.active { color: #0d6efd; }


		.admin-content .card { border: none; box-shadow: 0 2px 8px rgba(0,0,0,0.06); border-radius: 0.375rem; min-height: 500px; }
		.admin-content .card-body { padding: 1.5rem 2rem; } /* Adjust padding */

		/* Tab content panes */
		.tab-pane { display: none; }
		.tab-pane.active { display: block; }

		/* Simple Dashboard Stats styling */
		.stat-card { background-color: #fff; padding: 1.5rem; border-radius: .375rem; text-align:center; margin-bottom: 1rem; box-shadow: 0 1px 3px rgba(0,0,0,.05); }
		.stat-card .stat-value { font-size: 2rem; font-weight: 700; color: #0d6efd; }
		.stat-card .stat-label { font-size: 0.9rem; color: #6c757d; }

	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar - Should show Admin view --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container-fluid flex-grow-1 my-4">

	<%-- Display Messages --%>
	<%@include file="Components/alert_message.jsp"%>

	<div class="row g-4"> <%-- Row for sidebar and content --%>

		<%-- === Sidebar Column === --%>
		<div class="col-lg-3">
			<div class="card admin-sidebar">
				<div class="admin-greeting">
					<i class="fas fa-user-shield"></i>
					<div>
						<span>Welcome Admin,</span>
						<h5><c:out value="${activeAdmin.name}"/></h5>
					</div>
				</div>
				<div class="list-group list-group-flush admin-nav">
					<%-- Use data-target corresponding to content pane IDs --%>
					<button type="button" class="list-group-item list-group-item-action ${activeAdminTab == 'categories' ? 'active' : ''}" data-target="#categories-content">
						<i class="fas fa-tags fa-fw"></i>Categories
					</button>
					<button type="button" class="list-group-item list-group-item-action ${activeAdminTab == 'products' ? 'active' : ''}" data-target="#products-content">
						<i class="fas fa-boxes-stacked fa-fw"></i>Products
					</button>
					<button type="button" class="list-group-item list-group-item-action ${activeAdminTab == 'orders' ? 'active' : ''}" data-target="#orders-content">
						<i class="fas fa-receipt fa-fw"></i>Orders
					</button>
					<button type="button" class="list-group-item list-group-item-action ${activeAdminTab == 'users' ? 'active' : ''}" data-target="#users-content">
						<i class="fas fa-users fa-fw"></i>Users
					</button>
					<button type="button" class="list-group-item list-group-item-action ${activeAdminTab == 'vendors' ? 'active' : ''}" data-target="#vendors-content">
						<i class="fas fa-store fa-fw"></i>Vendors
					</button>
					<button type="button" class="list-group-item list-group-item-action ${activeAdminTab == 'admins' ? 'active' : ''}" data-target="#admins-content">
						<i class="fas fa-user-cog fa-fw"></i>Admins
					</button>
					<a href="LogoutServlet?user=admin" class="list-group-item list-group-item-action text-danger">
						<i class="fas fa-sign-out-alt fa-fw"></i>Logout
					</a>
				</div>
			</div>
		</div>

		<%-- === Main Content Column === --%>
		<div class="col-lg-9">
			<div class="card admin-content">
				<div class="card-body">
					<%-- Content panes - Include content JSPs here --%>
					<div id="categories-content" class="tab-pane ${activeAdminTab == 'categories' ? 'active' : ''}">
						<%@include file="display_category.jsp"%>
					</div>
					<div id="products-content" class="tab-pane ${activeAdminTab == 'products' ? 'active' : ''}">
						<%@include file="display_products.jsp"%>
					</div>
					<div id="orders-content" class="tab-pane ${activeAdminTab == 'orders' ? 'active' : ''}">
						<%@include file="display_orders.jsp"%>
					</div>
					<div id="users-content" class="tab-pane ${activeAdminTab == 'users' ? 'active' : ''}">
						<%@include file="display_users.jsp"%>
					</div>
					<div id="vendors-content" class="tab-pane ${activeAdminTab == 'vendors' ? 'active' : ''}">
						<%@include file="display_vendors.jsp"%>
					</div>
					<div id="admins-content" class="tab-pane ${activeAdminTab == 'admins' ? 'active' : ''}">
						<%@include file="display_admin.jsp"%>
					</div>
				</div> <%-- End card-body --%>
			</div> <%-- End card --%>
		</div> <%-- End Main Content Column --%>
	</div> <%-- End row --%>
</main>

<%-- Footer --%>
<%@include file="Components/footer.jsp"%>
<%@include file="Components/add_category_modal.jsp"%>
<%@include file="Components/update_product_modal.jsp"%>
<%@include file="Components/update_category_modal.jsp"%>

<script>
	// Tab switching script (similar to profile.jsp)
	$(document).ready(function() { // Use jQuery shorthand
		// Function to switch tabs
		function switchAdminTab(targetId) {
			$('.tab-pane').removeClass('active').hide(); // Hide all panes
			$(targetId).addClass('active').show();      // Show target pane

			$('.admin-nav .list-group-item').removeClass('active'); // Deactivate all buttons
			$('.admin-nav .list-group-item[data-target="' + targetId + '"]').addClass('active'); // Activate target button

			// Optional: Update URL hash
			// if(history.pushState) history.pushState(null, null, '#'+targetId.substring(1));
			// else location.hash = '#'+targetId.substring(1);
		}

		// Attach click handler
		$('.admin-nav .list-group-item-action').click(function(e) {
			if ($(this).is('button')) { // Only handle buttons, not the logout link
				e.preventDefault();
				const targetPane = $(this).data('target');
				switchAdminTab(targetPane);
			}
		});

		// Optional: Activate tab based on URL hash on load
		var hash = window.location.hash;
		if (hash && $('.admin-nav .list-group-item[data-target="' + hash + '"]').length) {
			switchAdminTab(hash);
		} else {
			// Activate default tab (based on JSP EL 'active' class)
			$('.tab-pane').hide();
			$('.tab-pane.active').show();
		}
	});
</script>

</body>
</html>