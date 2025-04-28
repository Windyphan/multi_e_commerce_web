<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> <%-- Include for potential future use --%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- No isErrorPage needed for a standard 404 page --%>
<%-- No errorPage needed unless you want to chain errors --%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Page Not Found (404) - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		body {
			background-color: #f8f9fa;
		}
		/* Reuse error container styles or define similar ones */
		.error-container {
			max-width: 650px;
			padding: 2rem;
			text-align: center;
		}
		.error-icon {
			font-size: 4.5rem;
			color: #ffc107; /* Bootstrap warning color */
			margin-bottom: 1.5rem;
			/* Alternative if using an image:
            max-width: 180px;
            margin-bottom: 1.5rem; */
		}
		.error-code {
			font-size: 6rem;
			font-weight: 700;
			color: #e9ecef; /* Light grey, subtle */
			line-height: 1;
			margin-bottom: 0.5rem;
			text-shadow: 1px 1px 3px rgba(0,0,0,0.1);
		}

	</style>
</head>
<body class="d-flex flex-column min-vh-100">

<%-- Optional: Simple Header or Full Navbar --%>
<%-- <%@include file="Components/navbar.jsp"%> --%>
<header class="bg-dark text-white p-2 text-center">
	<h4>Phong Shop</h4>
</header>

<%-- Main Content Wrapper --%>
<main class="container text-center flex-grow-1 d-flex flex-column justify-content-center align-items-center error-container">

	<%-- Icon or Image --%>
	<h1 class="error-code">404</h1>
	<%-- <i class="fas fa-map-signs error-icon"></i> --%> <%-- Example map signs icon --%>
		<i class="fas fa-map-signs fa-4x text-primary mb-3"></i>


	<h2 class="display-6 fw-bold text-secondary">Page Not Found</h2>
	<p class="lead text-muted mt-3">
		Sorry, the page you are looking for cannot be found or may have been moved.
	</p>
	<p class="mt-2">
		Please check the URL or return to the homepage.
	</p>

	<%-- Link back to Home --%>
	<a href="index.jsp" class="btn btn-primary mt-4">
		<i class="fas fa-home"></i> Go to Homepage
	</a>

</main> <%-- End main --%>

<%-- Footer --%>
<%@include file="Components/footer.jsp"%>

</body>
</html>