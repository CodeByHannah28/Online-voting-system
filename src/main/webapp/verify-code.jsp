<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String pageTitle = "Verify Code";
    String authViewName = "";
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
    String emailValue = request.getAttribute("unverifiedEmail") != null
        ? request.getAttribute("unverifiedEmail").toString()
        : (session.getAttribute("verificationEmail") != null ? session.getAttribute("verificationEmail").toString() : "");
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
                    <div class="auth-aside__eyebrow"><i class="fas fa-envelope-circle-check"></i> Email verification</div>
                    <h1 class="auth-aside__title">Confirm your account with the verification code.</h1>
                    <p class="auth-aside__text">
                        Enter the code sent to your email so your account can move fully into the platform.
                    </p>
                </div>
                <div class="auth-points">
                    <div class="auth-point">
                        <i class="fas fa-keyboard"></i>
                        <div>
                            <strong>Manual code entry</strong>
                            <span>Paste or type the verification code exactly as it appears in your email.</span>
                        </div>
                    </div>
                    <div class="auth-point">
                        <i class="fas fa-paper-plane"></i>
                        <div>
                            <strong>Need another code?</strong>
                            <span>You can request a fresh code from the same screen without restarting registration.</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="auth-card">
            <div class="auth-card__eyebrow"><i class="fas fa-check-double"></i> Verification step</div>
            <h2 class="auth-card__title">Verify your email.</h2>
            <p class="auth-card__text">
                Enter the verification code sent to your email address.
            </p>

            <% if (message != null) { %>
                <div class="auth-alert auth-alert--success"><%= message %></div>
            <% } %>
            <% if (error != null) { %>
                <div class="auth-alert auth-alert--error"><%= error %></div>
            <% } %>

            <form method="post" action="verify-code" class="auth-form">
                <div class="auth-field">
                    <label for="code">Verification code</label>
                    <input id="code" class="auth-input" type="text" name="code" placeholder="Enter verification code" maxlength="36" inputmode="numeric" autocomplete="one-time-code" required autofocus>
                </div>
                <div class="auth-form__footer">
                    <div class="auth-links">
                        <a href="forgot-password.jsp">Forgot password?</a>
                    </div>
                    <button type="submit" class="site-button site-button--primary">Verify code</button>
                </div>
            </form>

            <div class="auth-note">
                <form method="post" action="resend-code" style="display: inline;">
                    <input type="hidden" name="email" value="<%= emailValue %>">
                    Didn't receive the email?
                    <button type="submit" style="background:none;border:none;padding:0;color:#1d4ed8;font:inherit;font-weight:700;cursor:pointer;">Resend code</button>
                </form>
            </div>
        </section>
    </div>
</main>

</body>
</html>
