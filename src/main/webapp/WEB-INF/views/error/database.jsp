<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../fragment/head.jsp" %>
</head>
<body>
<%@ include file="../fragment/navbar.jsp" %>

<div class="container mt-5 text-center">
    <h1 class="text-danger">Database Error</h1>
    <p>A system error occurred while processing your request.</p>
    <p>Please contact the administrator.</p>
</div>

<%@ include file="../fragment/footer.jsp" %>
</body>
</html>
