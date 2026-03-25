<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String pageTitle = "Resend Verification";
    String authViewName = "";
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
    String email = request.getParameter("email") != null ? request.getParameter("email") : "";
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
                    <div class="auth-aside__eyebrow"><i class="fas fa-envelope-open"></i> Resend verification</div>
                    <h1 class="auth-aside__title">Send a fresh verification email.</h1>
                    <p class="auth-aside__text">
                        If your original verification email did not arrive, request another one here using the address you registered with.
                    </p>
                </div>
                <div class="auth-points">
                    <div class="auth-point">
                        <i class="fas fa-user-check"></i>
                        <div>
                            <strong>Account-aware</strong>
                            <span>The response stays generic so the page does not reveal whether an email exists in the system.</span>
                        </div>
                    </div>
                    <div class="auth-point">
                        <i class="fas fa-inbox"></i>
                        <div>
                            <strong>New verification code</strong>
                            <span>A fresh code is generated when a matching account needs another verification email.</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="auth-card">
            <div class="auth-card__eyebrow"><i class="fas fa-paper-plane"></i> Resend flow</div>
            <h2 class="auth-card__title">Resend verification email.</h2>
            <p class="auth-card__text">
                Enter the email you used during registration and we'll send a new verification email if an account exists.
            </p>

            <% if (message != null) { %>
                <div class="auth-alert auth-alert--success"><%= message %></div>
            <% } %>
            <% if (error != null) { %>
                <div class="auth-alert auth-alert--error"><%= error %></div>
            <% } %>

            <form method="post" action="resend-verification" class="auth-form">
                <div class="auth-field">
                    <label for="email">Email address</label>
                    <input id="email" class="auth-input" type="email" name="email" value="<%= email %>" placeholder="you@example.com" maxlength="255" required autofocus>
                </div>
                <div class="auth-form__footer">
                    <div class="auth-links">
                        <a href="verify-code.jsp">Already have a code?</a>
                    </div>
                    <button type="submit" class="site-button site-button--primary">Send verification email</button>
                </div>
            </form>

            <div class="auth-note">
                Need account recovery instead? <a href="forgot-password.jsp">Reset your password</a>.
            </div>
        </section>
    </div>
</main>

</body>
</html>
