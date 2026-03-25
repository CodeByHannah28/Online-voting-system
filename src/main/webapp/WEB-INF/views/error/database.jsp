<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page isErrorPage="true" %>
<%
    Object sessionRole = session.getAttribute("userRole");
    boolean adminSession = sessionRole != null && "ADMIN".equalsIgnoreCase(sessionRole.toString());
    boolean memberSession = sessionRole != null && !sessionRole.toString().isBlank();

    String pageTitle = "Page Unavailable";
    String activePage = "";
    String errorCode = "Oops";
    String errorTitle = "We couldn't load that page";
    String errorMessage = "Please try the page again. If it keeps happening, return to your dashboard and continue from there.";
    String errorActionHref = adminSession
        ? request.getContextPath() + "/admin/dashboard"
        : (memberSession ? request.getContextPath() + "/voterDashboard.jsp" : request.getContextPath() + "/index.jsp");
    String errorActionLabel = memberSession ? "Open dashboard" : "Return home";
    String errorSecondaryHref = memberSession ? request.getContextPath() + "/profile" : request.getContextPath() + "/contact.jsp";
    String errorSecondaryLabel = memberSession ? "Open profile" : "Contact support";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/site-head.jspf" %>
</head>
<body class="public-body">
<% if (!memberSession) { %>
<%@ include file="/WEB-INF/views/fragment/public-navbar.jspf" %>
<% } %>
<%@ include file="/WEB-INF/views/fragment/error-page.jspf" %>
<% if (!memberSession) { %>
<%@ include file="/WEB-INF/views/fragment/public-footer.jspf" %>
<% } %>
</body>
</html>
