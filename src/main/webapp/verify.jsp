<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Verify Email | Go Voter</title>
<style>
* { margin:0; padding:0; box-sizing:border-box; font-family:Segoe UI, Arial, sans-serif; }
body { 
    height:100vh; 
    display:flex; 
    align-items:center; 
    justify-content:center; 
    background:linear-gradient(135deg, #1e40af 0%, #2563eb 100%); 
    color:white; 
}
.container { 
    background:white; 
    color:#1e3a8a; 
    padding:60px 40px; 
    border-radius:20px; 
    box-shadow:0 25px 70px rgba(0,0,0,0.3); 
    text-align:center; 
    max-width:500px; 
}
.container h1 { font-size:32px; margin-bottom:20px; color:#1e40af; }
.container p { font-size:16px; margin-bottom:20px; line-height:1.6; }
.success { color:#22c55e; }
.error { color:#dc2626; }
.btn { 
    display:inline-block; 
    padding:12px 32px; 
    background:#2563eb; 
    color:white; 
    text-decoration:none; 
    border-radius:25px; 
    font-weight:600; 
    transition:all 0.3s; 
}
.btn:hover { background:#1e40af; transform:translateY(-2px); }
.loading { color:#6b7280; }
</style>
</head>
<body>
<div class="container">
<%
String message = (String) request.getAttribute("message");
String error = (String) request.getAttribute("error");
String code = request.getParameter("code");

if (code == null || code.trim().isEmpty()) {
%>
    <h1>Invalid Verification Link</h1>
    <p class="error">No verification code provided.</p>
    <a href="auth.jsp" class="btn">Back to Auth</a>
<%
} else if (message != null) {
%>
    <h1>✅ Verified Successfully!</h1>
    <p class="success"><%=message%></p>
    <a href="auth.jsp?mode=login" class="btn">Login Now</a>
<%
} else if (error != null) {
%>
    <h1>❌ Verification Failed</h1>
    <p class="error"><%=error%></p>
    <a href="auth.jsp?mode=signup" class="btn">Register Again</a>
<%
} else {
%>
    <h1>Verifying Email...</h1>
    <p class="loading">Please wait while we verify your email address.</p>
    <jsp:include page="/verify">
        <jsp:param name="code" value="<%=code%>"/>
    </jsp:include>
<%
}
%>
</div>
</body>
</html>

