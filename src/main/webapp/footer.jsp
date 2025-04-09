<%@page import="java.time.Year" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% int currentYear = Year.now().getValue(); %>

<footer class="footer mt-auto py-3 bg-dark text-white-50"> <%-- mt-auto is key --%>
    <div class="container text-center">
        <span>© <%= currentYear %> Phong Phan. All Rights Reserved.</span>
</footer>