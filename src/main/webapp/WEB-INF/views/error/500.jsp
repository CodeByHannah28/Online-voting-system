<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page isErrorPage="true" %>
<%
    String pageTitle = "Server Error";
    String activePage = "";
    String errorCode = "500";
    String errorTitle = "Something went wrong on the server";
    String errorMessage = "The platform hit an unexpected error while processing your request. Please try again in a moment.";
    String errorActionHref = request.getContextPath() + "/index.jsp";
    String errorActionLabel = "Back to safety";
    String errorSecondaryHref = request.getContextPath() + "/contact.jsp";
    String errorSecondaryLabel = "Contact support";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/site-head.jspf" %>
</head>
<body class="public-body">
<%@ include file="/WEB-INF/views/fragment/public-navbar.jspf" %>
<%@ include file="/WEB-INF/views/fragment/error-page.jspf" %>
<%@ include file="/WEB-INF/views/fragment/public-footer.jspf" %>
</body>
</html>

