<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Forgot Password | Go Voter</title>
<style>
* { margin:0; padding:0; box-sizing:border-box; font-family:Segoe UI, Arial, sans-serif; }
body { display:flex; align-items:center; justify-content:center; height:100vh; background:url("Sign-in-up.jpeg") no-repeat center center/cover; }
.container { background:#fff; padding:40px; border-radius:12px; width:360px; box-shadow:0 10px 30px rgba(0,0,0,0.15); text-align:center; }
input { width:100%; padding:12px; border:1px solid #ddd; border-radius:8px; margin-bottom:12px; }
.btn { width:100%; padding:12px; background:#2563eb; color:#fff; border:none; border-radius:8px; cursor:pointer; }
.message { padding:10px; margin-bottom:12px; border-radius:8px; }
.success { background:#d4edda; color:#155724; }
.error { background:#f8d7da; color:#721c24; }
</style>
</head>
<body>
<div class="container">
<h2>Reset your password</h2>
<p>Enter your account email and we'll send a reset link.</p>
<%
String message = (String) request.getAttribute("message");
String error = (String) request.getAttribute("error");
if (message != null) {
%>
<div class="message success"><%=message%></div>
<%
} else if (error != null) {
%>
<div class="message error"><%=error%></div>
<%
}
%>
<form method="post" action="forgot-password">
    <input type="email" name="email" placeholder="Email" required>
    <button class="btn" type="submit">Send Reset Link</button>
</form>
</div>
</body>
</html>