<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login | Go Voter</title>
<style>
* { margin:0; padding:0; box-sizing:border-box; font-family:Segoe UI, Arial, sans-serif; }
body { 
    height:100vh; 
    display:flex; 
    align-items:center; 
    justify-content:center; 
    background:url("Sign-in-up.jpeg") no-repeat center center/cover; 
    position:relative; 
}
body::before { content:""; position:absolute; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,.55); z-index:0; }
.container { position:relative; z-index:1; background:#fff; padding:60px 40px; border-radius:20px; box-shadow:0 20px 60px rgba(0,0,0,0.3); max-width:400px; text-align:center; }
.container h1 { color:#1e3a8a; margin-bottom:30px; font-size:32px; }
.container p { color:#4b5563; margin-bottom:30px; line-height:1.6; }
form { display:flex; flex-direction:column; align-items:center; }
input { width:100%; padding:15px; border:1px solid #ddd; border-radius:12px; font-size:16px; margin-bottom:20px; transition:border-color .3s; }
input:focus { border-color:#2563eb; outline:none; box-shadow:0 0 0 3px rgba(37,99,235,0.1); }
.btn { width:100%; padding:15px; background:#2563eb; color:white; border:none; border-radius:12px; font-size:16px; font-weight:600; cursor:pointer; transition:all .3s; }
.btn:hover { background:#1e40af; transform:translateY(-1px); }
.btn:active { transform:translateY(0); }
.link { color:#2563eb; text-decoration:none; font-weight:500; }
.link:hover { text-decoration:underline; }
.back-btn { position:absolute; top:30px; left:40px; padding:10px 20px; background:transparent; border:1px solid rgba(255,255,255,0.6); color:white; border-radius:20px; cursor:pointer; text-decoration:none; backdrop-filter:blur(4px); font-size:14px; }
.back-btn:hover { background:rgba(255,255,255,0.15); }
.error { background:#f8d7da; color:#721c24; padding:15px; border-radius:8px; border:1px solid #f5c6cb; margin-bottom:20px; }
</style>
</head>
<body>
<a href="index.jsp" class="back-btn">← Home</a>
<div class="container">
<h1>Sign In</h1>
    <p>Welcome back! Please login to your account. <a href="verify-code.jsp" style="color:#2563eb;">Verify email?</a></p>

<%
String error = (String) request.getAttribute("error");
String message = (String) request.getAttribute("message");
if (message != null) {
%>
<div class="" style="background:#d4edda;color:#155724;padding:15px;border-radius:8px;border:1px solid #c3e6cb;margin-bottom:20px;"><%=message%></div>
<%
}
if (error != null) {
%>
<div class="error"><%=error%></div>
<%
}
%>

<form method="post" action="login">
    <input type="email" name="email" placeholder="Email address" required autofocus>
    <input type="password" name="password" placeholder="Password" required>
    <!-- Preserve redirect param if present -->
    <input type="hidden" name="redirect" value="<%= request.getParameter("redirect") != null ? request.getParameter("redirect") : "" %>">
    <button type="submit" class="btn">Sign In</button>
</form>

<p style="margin-top:12px;"><a href="forgot-password.jsp" class="link">Forgot password?</a></p>

<p style="margin-top:25px;">Don't have an account? <a href="register.jsp" class="link">Sign up</a></p>
</div>
</body>
</html>