<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page isErrorPage="true" %>
<%
    String pageTitle = "Secure Online Voting Platform";
    String activePage = "home";
    Object indexUserObj = session.getAttribute("user");
    com.bascode.model.entity.User indexUser =
        indexUserObj instanceof com.bascode.model.entity.User
            ? (com.bascode.model.entity.User) indexUserObj
            : null;
    boolean signedIn = session.getAttribute("userId") != null;
    String dashboardHref = request.getContextPath() + "/voterDashboard.jsp";
    if (indexUser != null && indexUser.getRole() != null &&
            com.bascode.model.enums.Role.ADMIN.equals(indexUser.getRole())) {
        dashboardHref = request.getContextPath() + "/admin/dashboard";
    }
    boolean deleted = "true".equals(request.getParameter("deleted"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/site-head.jspf" %>
</head>
<body class="public-body">
<%@ include file="/WEB-INF/views/fragment/public-navbar.jspf" %>

<section class="site-hero" style="background: url('${pageContext.request.contextPath}/Home-background.jpeg') center/cover no-repeat;">
    <div class="site-shell site-hero__inner">
        <div class="site-hero__copy">
            <div class="site-hero__eyebrow"><i class="fas fa-landmark"></i> Trusted digital elections</div>
            <h1 class="site-hero__title">Run voting that feels secure, clear, and modern.</h1>
            <p class="site-hero__subtitle">
                Go Voter brings registration, candidate review, ballot submission, results tracking, and admin oversight into one clean election platform.
            </p>
            <div class="site-hero__actions">
                <% if (signedIn) { %>
                    <a class="site-button site-button--primary" href="<%= dashboardHref %>">Open dashboard</a>
                    <a class="site-button site-button--light" href="${pageContext.request.contextPath}/profile">View profile</a>
                <% } else { %>
                    <a class="site-button site-button--primary" href="${pageContext.request.contextPath}/register.jsp">Create account</a>
                    <a class="site-button site-button--light" href="${pageContext.request.contextPath}/login.jsp">Sign in</a>
                <% } %>
                <a class="site-button site-button--light" href="${pageContext.request.contextPath}/about.jsp">Learn more</a>
            </div>
            <% if (deleted) { %>
                <div class="site-notice site-notice--success">Your account has been deleted successfully.</div>
            <% } %>
        </div>

        <div class="site-hero__aside">
            <div class="site-glass-card">
                <h3>Election operations in one flow</h3>
                <p>Voters can move from registration to candidate review and live results without jumping between disconnected screens.</p>
            </div>
            <div class="site-glass-card">
                <h3>Built for trust</h3>
                <p>Role-aware access, profile controls, contester approvals, and protected vote submission keep the process accountable.</p>
            </div>
        </div>
    </div>
</section>

<main>
    <section class="site-section">
        <div class="site-shell">
            <div class="site-section__header">
                <div class="site-section__eyebrow"><i class="fas fa-sparkles"></i> Platform highlights</div>
                <h2 class="site-section__title">Designed to feel serious, not clumsy.</h2>
                <p class="site-section__text">
                    The platform focuses on practical election work: identity, candidate visibility, secure voting, and transparent monitoring for administrators.
                </p>
            </div>

            <div class="site-card-grid">
                <article class="site-card">
                    <div class="site-card__icon"><i class="fas fa-user-check"></i></div>
                    <h3 class="site-card__title">Verified participation</h3>
                    <p class="site-card__text">Account creation captures the core details needed for a valid voting profile.</p>
                </article>
                <article class="site-card">
                    <div class="site-card__icon"><i class="fas fa-people-group"></i></div>
                    <h3 class="site-card__title">Clear candidate access</h3>
                    <p class="site-card__text">Voters can inspect candidates grouped by position before opening the ballot.</p>
                </article>
                <article class="site-card">
                    <div class="site-card__icon"><i class="fas fa-chart-column"></i></div>
                    <h3 class="site-card__title">Live result visibility</h3>
                    <p class="site-card__text">Vote totals and leading candidates update in a format that is easy to follow.</p>
                </article>
                <article class="site-card">
                    <div class="site-card__icon"><i class="fas fa-toolbox"></i></div>
                    <h3 class="site-card__title">Admin oversight</h3>
                    <p class="site-card__text">Moderators can manage voters, contesters, approvals, monitoring, and reporting from one control center.</p>
                </article>
            </div>
        </div>
    </section>

    <section class="site-section">
        <div class="site-shell">
            <div class="site-band">
                <div class="site-band__grid">
                    <div class="site-band__metric">
                        <strong>1</strong>
                        <span>shared platform for voters and administrators</span>
                    </div>
                    <div class="site-band__metric">
                        <strong>4</strong>
                        <span>core election roles already modeled in the system</span>
                    </div>
                    <div class="site-band__metric">
                        <strong>Real-time</strong>
                        <span>result visibility and operational monitoring</span>
                    </div>
                    <div class="site-band__metric">
                        <strong>Role-aware</strong>
                        <span>access control for dashboards and workflows</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="site-section">
        <div class="site-shell site-duo">
            <div class="site-stack">
                <div class="site-section__header" style="margin-bottom: 0.4rem;">
                    <div class="site-section__eyebrow"><i class="fas fa-list-check"></i> How it works</div>
                    <h2 class="site-section__title">A cleaner path from signup to results.</h2>
                    <p class="site-section__text">
                        The platform now supports a more focused user journey across the main election tasks.
                    </p>
                </div>
                <ul class="site-list">
                    <li class="site-list__item">
                        <i class="fas fa-address-card"></i>
                        <div>
                            <strong>Create and verify an account</strong>
                            <span>Users register with their identity, location, age, and intended role in the election.</span>
                        </div>
                    </li>
                    <li class="site-list__item">
                        <i class="fas fa-users-viewfinder"></i>
                        <div>
                            <strong>Review approved candidates</strong>
                            <span>Voters can inspect candidates grouped by position before committing to the ballot.</span>
                        </div>
                    </li>
                    <li class="site-list__item">
                        <i class="fas fa-check-to-slot"></i>
                        <div>
                            <strong>Cast a protected vote</strong>
                            <span>The voting flow protects against duplicate submissions and keeps the interface straightforward.</span>
                        </div>
                    </li>
                    <li class="site-list__item">
                        <i class="fas fa-chart-simple"></i>
                        <div>
                            <strong>Monitor live election outcomes</strong>
                            <span>Results and admin metrics remain visible in dashboards built for fast, practical review.</span>
                        </div>
                    </li>
                </ul>
            </div>

            <div class="site-stack">
                <div class="site-card" style="overflow: hidden; padding: 0;">
                    <img src="${pageContext.request.contextPath}/Box.jpeg" alt="Go Voter overview" style="display: block; width: 100%; height: 18rem; object-fit: cover;">
                    <div style="padding: 1.35rem;">
                        <h3 class="site-card__title" style="margin-top: 0;">Professional by default</h3>
                        <p class="site-card__text">The latest round of work focused on reducing duplicated screens and making the platform feel more cohesive across the authenticated experience.</p>
                    </div>
                </div>

                <div class="site-callout">
                    <h3 class="site-callout__title">Ready to enter the platform?</h3>
                    <p class="site-callout__text">
                        <% if (signedIn) { %>
                            Your account is already active. Open your dashboard and continue from where you left off.
                        <% } else { %>
                            Register to join the election workflow, or sign in if you already have an account.
                        <% } %>
                    </p>
                    <div class="site-hero__actions" style="margin-top: 1.1rem;">
                        <% if (signedIn) { %>
                            <a class="site-button site-button--primary" href="<%= dashboardHref %>">Continue</a>
                        <% } else { %>
                            <a class="site-button site-button--primary" href="${pageContext.request.contextPath}/register.jsp">Register now</a>
                            <a class="site-button site-button--outline" href="${pageContext.request.contextPath}/login.jsp">Login</a>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </section>
</main>

<%@ include file="/WEB-INF/views/fragment/public-footer.jspf" %>

</body>
</html>
