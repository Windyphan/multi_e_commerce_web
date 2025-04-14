<%@ page import="java.sql.*, com.phong.helper.ConnectionProvider, java.io.PrintWriter" %>
<!DOCTYPE html>
<html>
<head><title>DB Connection Test</title></head>
<body>
<h1>Database Connection Test</h1>
<hr>
<%
  Connection testCon = null;
  long startTime = System.currentTimeMillis();
  try {
    out.println("<p>Attempting to get connection...</p>");
    testCon = ConnectionProvider.getConnection();
    long endTime = System.currentTimeMillis();

    if (testCon != null && !testCon.isClosed()) {
      out.println("<p style='color:green; font-weight:bold;'>SUCCESS!</p>");
      out.println("<p>Connection obtained in " + (endTime - startTime) + " ms.</p>");
      // Optional: Try a simple query
      try (Statement stmt = testCon.createStatement();
           ResultSet rs = stmt.executeQuery("SELECT count(*) FROM category")) {
        if (rs.next()) {
          out.println("<p>Test Query (SELECT count(*) FROM category) Result: " + rs.getInt(1) + "</p>");
        } else {
          out.println("<p style='color:orange;'>Test Query failed to return results.</p>");
        }
      } catch (SQLException sqlEx) {
        out.println("<p style='color:red; font-weight:bold;'>ERROR DURING TEST QUERY:</p>");
        out.println("<pre>");
        sqlEx.printStackTrace(new PrintWriter(out));
        out.println("</pre>");
      }
    } else {
      out.println("<p style='color:orange; font-weight:bold;'>WARNING: ConnectionProvider.getConnection() returned null or closed connection?</p>");
    }
  } catch (Exception e) {
    long failTime = System.currentTimeMillis();
    out.println("<p style='color:red; font-weight:bold;'>FAILED TO GET CONNECTION (" + (failTime - startTime) + " ms):</p>");
    out.println("<p>Exception Type: " + e.getClass().getName() + "</p>");
    out.println("<p>Message: " + e.getMessage() + "</p>");
    out.println("<p style='font-weight:bold;'>Stack Trace:</p>");
    out.println("<pre>");
    e.printStackTrace(new PrintWriter(out)); // Print stack trace directly to the page output
    out.println("</pre>");
  } finally {
    if (testCon != null) {
      try {
        testCon.close();
        out.println("<p>Connection closed.</p>");
      } catch (Exception ignored) {}
    }
  }
%>
<hr>
<p>Test finished.</p>
</body>
</html>