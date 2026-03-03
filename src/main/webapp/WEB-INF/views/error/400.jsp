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
    <h1 class="text-warning">400 - Bad Request</h1>
    <p>Invalid request sent to the server.</p>
</div>

<%@ include file="../fragment/footer.jsp" %>
</body>
</html>