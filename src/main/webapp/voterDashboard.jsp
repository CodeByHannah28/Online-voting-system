<%@ page contentType="text/html;charset=UTF-8" %>
<%
    Object userObj = session.getAttribute("user");
    if (!(userObj instanceof com.bascode.model.entity.User)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    com.bascode.model.entity.User user = (com.bascode.model.entity.User) userObj;
    if (!(com.bascode.model.enums.Role.VOTER.equals(user.getRole())
            || com.bascode.model.enums.Role.CONTESTER.equals(user.getRole()))) {
        response.sendError(403, "Member access required.");
        return;
    }
    String pageTitle = "Voter Dashboard";
    String activeSection = "dashboard";
    String location = "";
    if (user.getState() != null && !user.getState().isBlank()) {
        location = user.getState();
    }
    if (user.getCountry() != null && !user.getCountry().isBlank()) {
        location = location.isEmpty() ? user.getCountry() : location + ", " + user.getCountry();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/portal-head.jspf" %>
</head>
<body class="portal-body">
<%@ include file="/WEB-INF/views/fragment/portal-navbar.jspf" %>

<main class="portal-shell">
    <section class="portal-hero">
        <div class="portal-hero__eyebrow"><i class="fas fa-shield-heart"></i> Voter workspace</div>
        <h1 class="portal-hero__title">Welcome back, <%= user.getFirstName() %>.</h1>
        <p class="portal-hero__subtitle">
            Review candidates, cast your ballot securely, and keep an eye on the live election results from one clear workspace.
        </p>
        <div class="portal-hero__stats">
            <div class="portal-stat">
                <span class="portal-stat__value">Active</span>
                <span class="portal-stat__label">Your voter account is ready</span>
            </div>
            <div class="portal-stat">
                <span class="portal-stat__value"><%= user.getBirthYear() %></span>
                <span class="portal-stat__label">Birth year on file</span>
            </div>
            <div class="portal-stat">
                <span class="portal-stat__value"><%= location.isEmpty() ? "Update profile" : location %></span>
                <span class="portal-stat__label">Current location details</span>
            </div>
        </div>
    </section>

    <section class="portal-card portal-card--glass" style="margin-top: 1.6rem;">
        <div class="portal-card__header">
            <div>
                <h2 class="portal-card__title">Election tools</h2>
                <p class="portal-card__subtitle">Everything you need to participate is grouped below with a cleaner, more focused layout.</p>
            </div>
            <span class="portal-chip"><i class="fas fa-bolt"></i> Quick actions</span>
        </div>
        <div class="portal-card__body">
            <div class="portal-action-grid">
                <article class="portal-action-card">
                    <div class="portal-action-card__icon"><i class="fas fa-users-viewfinder"></i></div>
                    <h3 class="portal-action-card__title">Browse candidates</h3>
                    <p class="portal-action-card__text">Review everyone approved for the ballot before you make your choice.</p>
                    <div class="portal-action-card__footer">
                        <a class="portal-button portal-button--primary" href="${pageContext.request.contextPath}/voter/candidates">View candidates</a>
                    </div>
                </article>

                <article class="portal-action-card">
                    <div class="portal-action-card__icon"><i class="fas fa-check-to-slot"></i></div>
                    <h3 class="portal-action-card__title">Cast your vote</h3>
                    <p class="portal-action-card__text">Submit your ballot through the secure voting flow when you are ready.</p>
                    <div class="portal-action-card__footer">
                        <a class="portal-button portal-button--primary" href="${pageContext.request.contextPath}/voter/vote">Open ballot</a>
                    </div>
                </article>

                <article class="portal-action-card">
                    <div class="portal-action-card__icon"><i class="fas fa-chart-simple"></i></div>
                    <h3 class="portal-action-card__title">Track results</h3>
                    <p class="portal-action-card__text">Stay informed with live counts and leading candidates by position.</p>
                    <div class="portal-action-card__footer">
                        <a class="portal-button portal-button--primary" href="${pageContext.request.contextPath}/voter/results">View results</a>
                    </div>
                </article>

                <article class="portal-action-card">
                    <div class="portal-action-card__icon"><i class="fas fa-user-plus"></i></div>
                    <h3 class="portal-action-card__title">Stand as a contester</h3>
                    <p class="portal-action-card__text">Apply for a position and track your approval status from the same portal.</p>
                    <div class="portal-action-card__footer">
                        <a class="portal-button portal-button--secondary" href="${pageContext.request.contextPath}/voter/register-contester">Submit application</a>
                    </div>
                </article>
            </div>
        </div>
    </section>
</main>

</body>
</html>
