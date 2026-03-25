<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page isErrorPage="true" %>
<%
    String pageTitle = "Bad Request";
    String activePage = "";
    String errorCode = "400";
    String errorTitle = "The request could not be processed";
    String errorMessage = "Some of the information sent to the server was missing or invalid. Please go back and try again.";
    String errorActionHref = request.getContextPath() + "/index.jsp";
    String errorActionLabel = "Return home";
    String errorSecondaryHref = request.getContextPath() + "/contact.jsp";
    String errorSecondaryLabel = "Need help?";
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
