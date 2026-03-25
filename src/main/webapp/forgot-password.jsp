<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String pageTitle = "Forgot Password";
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
                    <div class="auth-aside__eyebrow"><i class="fas fa-key"></i> Password recovery</div>
                    <h1 class="auth-aside__title">Get back into your account.</h1>
                    <p class="auth-aside__text">
                        Request a reset code for the email linked to your account and move back into the platform without starting over.
                    </p>
                </div>
                <div class="auth-points">
                    <div class="auth-point">
                        <i class="fas fa-envelope-open-text"></i>
                        <div>
                            <strong>Email-based recovery</strong>
                            <span>We send a short reset code to the address stored on your account.</span>
                        </div>
                    </div>
                    <div class="auth-point">
                        <i class="fas fa-stopwatch"></i>
                        <div>
                            <strong>Time-limited code</strong>
                            <span>Reset codes expire automatically so recovery stays secure.</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="auth-card">
            <div class="auth-card__eyebrow"><i class="fas fa-unlock-keyhole"></i> Recover access</div>
            <h2 class="auth-card__title">Reset your password.</h2>
            <p class="auth-card__text">
                Enter your email address and we'll send you a verification code for password reset.
            </p>

            <% if (message != null) { %>
                <div class="auth-alert auth-alert--success"><%= message %></div>
            <% } %>
            <% if (error != null) { %>
                <div class="auth-alert auth-alert--error"><%= error %></div>
            <% } %>

            <form method="post" action="forgot-password" class="auth-form">
                <div class="auth-field">
                    <label for="email">Email address</label>
                    <input id="email" class="auth-input" type="email" name="email" value="<%= email %>" placeholder="you@example.com" required>
                </div>
                <div class="auth-form__footer">
                    <div class="auth-links">
                        <a href="reset-password.jsp">Already have a code?</a>
                    </div>
                    <button class="site-button site-button--primary" type="submit">Send reset code</button>
                </div>
            </form>

            <div class="auth-note">
                Remembered your password? <a href="login.jsp">Return to login</a>.
            </div>
        </section>
    </div>
</main>

</body>
</html>
