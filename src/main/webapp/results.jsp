<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Voting Results</title>
</head>
<body>
    <h1>Voting Results</h1>
    <% 
    String error = request.getParameter("error");
    if (error != null) {
        out.println("<p style='color:red;'>Error: " + error + "</p>");
    }
    %>
    <p>Results page - approved contesters and vote counts would be listed here.</p>
    <a href="vote-page.jsp">Back to Vote</a>
</body>
</html>
