<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@page errorPage="error_exception.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- Security Check --%>
<c:if test="${empty sessionScope.activeUser}">
	<c:set var="errorMessage" value="You are not logged in! Login first!!" scope="session"/>
	<c:set var="errorType" value="error" scope="session"/>
	<c:set var="errorClass" value="alert-danger" scope="session"/>
	<c:redirect url="login.jsp"/>
</c:if>

<%--
    Data Preparation:
    - User is already in sessionScope.activeUser
    - The included JSPs (wishlist_section.jsp, order_section.jsp, personalInfo.jsp)
      should ideally fetch their own data (or receive it via request attributes
      set by a controller servlet before forwarding here).
    - We can pre-set the active tab based on a request parameter if needed.
--%>
<c:set var="activeTab" value="${empty param.tab ? 'profile' : param.tab}" scope="request"/> <%-- Default to profile, allow tab parameter --%>


<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>My Profile - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f8f9fa;
		}
		.profile-sidebar .card {
			border: none;
			box-shadow: 0 2px 8px rgba(0,0,0,0.06);
			border-radius: 0.375rem;
		}
		.profile-greeting {
			padding: 1rem;
			border-bottom: 1px solid #eee;
			display: flex;
			align-items: center;
		}
		.profile-greeting img {
			max-width: 50px; /* Slightly smaller */
			margin-right: 15px;
		}
		.profile-greeting h5 {
			margin-bottom: 0;
			font-size: 1.1rem;
			font-weight: 600;
			color: #343a40;
		}
		.profile-greeting span {
			font-size: 0.9rem;
			color: #6c757d;
		}

		.profile-nav .list-group-item {
			border: none; /* Remove borders */
			border-radius: 0 !important; /* Override Bootstrap radius */
			padding: 0.9rem 1.25rem;
			font-size: 1rem; /* Adjust font size */
			font-weight: 500;
			color: #495057;
			transition: background-color 0.2s ease, color 0.2s ease, border-left 0.2s ease;
			border-left: 3px solid transparent; /* Indicator for active item */
		}
		.profile-nav .list-group-item:hover {
			background-color: #f1f3f5;
			color: #0d6efd;
		}
		.profile-nav .list-group-item.active {
			background-color: #e7f1ff; /* Lighter active blue */
			color: #0d6efd; /* Bootstrap primary color */
			border-left: 3px solid #0d6efd;
			font-weight: 600;
		}
		.profile-nav .list-group-item i { /* Style icons */
			margin-right: 10px;
			width: 20px; /* Fixed width for alignment */
			text-align: center;
			color: #6c757d;
		}
		.profile-nav .list-group-item.active i {
			color: #0d6efd;
		}

		.profile-content .card {
			border: none;
			box-shadow: 0 2px 8px rgba(0,0,0,0.06);
			border-radius: 0.375rem;
			min-height: 400px; /* Ensure card has some height */
		}
		.profile-content .card-body { /* Assuming content is wrapped in card-body in includes */
			padding: 1.5rem;
		}

		/* Tab content panels */
		.tab-pane {
			display: none; /* Hide inactive tabs */
		}
		.tab-pane.active {
			display: block; /* Show active tab */
		}

	</style>
</head>
<body class="d-flex flex-column min-vh-100">
<%-- Navbar --%>
<%@include file="Components/navbar.jsp"%>

<%-- Main Content Wrapper --%>
<main class="container flex-grow-1 my-4">

	<h2 class="mb-4">My Account</h2>

	<%-- Display Messages (e.g., profile updated) --%>
	<%@include file="Components/alert_message.jsp"%>

	<div class="row g-4"> <%-- Add gap between columns --%>
		<%-- Sidebar Navigation --%>
		<div class="col-lg-3">
			<div class="card profile-sidebar">
				<div class="profile-greeting">
					<img src="Images/profile.png" class="img-fluid rounded-circle" alt="Profile Icon">
					<div>
						<span>Hello,</span>
						<h5><c:out value="${sessionScope.activeUser.userName}"/></h5>
					</div>
				</div>
				<div class="list-group list-group-flush profile-nav">
					<%-- Use data attributes to target content panes --%>
					<button type="button" class="list-group-item list-group-item-action ${activeTab == 'profile' ? 'active' : ''}" data-target="#profile-content">
						<i class="fas fa-user-edit"></i>Profile Information
					</button>
					<button type="button" class="list-group-item list-group-item-action ${activeTab == 'wishlist' ? 'active' : ''}" data-target="#wishlist-content">
						<i class="fas fa-heart"></i>My Wishlist
					</button>
					<button type="button" class="list-group-item list-group-item-action ${activeTab == 'orders' ? 'active' : ''}" data-target="#orders-content">
						<i class="fas fa-box-open"></i>My Orders
					</button>
					<a href="LogoutServlet?user=user" class="list-group-item list-group-item-action text-danger"> <%-- Style logout differently --%>
						<i class="fas fa-sign-out-alt"></i>Logout
					</a>
				</div>
			</div>
		</div>

		<%-- Content Area --%>
		<div class="col-lg-9">
			<div class="card profile-content">
				<%-- Content panes - only one is shown by JS based on active button --%>
				<div id="profile-content" class="tab-pane ${activeTab == 'profile' ? 'active' : ''}">
					<%@include file="personalInfo.jsp"%>
				</div>
				<div id="wishlist-content" class="tab-pane ${activeTab == 'wishlist' ? 'active' : ''}">
					<%@include file="wishlist_section.jsp"%>
				</div>
				<div id="orders-content" class="tab-pane ${activeTab == 'orders' ? 'active' : ''}">
					<%@include file="order_section.jsp"%>
				</div>
			</div>
		</div>
	</div> <%-- End row --%>
</main> <%-- End main wrapper --%>

<%-- Footer --%>
<%@include file="footer.jsp"%>

<script>
	$(document).ready(function() {
		// Function to switch tabs
		function switchTab(targetId) {
			// Hide all content panes
			$('.tab-pane').removeClass('active').hide();
			// Show the target pane
			$(targetId).addClass('active').show();

			// Update active state for buttons
			$('.profile-nav .list-group-item').removeClass('active');
			$('.profile-nav .list-group-item[data-target="' + targetId + '"]').addClass('active');

			// Optional: Update URL hash without reloading page
			// if(history.pushState) {
			//     history.pushState(null, null, '#'+targetId.substring(1));
			// } else {
			//     location.hash = '#'+targetId.substring(1);
			// }
		}

		// Attach click handler to navigation buttons
		$('.profile-nav .list-group-item-action').click(function(e) {
			// Prevent default action for buttons (anchor tags handle their own href)
			if ($(this).is('button')) {
				e.preventDefault();
				const targetPane = $(this).data('target'); // Get target from data-target attribute
				switchTab(targetPane);
			}
		});

		// Optional: Check URL hash on page load to activate correct tab
		// var hash = window.location.hash;
		// if (hash) {
		//    var targetButton = $('.profile-nav .list-group-item[data-target="' + hash + '"]');
		//    if(targetButton.length){
		//         switchTab(hash);
		//    } else {
		//         // Default to profile if hash is invalid
		//         switchTab('#profile-content');
		//    }
		// } else {
		// If no hash, ensure the default tab determined by JSP EL is shown correctly
		// The initial class setting in the JSP handles this, JS just confirms display.
		$('.tab-pane').hide(); // Ensure others are hidden
		$('.tab-pane.active').show(); // Show the one marked active by JSP
		// }

	});
</script>

</body>
</html>