<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String pageTitle = "Login";
    String authViewName = "login";
    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");
    String emailValue = request.getParameter("email") != null ? request.getParameter("email") : "";
    String redirectValue = request.getParameter("redirect") != null ? request.getParameter("redirect") : "";
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
                    <div class="auth-aside__eyebrow"><i class="fas fa-lock"></i> Secure sign in</div>
                    <h1 class="auth-aside__title">Return to the ballot with confidence.</h1>
                    <p class="auth-aside__text">
                        Sign in to review candidates, cast your vote, manage your profile, and access live election results from one trusted workspace.
                    </p>
                </div>
                <div class="auth-points">
                    <div class="auth-point">
                        <i class="fas fa-shield-halved"></i>
                        <div>
                            <strong>Protected access</strong>
                            <span>Your account stays behind verified sessions and encrypted credentials.</span>
                        </div>
                    </div>
                    <div class="auth-point">
                        <i class="fas fa-chart-line"></i>
                        <div>
                            <strong>Live election context</strong>
                            <span>Move straight from login into voting, results, or admin oversight depending on your role.</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="auth-card">
            <div class="auth-card__eyebrow"><i class="fas fa-right-to-bracket"></i> Account access</div>
            <h2 class="auth-card__title">Welcome back.</h2>
            <p class="auth-card__text">
                Sign in with the email address linked to your Go Voter account.
            </p>

            <% if (message != null) { %>
                <div class="auth-alert auth-alert--success"><%= message %></div>
            <% } %>
            <% if (error != null) { %>
                <div class="auth-alert auth-alert--error"><%= error %></div>
            <% } %>

            <form method="post" action="login" class="auth-form">
                <div class="auth-field">
                    <label for="email">Email address</label>
                    <input id="email" class="auth-input" type="email" name="email" value="<%= emailValue %>" placeholder="you@example.com" required autofocus>
                </div>
                <div class="auth-field">
                    <label for="password">Password</label>
                    <input id="password" class="auth-input" type="password" name="password" placeholder="Enter your password" required>
                </div>
                <input type="hidden" name="redirect" value="<%= redirectValue %>">
                <div class="auth-form__footer">
                    <div class="auth-links">
                        <a href="forgot-password.jsp">Forgot password?</a>
                        <a href="verify-code.jsp">Verify email</a>
                    </div>
                    <button type="submit" class="site-button site-button--primary">Sign in</button>
                </div>
            </form>

            <div class="auth-note">
                New here? <a href="register.jsp">Create your account</a> and start participating securely.
            </div>
        </section>
    </div>
</main>

</body>
</html>
