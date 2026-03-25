<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String pageTitle = "Authentication";
    String authViewName = "";
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/site-head.jspf" %>
</head>
<body class="auth-body">
<%@ include file="/WEB-INF/views/fragment/auth-header.jspf" %>

<main class="auth-shell">
    <div class="auth-stage">
        <section class="auth-aside" style="background-image: url('${pageContext.request.contextPath}/Sign-in-up.jpeg');">
            <div class="auth-aside__content">
                <div>
                    <div class="auth-aside__eyebrow"><i class="fas fa-user-shield"></i> Continue securely</div>
                    <h1 class="auth-aside__title">Choose how you want to enter Go Voter.</h1>
                    <p class="auth-aside__text">
                        This gateway helps new users register and returning users sign in to the voting platform.
                    </p>
                </div>
                <div class="auth-points">
                    <div class="auth-point">
                        <i class="fas fa-right-to-bracket"></i>
                        <div>
                            <strong>Returning account</strong>
                            <span>Go straight to login if you already have verified account credentials.</span>
                        </div>
                    </div>
                    <div class="auth-point">
                        <i class="fas fa-address-card"></i>
                        <div>
                            <strong>New registration</strong>
                            <span>Create a fresh voter account, then apply as a contester after sign-in if you plan to stand for office.</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="auth-card">
            <div class="auth-card__eyebrow"><i class="fas fa-route"></i> Access point</div>
            <h2 class="auth-card__title">Continue authentication.</h2>
            <p class="auth-card__text">
                Pick the right next step for your account and continue into the platform.
            </p>

            <% if (message != null) { %>
                <div class="auth-alert auth-alert--success"><%= message %></div>
            <% } %>
            <% if (error != null) { %>
                <div class="auth-alert auth-alert--error"><%= error %></div>
            <% } %>

            <div class="auth-form" style="margin-top: 1.6rem;">
                <a class="site-button site-button--primary" href="login.jsp" style="width: 100%; justify-content: center;">
                    <i class="fas fa-right-to-bracket"></i> Sign in to your account
                </a>
                <a class="site-button site-button--accent" href="register.jsp" style="width: 100%; justify-content: center;">
                    <i class="fas fa-user-plus"></i> Create a new account
                </a>
                <a class="site-button site-button--ghost" href="forgot-password.jsp" style="width: 100%; justify-content: center;">
                    <i class="fas fa-key"></i> Recover your password
                </a>
            </div>

            <div class="auth-note">
                If a `mode` query parameter is present, this page will still route visitors to the matching dedicated page automatically.
            </div>
        </section>
    </div>
</main>

<script>
window.onload = function() {
    const params = new URLSearchParams(window.location.search);
    const mode = params.get("mode");

    if (mode === "signup") {
        window.location.href = "register.jsp";
        return;
    }
    if (mode === "login") {
        window.location.href = "login.jsp";
    }
};
</script>

</body>
</html>
