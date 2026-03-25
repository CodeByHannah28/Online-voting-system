<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String pageTitle = "Reset Password";
    String authViewName = "";
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
    String token = request.getParameter("token");
    String code = request.getParameter("code");
    String codeValue = token != null && !token.isBlank() ? token : (code != null ? code : "");
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
        <section class="auth-aside" style="background-image: url('${pageContext.request.contextPath}/Home-background.jpeg');">
            <div class="auth-aside__content">
                <div>
                    <div class="auth-aside__eyebrow"><i class="fas fa-rotate-right"></i> Password reset</div>
                    <h1 class="auth-aside__title">Set a secure new password.</h1>
                    <p class="auth-aside__text">
                        Use the verification code from your email, choose a fresh password, and return to your account securely.
                    </p>
                </div>
                <div class="auth-points">
                    <div class="auth-point">
                        <i class="fas fa-hashtag"></i>
                        <div>
                            <strong>Code-based verification</strong>
                            <span>Paste or type the reset code exactly as it appears in the email you received.</span>
                        </div>
                    </div>
                    <div class="auth-point">
                        <i class="fas fa-shield-heart"></i>
                        <div>
                            <strong>Fresh credentials</strong>
                            <span>Your old reset token is cleared automatically after a successful password update.</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="auth-card">
            <div class="auth-card__eyebrow"><i class="fas fa-lock-open"></i> New password</div>
            <h2 class="auth-card__title">Finish password reset.</h2>
            <p class="auth-card__text">
                Enter the verification code sent to your email and choose a new password for your account.
            </p>

            <% if (message != null) { %>
                <div class="auth-alert auth-alert--success"><%= message %></div>
            <% } else if (error != null) { %>
                <div class="auth-alert auth-alert--error"><%= error %></div>
            <% } %>

            <form method="post" action="reset-password" class="auth-form">
                <div class="auth-field">
                    <label for="code">Verification code</label>
                    <input id="code" class="auth-input" type="text" name="code" value="<%= codeValue %>" placeholder="Enter your code" required>
                </div>
                <div class="auth-field">
                    <label for="password">New password</label>
                    <input id="password" class="auth-input" type="password" name="password" placeholder="Minimum 6 characters" required>
                </div>
                <div class="auth-field">
                    <label for="confirmPassword">Confirm new password</label>
                    <input id="confirmPassword" class="auth-input" type="password" name="confirmPassword" placeholder="Repeat your new password" required>
                </div>
                <div class="auth-form__footer">
                    <div class="auth-links">
                        <a href="forgot-password.jsp">Request another code</a>
                    </div>
                    <button class="site-button site-button--accent" type="submit">Reset password</button>
                </div>
            </form>

            <div class="auth-note">
                Back to <a href="login.jsp">login</a>.
            </div>
        </section>
    </div>
</main>

</body>
</html>
