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
    <h1 class="text-danger">404</h1>
    <p>The page you are looking for does not exist.</p>
    <a href="<%=request.getContextPath()%>/" class="btn btn-primary">Go Home</a>
</div>

<%@ include file="../fragment/footer.jsp" %>
</body>
</html>
