<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Resend Verification | Go Voter</title>
<style>
* { margin:0; padding:0; box-sizing:border-box; font-family:Segoe UI, Arial, sans-serif; }
body { height:100vh; display:flex; align-items:center; justify-content:center; background:url("Sign-in-up.jpeg") no-repeat center center/cover; position:relative; }
body::before { content:""; position:absolute; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,.55); z-index:0; }
.container { position:relative; z-index:1; background:#fff; padding:60px 40px; border-radius:20px; box-shadow:0 25px 70px rgba(0,0,0,0.3); max-width:400px; text-align:center; }
h1 { color:#1e3a8a; margin-bottom:20px; font-size:28px; }
p { color:#4b5563; margin-bottom:30px; line-height:1.6; }
form { display:flex; flex-direction:column; align-items:center; }
input { width:100%; padding:15px; border:1px solid #ddd; border-radius:12px; font-size:16px; margin-bottom:20px; transition:border-color .3s; }
input:focus { border-color:#2563eb; outline:none; }
.btn { width:100%; padding:15px; background:#2563eb; color:white; border:none; border-radius:12px; font-size:16px; font-weight:600; cursor:pointer; transition:all .3s; }
.btn:hover { background:#1e40af; }
.back-btn { position:absolute; top:30px; left:40px; padding:10px 20px; background:transparent; border:1px solid rgba(255,255,255,0.6); color:white; border-radius:20px; cursor:pointer; text-decoration:none; backdrop-filter:blur(4px); }
.back-btn:hover { background:rgba(255,255,255,0.15); }
.message { padding:15px; border-radius:8px; margin-bottom:20px; }
.success { background:#d4edda; color:#155724; border:1px solid #c3e6cb; }
.error { background:#f8d7da; color:#721c24; border:1px solid #f5c6cb; }
</style>
</head>
<body>
<a href="auth.jsp" class="back-btn">← Back</a>
<div class="container">
<h1>Resend Verification</h1>
<p>Enter the email you used to register, and we'll send a new verification code if an account exists.</p>

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

<form method="post" action="resend-verification">
    <input type="email" name="email" placeholder="your@email.com" maxlength="255" required autofocus>
    <button type="submit" class="btn">Send Verification Email</button>
</form>

<p style="font-size:14px; color:#6b7280; margin-top:20px;">If you also need to reset your password, visit <a href="forgot-password.jsp" style="color:#2563eb;">Forgot Password</a></p>
</div>

<script>
// Auto-focus input
document.querySelector('input').focus();
</script>
</body>
</html>