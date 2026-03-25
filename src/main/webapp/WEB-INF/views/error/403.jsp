<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page isErrorPage="true" %>
<%
    String pageTitle = "Forbidden";
    String activePage = "";
    String errorCode = "403";
    String errorTitle = "You do not have permission to view this page";
    String errorMessage = "Your account does not currently have access to the resource you tried to open.";
    String errorActionHref = request.getContextPath() + "/index.jsp";
    String errorActionLabel = "Return home";
    String errorSecondaryHref = request.getContextPath() + "/login.jsp";
    String errorSecondaryLabel = "Switch account";
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
