<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page isErrorPage="true" %>
<%
    String pageTitle = "Unauthorized";
    String activePage = "";
    String errorCode = "401";
    String errorTitle = "Sign in is required";
    String errorMessage = "You need to log in before accessing this part of the platform.";
    String errorActionHref = request.getContextPath() + "/login.jsp";
    String errorActionLabel = "Open login";
    String errorSecondaryHref = request.getContextPath() + "/index.jsp";
    String errorSecondaryLabel = "Go home";
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
