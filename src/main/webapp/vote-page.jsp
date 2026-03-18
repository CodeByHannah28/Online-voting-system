<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Vote Page</title>
</head>
<body>
    <h1>Vote for Contesters</h1>
    <% 
    String error = request.getParameter("error");
    if (error != null) {
        out.println("<p style='color:red;'>Error: " + error + "</p>");
    }
    %>
    <form method="post" action="vote">
        <label>Select Contester ID:</label>
        <input type="number" name="contesterId" required>
        <button type="submit">Vote</button>
    </form>
    
    <h2>Register as Contester</h2>
    <form method="post" action="register-contester">
        <label>Position:</label>
        <select name="position">
            <option>PRESIDENT</option>
            <option>VICE_PRESIDENT</option>
            <option>SECRETARY</option>
            <option>TREASURER</option>
        </select>
        <button type="submit">Register</button>
    </form>
    
    <a href="index.jsp">Home</a>
</body>
</html>
