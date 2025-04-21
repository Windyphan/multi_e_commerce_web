<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@page import="com.phong.entities.Admin"%>
<%@page import="com.phong.entities.Cart"%>
<%@page import="com.phong.dao.CartDao"%>
<%@page import="com.phong.entities.User"%>
<%@page import="java.util.List"%>
<%@page import="com.phong.entities.Category"%>
<%@page import="com.phong.dao.CategoryDao"%>
<%@page import="java.util.Collections"%>
<%@ page import="java.util.Date" %> <%-- Import Collections --%>

<%--
    Server-side Data Fetching for Navbar
    Ideally done in a Servlet/Filter before forwarding.
    Includes null checks and setting request attributes for EL.
--%>
<%
	// *** START NAVBAR LOGGING ***
	System.out.println("### NAVBAR_JSP [" + new Date() + "]: Starting data fetch...");

	User activeUser = (User) session.getAttribute("activeUser");
	Admin activeAdmin = (Admin) session.getAttribute("activeAdmin");
	System.out.println("### NAVBAR_JSP [" + new Date() + "]: activeUser found? " + (activeUser != null) + ", activeAdmin found? " + (activeAdmin != null));

	CategoryDao categoryDao = new CategoryDao();
	List<Category> categoryList = null;
	String catError = null;
	try {
		categoryList = categoryDao.getAllCategories();
	} catch (Exception e) {
		catError = e.getMessage();
		System.err.println("### NAVBAR_JSP [" + new Date() + "]: ERROR fetching categories: " + e.getMessage());
		e.printStackTrace(); // Print stack trace too
	}

	if (categoryList == null) {
		categoryList = Collections.emptyList();
	}
	System.out.println("### NAVBAR_JSP [" + new Date() + "]: Fetched " + categoryList.size() + " categories. Error msg (if any): " + catError);

	int cartCount = 0;
	if (activeUser != null) {
		CartDao cartDao = new CartDao();
		try {
			cartCount = cartDao.getCartCountByUserId(activeUser.getUserId());
		} catch (Exception e) {
			System.err.println("### NAVBAR_JSP [" + new Date() + "]: ERROR fetching cart count: " + e.getMessage());
			e.printStackTrace();
		}
	}
	System.out.println("### NAVBAR_JSP [" + new Date() + "]: Cart count: " + cartCount);

	// Set request attributes
	request.setAttribute("activeUserForNav", activeUser);
	request.setAttribute("activeAdminForNav", activeAdmin);
	request.setAttribute("navbarCategoryList", categoryList);
	request.setAttribute("navbarCartCount", cartCount);

	// !!! Confirmation log !!!
	System.out.println("### NAVBAR_JSP [" + new Date() + "]: FINISHED setup. 'message' attribute in session is: " + (session.getAttribute("message") != null ? "PRESENT" : "ABSENT"));
	// *** END NAVBAR LOGGING ***
%>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Navigation bar - Phong Shop</title>
	<%@include file="common_css_js.jsp"%>
	<style>
		/* Basic Professional Navbar Styling */
		.navbar.custom-color {
			/* Use a subtle gradient or solid professional color */
			/* Example: background: linear-gradient(to right, #4e54c8, #8f94fb); */
			background: #2c3e50; /* Dark blue/grey */
			box-shadow: 0 2px 4px rgba(0,0,0,0.1);
			padding-top: 0.8rem;
			padding-bottom: 0.8rem;
			font-weight: 500;
		}

		.navbar .navbar-brand {
			font-weight: 600;
			font-size: 1.4rem;
			color: #ffffff !important;
		}
		.navbar .navbar-brand i {
			margin-right: 5px;
		}

		.navbar .nav-link {
			color: rgba(255, 255, 255, 0.85) !important; /* Slightly faded white */
			margin-right: 5px; /* Add some spacing */
			margin-left: 5px;
			transition: color 0.2s ease;
		}
		.navbar .nav-link:hover,
		.navbar .nav-link.active { /* Add .active class where appropriate */
			color: #ffffff !important;
		}
		.navbar .nav-link i {
			margin-right: 3px;
		}

		/* Dropdown styling */
		.navbar .dropdown-menu {
			border: none;
			border-radius: 0.25rem;
			box-shadow: 0 4px 10px rgba(0,0,0,0.15);
			background-color: #ffffff !important; /* Keep background white */
			margin-top: 0.5rem; /* Add space between toggle and menu */
		}
		.navbar .dropdown-item {
			color: #333 !important;
			padding: 0.5rem 1rem;
			font-size: 0.95rem;
			transition: background-color 0.2s ease, color 0.2s ease;
		}
		.navbar .dropdown-item:hover,
		.navbar .dropdown-item:focus {
			background-color: #f0f0f0 !important; /* Subtle hover */
			color: #000 !important;
		}
		.navbar .dropdown-item:active {
			background-color: #e0e0e0 !important;
		}


		/* Search Bar */
		.navbar .form-control {
			border-radius: 20px; /* Rounded search */
			border: none;
			padding-left: 15px;
		}
		.navbar .btn-outline-light {
			border-radius: 20px;
			border-color: rgba(255, 255, 255, 0.7);
			color: rgba(255, 255, 255, 0.85);
		}
		.navbar .btn-outline-light:hover {
			border-color: #ffffff;
			background-color: rgba(255, 255, 255, 0.1);
			color: #ffffff;
		}

		/* Cart Badge */
		.navbar .cart-link .badge {
			font-size: 0.7em; /* Make badge smaller */
			padding: 0.3em 0.5em;
			vertical-align: top; /* Align badge better */
			margin-left: -5px; /* Adjust position */
		}

		/* Admin Specific Buttons */
		.navbar .admin-nav-btn {
			background-color: rgba(255,255,255, 0.1);
			border: 1px solid rgba(255,255,255, 0.3);
			color: rgba(255, 255, 255, 0.85) !important;
			margin-left: 10px;
			font-size: 0.9rem;
			padding: 0.3rem 0.7rem;
		}
		.navbar .admin-nav-btn:hover {
			background-color: rgba(255,255,255, 0.2);
			border-color: rgba(255,255,255, 0.5);
			color: #ffffff !important;
		}


	</style>

</head>

<nav class="navbar navbar-expand-lg custom-color" data-bs-theme="dark">
	<div class="container"> <%-- Use container for padding --%>

		<c:choose>
			<%-- === Admin View === --%>
			<c:when test="${not empty activeAdminForNav}">
				<a class="navbar-brand" href="admin.jsp">
					<i class="fa-solid fa-user-shield" style="color: #ffffff;"></i>Phong Admin
				</a>
				<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
					<span class="navbar-toggler-icon"></span>
				</button>
				<div class="collapse navbar-collapse" id="navbarSupportedContent">
						<%-- Admin Actions (aligned right) --%>
					<ul class="navbar-nav ms-auto mb-2 mb-lg-0">
						<li class="nav-item">
							<button type="button" class="btn btn-sm admin-nav-btn" data-bs-toggle="modal" data-bs-target="#add-category">
								<i class="fa-solid fa-plus fa-xs"></i> Add Category
							</button>
						</li>
						<li class="nav-item">
							<button type="button" class="btn btn-sm admin-nav-btn" data-bs-toggle="modal" data-bs-target="#add-product">
								<i class="fa-solid fa-plus fa-xs"></i> Add Product
							</button>
						</li>
						<li class="nav-item dropdown">
							<a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
								<i class="fa-solid fa-user-gear"></i> ${activeAdminForNav.name}
							</a>
							<ul class="dropdown-menu dropdown-menu-end"> <%-- Align right --%>
								<li><a class="dropdown-item" href="admin.jsp">Dashboard</a></li>
								<li><a class="dropdown-item" href="display_users.jsp">Manage Users</a></li>
								<li><a class="dropdown-item" href="display_orders.jsp">Manage Orders</a></li>
								<li><hr class="dropdown-divider"></li>
								<li>
									<a class="dropdown-item" href="LogoutServlet?user=admin">
										<i class="fa-solid fa-sign-out-alt"></i> Logout
									</a>
								</li>
							</ul>
						</li>
					</ul>
				</div>
			</c:when>

			<%-- === User/Guest View === --%>
			<c:otherwise>
				<a class="navbar-brand" href="index.jsp">
					<i class="fa-sharp fa-solid fa-house" style="color: #ffffff;"></i>Phong Shop
				</a>
				<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
					<span class="navbar-toggler-icon"></span>
				</button>
				<div class="collapse navbar-collapse" id="navbarSupportedContent">
						<%-- Left-aligned navigation --%>
					<ul class="navbar-nav me-auto mb-2 mb-lg-0">
						<li class="nav-item">
							<a class="nav-link <c:if test='${param.activePage == "products"}'>active</c:if>" href="products.jsp"> Products </a> <%-- Example active state --%>
						</li>
						<li class="nav-item dropdown">
							<a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
								Category
							</a>
							<ul class="dropdown-menu">
								<li><a class="dropdown-item" href="products.jsp?category=0">All Products</a></li>
									<%-- Loop through categories using JSTL --%>
								<c:if test="${not empty navbarCategoryList}">
									<li><hr class="dropdown-divider"></li>
									<c:forEach var="cat" items="${navbarCategoryList}">
										<li>
											<a class="dropdown-item" href="products.jsp?category=${cat.categoryId}">${cat.categoryName}</a>
										</li>
									</c:forEach>
								</c:if>
							</ul>
						</li>
							<%-- Add other links like "About", "Contact" here if needed --%>
					</ul>

						<%-- Search Form (Center/Right) --%>
					<form class="d-flex mx-auto" style="width: 50%; min-width: 250px;" role="search" action="products.jsp" method="get">
						<input name="search" class="form-control me-2" type="search" placeholder="Search products..." aria-label="Search" value="${param.search}">
						<button class="btn btn-outline-light" type="submit"><i class="fa-solid fa-search"></i></button>
					</form>

						<%-- Right-aligned user actions --%>
					<ul class="navbar-nav ms-auto mb-2 mb-lg-0">
						<c:choose>
							<c:when test="${not empty activeUserForNav}">
								<%-- User is Logged In --%>
								<li class="nav-item">
									<a class="nav-link cart-link position-relative" aria-current="page" href="cart.jsp" title="View Cart">
										<i class="fa-solid fa-cart-shopping"></i>
										<c:if test="${navbarCartCount > 0}">
                                             <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                                                 ${navbarCartCount}
                                                 <span class="visually-hidden">items in cart</span>
                                             </span>
										</c:if>
									</a>
								</li>
								<li class="nav-item dropdown">
									<a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
										<i class="fa-solid fa-user"></i> ${activeUserForNav.userName}
									</a>
									<ul class="dropdown-menu dropdown-menu-end">
										<li><a class="dropdown-item" href="profile.jsp">My Profile</a></li>
										<li><a class="dropdown-item" href="order.jsp">My Orders</a></li>
										<li><a class="dropdown-item" href="wishlist.jsp">My Wishlist</a></li>
										<li><hr class="dropdown-divider"></li>
										<li>
											<a class="dropdown-item" href="LogoutServlet?user=user">
												<i class="fa-solid fa-sign-out-alt"></i> Logout
											</a>
										</li>
									</ul>
								</li>
							</c:when>
							<c:otherwise>
								<%-- User is Logged Out (Guest) --%>
								<li class="nav-item">
									<a class="nav-link" aria-current="page" href="register.jsp">
										<i class="fa-solid fa-user-plus"></i> Register
									</a>
								</li>
								<li class="nav-item">
									<a class="nav-link" aria-current="page" href="login.jsp">
										<i class="fa-solid fa-user-lock"></i> Login
									</a>
								</li>
								<%-- Keep Admin login accessible? Optional --%>
								<%-- <li class="nav-item">
                                    <a class="nav-link" aria-current="page" href="adminlogin.jsp">Admin</a>
                                </li> --%>
							</c:otherwise>
						</c:choose>
					</ul>
				</div>
			</c:otherwise>
		</c:choose>

	</div> <%-- End .container --%>
</nav>
</html>