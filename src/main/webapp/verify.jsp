<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String code = request.getParameter("code");
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
    if (code != null && !code.trim().isEmpty() && message == null && error == null) {
        response.sendRedirect(request.getContextPath() + "/verify?code=" + java.net.URLEncoder.encode(code, "UTF-8"));
        return;
    }
    String pageTitle = "Verify Email";
    String authViewName = "";
    boolean hasCode = code != null && !code.trim().isEmpty();
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
                    <div class="auth-aside__eyebrow"><i class="fas fa-envelope-circle-check"></i> Email confirmation</div>
                    <h1 class="auth-aside__title">Finalize your verification status.</h1>
                    <p class="auth-aside__text">
                        Verification links sent by email are resolved through this screen so users get a clear success or failure state.
                    </p>
                </div>
                <div class="auth-points">
                    <div class="auth-point">
                        <i class="fas fa-bolt"></i>
                        <div>
                            <strong>Direct link support</strong>
                            <span>Verification links can bring users straight into this flow from their email inbox.</span>
                        </div>
                    </div>
                    <div class="auth-point">
                        <i class="fas fa-arrow-right-to-bracket"></i>
                        <div>
                            <strong>Clear next steps</strong>
                            <span>After verification, users can move straight back to login or request another verification path.</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="auth-card">
            <div class="auth-card__eyebrow"><i class="fas fa-circle-check"></i> Verification result</div>

            <% if (!hasCode && message == null && error == null) { %>
                <h2 class="auth-card__title">Invalid verification link.</h2>
                <p class="auth-card__text">No verification code was provided with this request.</p>
                <div class="auth-form" style="margin-top: 1.6rem;">
                    <a class="site-button site-button--primary" href="auth.jsp">Back to authentication</a>
                </div>
            <% } else if (message != null) { %>
                <h2 class="auth-card__title">Email verified successfully.</h2>
                <p class="auth-card__text">Your account is ready to sign in.</p>
                <div class="auth-alert auth-alert--success"><%= message %></div>
                <div class="auth-form" style="margin-top: 1.3rem;">
                    <a class="site-button site-button--primary" href="login.jsp">Login now</a>
                </div>
            <% } else if (error != null) { %>
                <h2 class="auth-card__title">Verification failed.</h2>
                <p class="auth-card__text">The verification link may be invalid or expired.</p>
                <div class="auth-alert auth-alert--error"><%= error %></div>
                <div class="auth-form" style="margin-top: 1.3rem;">
                    <a class="site-button site-button--primary" href="resend-verification.jsp">Resend verification</a>
                    <a class="site-button site-button--ghost" href="auth.jsp?mode=signup">Back to register</a>
                </div>
            <% } else { %>
                <h2 class="auth-card__title">Verifying your email...</h2>
                <p class="auth-card__text">Please wait while your verification link is processed.</p>
                <div class="auth-alert auth-alert--success">Redirecting to the verification handler now.</div>
            <% } %>
        </section>
    </div>
</main>

</body>
</html>
