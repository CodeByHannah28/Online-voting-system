<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String pageTitle = "About";
    String activePage = "about";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/site-head.jspf" %>
</head>
<body class="public-body">
<%@ include file="/WEB-INF/views/fragment/public-navbar.jspf" %>

<main>
    <section class="site-section" style="padding-top: 3.2rem;">
        <div class="site-shell">
            <div class="site-callout" style="background: linear-gradient(135deg, rgba(29,78,216,0.12), rgba(15,118,110,0.12));">
                <div class="site-section__eyebrow"><i class="fas fa-circle-info"></i> About the platform</div>
                <h1 class="site-section__title" style="margin-top: 0.85rem;">Go Voter exists to make election operations clearer and more trustworthy.</h1>
                <p class="site-section__text">
                    The project focuses on a practical digital voting experience where registration, candidate review, results, and administrative oversight all work together in one system.
                </p>
            </div>
        </div>
    </section>

    <section class="site-section" style="padding-top: 1rem;">
        <div class="site-shell">
            <div class="site-card-grid">
                <article class="site-card">
                    <div class="site-card__icon"><i class="fas fa-bullseye"></i></div>
                    <h2 class="site-card__title">Mission</h2>
                    <p class="site-card__text">Modernize voting workflows with interfaces that are easier to trust, manage, and use responsibly.</p>
                </article>
                <article class="site-card">
                    <div class="site-card__icon"><i class="fas fa-eye"></i></div>
                    <h2 class="site-card__title">Vision</h2>
                    <p class="site-card__text">Create a dependable digital election space for schools, communities, and organizations that need transparency without unnecessary friction.</p>
                </article>
                <article class="site-card">
                    <div class="site-card__icon"><i class="fas fa-shield-halved"></i></div>
                    <h2 class="site-card__title">Security first</h2>
                    <p class="site-card__text">Role-aware access, protected ballots, and clearer account controls support a more secure election experience.</p>
                </article>
            </div>
        </div>
    </section>

    <section class="site-section">
        <div class="site-shell site-duo">
            <div class="site-stack">
                <div class="site-section__header" style="margin-bottom: 0.5rem;">
                    <div class="site-section__eyebrow"><i class="fas fa-diagram-project"></i> What the platform covers</div>
                    <h2 class="site-section__title">One place for both voters and administrators.</h2>
                    <p class="site-section__text">
                        Instead of treating voting, candidate management, and election monitoring as separate tools, Go Voter brings them into a single operational flow.
                    </p>
                </div>
                <ul class="site-list">
                    <li class="site-list__item">
                        <i class="fas fa-user-plus"></i>
                        <div>
                            <strong>Account registration and recovery</strong>
                            <span>Users can register, sign in, recover passwords, and verify access through dedicated flows.</span>
                        </div>
                    </li>
                    <li class="site-list__item">
                        <i class="fas fa-people-group"></i>
                        <div>
                            <strong>Candidate and contester visibility</strong>
                            <span>Voters can browse approved candidates, while admins can manage contesters and approvals from their workspace.</span>
                        </div>
                    </li>
                    <li class="site-list__item">
                        <i class="fas fa-chart-line"></i>
                        <div>
                            <strong>Operational transparency</strong>
                            <span>Election results and admin metrics remain visible in the interface so decisions are easier to monitor.</span>
                        </div>
                    </li>
                </ul>
            </div>

            <div class="site-form-card">
                <span class="site-kicker"><i class="fas fa-handshake-angle"></i> Why it matters</span>
                <h3 style="margin-top: 1rem;">Digital voting should feel credible from the first screen.</h3>
                <p>
                    A trustworthy election system is not just about counting votes. It is also about making every step of the process understandable for the people using it.
                </p>
                <div class="site-card-grid" style="margin-top: 1.2rem; grid-template-columns: 1fr;">
                    <article class="site-card">
                        <h4 class="site-card__title" style="margin-top: 0;">Clearer journeys</h4>
                        <p class="site-card__text">Registration, verification, voting, and results are easier to follow when the interface feels consistent.</p>
                    </article>
                    <article class="site-card">
                        <h4 class="site-card__title" style="margin-top: 0;">Better admin control</h4>
                        <p class="site-card__text">Election administrators need a workspace that supports decisions, not just raw data tables.</p>
                    </article>
                </div>
            </div>
        </div>
    </section>
</main>

<%@ include file="/WEB-INF/views/fragment/public-footer.jspf" %>

</body>
</html>
