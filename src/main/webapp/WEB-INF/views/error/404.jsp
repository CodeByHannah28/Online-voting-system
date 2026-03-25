<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page isErrorPage="true" %>
<%
    String pageTitle = "Page Not Found";
    String activePage = "";
    String errorCode = "404";
    String errorTitle = "That page could not be found";
    String errorMessage = "The link may be outdated, or the page may have moved to a new route inside the application.";
    String errorActionHref = request.getContextPath() + "/index.jsp";
    String errorActionLabel = "Go home";
    String errorSecondaryHref = request.getContextPath() + "/contact.jsp";
    String errorSecondaryLabel = "Report issue";
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
