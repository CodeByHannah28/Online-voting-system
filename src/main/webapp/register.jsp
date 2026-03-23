<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Register | Go Voter</title>
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
.container { position:relative; z-index:1; background:#fff; padding:60px 40px; border-radius:20px; box-shadow:0 20px 60px rgba(0,0,0,0.3); max-width:450px; text-align:center; }
.container h1 { color:#1e3a8a; margin-bottom:30px; font-size:32px; }
.container p { color:#4b5563; margin-bottom:30px; line-height:1.6; }
form { display:flex; flex-direction:column; align-items:center; }
input, select { width:100%; padding:15px; border:1px solid #ddd; border-radius:12px; font-size:16px; margin-bottom:15px; transition:border-color .3s; }
input:focus, select:focus { border-color:#2563eb; outline:none; box-shadow:0 0 0 3px rgba(37,99,235,0.1); }
.btn { width:100%; padding:15px; background:#2563eb; color:white; border:none; border-radius:12px; font-size:16px; font-weight:600; cursor:pointer; transition:all .3s; margin-bottom:20px; }
.btn:hover { background:#1e40af; transform:translateY(-1px); }
.btn:active { transform:translateY(0); }
.link { color:#2563eb; text-decoration:none; font-weight:500; }
.link:hover { text-decoration:underline; }
.back-btn { position:absolute; top:30px; left:40px; padding:10px 20px; background:transparent; border:1px solid rgba(255,255,255,0.6); color:white; border-radius:20px; cursor:pointer; text-decoration:none; backdrop-filter:blur(4px); font-size:14px; }
.back-btn:hover { background:rgba(255,255,255,0.15); }
.error { background:#f8d7da; color:#721c24; padding:15px; border-radius:8px; border:1px solid #f5c6cb; margin-bottom:20px; }
.two-col { display:grid; grid-template-columns:1fr 1fr; gap:10px; }
.two-col input, .two-col select { margin-bottom:15px; }
@media (max-width:500px) { .two-col { grid-template-columns:1fr; } }
</style>
</head>
<body>
<a href="index.jsp" class="back-btn">← Home</a>
<div class="container">
<h1>Create Account</h1>
<p>Join thousands of voters on Go Voter platform.</p>

<%
String error = (String) request.getAttribute("error");
if (error != null) {
%>
<div class="error"><%=error%></div>
<%
}
%>

<form method="post" action="register">
    <div class="two-col">
        <input type="text" name="firstName" placeholder="First Name" required>
        <input type="text" name="lastName" placeholder="Last Name" required>
    </div>
    <input type="email" name="email" placeholder="Email" required>

    <select name="birthYear" required>
        <option value="">Select Birth Year</option>
        <% 
            int currentYear = java.time.Year.now().getValue();
            for (int year = currentYear; year >= 1880; year--) {
        %>
            <option value="<%=year%>"><%=year%></option>
        <% } %>
    </select>

    <select name="state" required>
        <option value="">Select State</option>
        <option>Abia</option>
        <option>Adamawa</option>
        <option>Akwa Ibom</option>
        <option>Anambra</option>
        <option>Bauchi</option>
        <option>Bayelsa</option>
        <option>Benue</option>
        <option>Borno</option>
        <option>Cross River</option>
        <option>Delta</option>
        <option>Ebonyi</option>
        <option>Edo</option>
        <option>Ekiti</option>
        <option>Enugu</option>
        <option>Gombe</option>
        <option>Imo</option>
        <option>Jigawa</option>
        <option>Kaduna</option>
        <option>Kano</option>
        <option>Katsina</option>
        <option>Kebbi</option>
        <option>Kogi</option>
        <option>Kwara</option>
        <option>Lagos</option>
        <option>Nasarawa</option>
        <option>Niger</option>
        <option>Ogun</option>
        <option>Ondo</option>
        <option>Osun</option>
        <option>Oyo</option>
        <option>Plateau</option>
        <option>Rivers</option>
        <option>Sokoto</option>
        <option>Taraba</option>
        <option>Yobe</option>
        <option>Zamfara</option>
    </select>

    <select name="country" required>
        <option value="Nigeria">Nigeria</option>
    </select>

    <select name="role" required>
        <option value="">Select Role</option>
        <option>Voter</option>
        <option>Contester</option>
    </select>

    <input type="password" name="password" placeholder="Password" required>
    <input type="password" name="confirmPassword" placeholder="Confirm Password" required>
    <button type="submit" class="btn">Create Account</button>
</form>

<p style="margin-top:25px;">Already have an account? <a href="login.jsp" class="link">Sign in</a></p>
</div>
</body>
</html>