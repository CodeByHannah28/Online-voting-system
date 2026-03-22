<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Go Voter | Authentication</title>

<style>
*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:Segoe UI, Arial, sans-serif;
}

body{
    height:100vh;
    display:flex;
    align-items:center;
    justify-content:center;
    background:url("Sign-in-up.jpeg") no-repeat center center/cover;
    position:relative;
}

body::before{
    content:"";
    position:absolute;
    top:0;
    left:0;
    width:100%;
    height:100%;
    background:rgba(0,0,0,.55);
    z-index:0;
}

.container{
    position:relative;
    z-index:1;
}

/* BACK BUTTON */
.back-btn{
    position:absolute;
    top:30px;
    left:40px;
    padding:6px 16px;
    font-size:13px;
    border-radius:20px;
    border:1px solid rgba(255,255,255,0.6);
    background:transparent;
    color:white;
    cursor:pointer;
    transition:all .3s ease;
    backdrop-filter:blur(4px);
}

.back-btn:hover{
    background:rgba(255,255,255,0.15);
    border-color:white;
}

/* MAIN CONTAINER */
.container{
    position:relative;
    width:900px;
    height:580px;
    background:#fff;
    border-radius:15px;
    overflow:hidden;
    box-shadow:0 20px 60px rgba(0,0,0,0.3);
}

/* FORM WRAPPER */
.form-wrapper{
    display:flex;
    width:200%;
    height:100%;
    transition:transform .6s ease-in-out;
}

.container.active .form-wrapper{
    transform:translateX(-50%);
}

/* PANELS */
.panel{
    width:50%;
    height:100%;
    display:flex;
    align-items:center;
    justify-content:center;
    padding:60px;
}

/* LEFT SIDE */
.left{
    background:linear-gradient(135deg,#1e40af,#2563eb);
    color:white;
    flex-direction:column;
    text-align:center;
}

.left h2{
    font-size:28px;
    margin-bottom:10px;
}

.left p{
    margin-bottom:20px;
    font-size:14px;
    opacity:.9;
}

.left button{
    padding:10px 28px;
    border-radius:25px;
    border:2px solid white;
    background:transparent;
    color:white;
    cursor:pointer;
    transition:.3s;
}

.left button:hover{
    background:white;
    color:#1e40af;
}

/* RIGHT SIDE */
.right{
    background:white;
    flex-direction:column;
    overflow-y:auto;
}

form{
    width:100%;
    max-width:320px;
    display:flex;
    flex-direction:column;
    align-items:center;
    padding:10px 0;
}

form h2{
    margin-bottom:15px;
    color:#1e3a8a;
}

input{
    width:100%;
    padding:8px;
    margin:6px 0;
    border-radius:8px;
    border:1px solid #ddd;
    transition:.3s;
}

input:focus{
    border-color:#2563eb;
    outline:none;
}

form button{
    margin-top:12px;
    padding:9px 26px;
    border:none;
    border-radius:25px;
    background:#2563eb;
    color:white;
    cursor:pointer;
    transition:.3s;
}

form button:hover{
    background:#1e40af;
}
</style>
</head>

<body>

<a href="index.jsp">
    <button type="button" class="back-btn">← Back Home</button>
</a>

<div class="container" id="container">
<%
String message = (String) request.getAttribute("message");
String error = (String) request.getAttribute("error");
if (message != null) {
%>
  <div style="position:absolute;top:100px;left:50%;transform:translateX(-50%);background:#d4edda;color:#155724;padding:15px;border-radius:8px;border:1px solid #c3e6cb;">
    <%=message%>
  </div>
<%
}
if (error != null) {
%>
  <div style="position:absolute;top:100px;left:50%;transform:translateX(-50%);background:#f8d7da;color:#721c24;padding:15px;border-radius:8px;border:1px solid #f5c6cb;">
    <%=error%>
  </div>
<%
}
%>

    <div class="form-wrapper">

        <!-- Simplified CTA panels linking to the new auth pages -->
        <div class="panel left">
            <h2>Welcome Back!</h2>
            <p>Already have an account?</p>
            <a href="login.jsp"><button type="button">Sign In</button></a>
        </div>

        <div class="panel right" style="flex-direction:column; justify-content:center;">
            <h2>Use the Login Page</h2>
            <p>This page is legacy. Please use the dedicated login page for full features.</p>
            <a href="login.jsp" class="btn">Go to Login</a>
        </div>

        <div class="panel left">
            <h2>Hello, Voter!</h2>
            <p>Don't have an account?</p>
            <a href="register.jsp"><button type="button">Sign Up</button></a>
        </div>

        <div class="panel right" style="flex-direction:column; justify-content:center;">
            <h2>Create Account</h2>
            <p>Register using the full registration page.</p>
            <a href="register.jsp" class="btn">Go to Register</a>
        </div>

     </div>
</div>

<script>
// Redirect to the dedicated pages when `mode` is provided, or keep this page as an informational landing
window.onload = function() {
    const params = new URLSearchParams(window.location.search);
    const mode = params.get("mode");

    if (mode === "signup") {
        window.location.href = "register.jsp";
        return;
    }
    if (mode === "login") {
        window.location.href = "login.jsp";
        return;
    }
};
</script>

</body>
</html>