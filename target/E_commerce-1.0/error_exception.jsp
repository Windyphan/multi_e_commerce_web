<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.io.PrintWriter"%> <%-- Needed to print stack trace --%>

<%@ page isErrorPage="true" %> <%-- IMPORTANT: This directive enables the 'exception' implicit object --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Error Occurred - Phong Shop</title>
	<%@include file="Components/common_css_js.jsp"%>
	<style>
		/* Styles specific to the error page */
		body {
			background-color: #f8f9fa;
		}
		.error-container {
			max-width: 650px; /* Limit width for better readability */
			padding: 2rem;
		}
		.error-icon {
			font-size: 4.5rem; /* If using Font Awesome */
			color: #dc3545; /* Bootstrap danger color */
			margin-bottom: 1.5rem;
			/* Alternative if using an image:
            max-width: 180px;
            margin-bottom: 1.5rem; */
		}
		.error-details summary {
			cursor: pointer;
			color: #0d6efd; /* Bootstrap primary color */
			margin-top: 2rem;
			font-size: 0.9rem;
			display: inline-block; /* Fit content */
		}
		.error-details summary:hover {
			text-decoration: underline;
		}
		.error-details pre {
			background-color: #e9ecef; /* Light background for stack trace */
			padding: 1rem;
			border-radius: 0.25rem;
			font-size: 0.8rem; /* Smaller font for trace */
			white-space: pre-wrap; /* Allow wrapping */
			word-break: break-all; /* Break long lines/words */
			max-height: 350px; /* Limit height */
			overflow-y: auto;  /* Add scrollbar if needed */
			text-align: left; /* Align stack trace left */
			margin-top: 0.5rem;
			border: 1px solid #ced4da;
		}
	</style>
</head>
<body class="d-flex flex-column min-vh-100">

<%-- Optional: Include navbar even on error page? Maybe simpler version? --%>
<%-- <%@include file="Components/navbar.jsp"%> --%>
<%-- OR a simple header --%>
<header class="bg-dark text-white p-2 text-center">
	<h4>Phong Shop</h4>
</header>

<%-- Main Content Wrapper --%>
<main class="container text-center flex-grow-1 d-flex flex-column justify-content-center align-items-center error-container">

	<%-- Icon or Image --%>
	<i class="fas fa-bug error-icon"></i> <%-- Example Font Awesome icon --%>
	<%-- <img src="Images/error-graphic.png" class="img-fluid error-icon" alt="Error"> --%>

	<h1 class="display-5 fw-bold text-danger">Oops! Something Went Wrong</h1>
	<p class="lead text-muted mt-3">
		We seem to have encountered an unexpected technical issue. We apologize for the inconvenience.
	</p>
	<p class="mt-2">
		Please try refreshing the page, or return to the homepage. If the problem persists, please contact support.
	</p>

	<%-- Link back to Home --%>
	<a href="index.jsp" class="btn btn-primary mt-4">
		<i class="fas fa-home"></i> Go to Homepage
	</a>

	<%-- Technical Details Section (Hidden by default) --%>
	<%-- Only show if the implicit exception object is available --%>
	<c:if test="${pageContext.exception != null}">
		<details class="error-details">
			<summary>View Technical Details</summary>
				<%-- Display basic exception message --%>
			<p class="mt-2 text-start"><strong>Error Type:</strong> <c:out value="${pageContext.exception.class.name}"/></p>
			<p class="text-start"><strong>Message:</strong> <c:out value="${pageContext.exception.message}"/></p>
			<pre><%-- Use scriptlet to print stack trace to the JspWriter (out) --%><%
                    // Print stack trace into the <pre> block
                    exception.printStackTrace(new PrintWriter(out));
                %></pre>
		</details>
	</c:if>

</main> <%-- End main --%>

<%-- Footer --%>
<%@include file="footer.jsp"%>

</body>
</html>