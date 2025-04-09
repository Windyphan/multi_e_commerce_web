<%@page import="com.phong.entities.Message"%>
<%
	Message messg = (Message) session.getAttribute("message");
	// *** START ALERT LOGGING ***
	System.out.println("--- ALERT_JSP [" + new Date() + "]: Checking for session message...");
	if (messg != null) {
		System.out.println("--- ALERT_JSP [" + new Date() + "]: FOUND message: '" + messg.getMessage() + "' (" + messg.getMessageType() + ")");
%>
<div class="alert <%=messg.getCssClass()%>" role="alert" id="alert">
	<%=messg.getMessage()%>
</div>
<%
		session.removeAttribute("message");
		System.out.println("--- ALERT_JSP [" + new Date() + "]: REMOVED session message.");
	} else {
		System.out.println("--- ALERT_JSP [" + new Date() + "]: NO session message found.");
	}
%>
<script type="text/javascript">
	setTimeout(function() {
		// Make sure jQuery and Bootstrap JS are loaded before this runs
		// Using vanilla JS for Bootstrap 5 alert closing is safer
		var alertElement = document.getElementById('alert');
		if(alertElement) { // Check if the element actually exists on the page
			try {
				var bsAlert = new bootstrap.Alert(alertElement);
				bsAlert.close();
			} catch (e) {
				console.error("Error closing Bootstrap alert:", e);
				// Fallback or just let it stay if BS JS failed
			}
		}
		// Older jQuery method (less safe if element doesn't exist):
		// $('#alert').alert('close');
	}, 3000); // Close after 3 seconds
</script>