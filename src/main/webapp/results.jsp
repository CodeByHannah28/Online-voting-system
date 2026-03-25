<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    Object userObj = session.getAttribute("user");
    if (!(userObj instanceof com.bascode.model.entity.User)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    com.bascode.model.entity.User user = (com.bascode.model.entity.User) userObj;
    if (!com.bascode.model.enums.Role.VOTER.equals(user.getRole()) && !com.bascode.model.enums.Role.CONTESTER.equals(user.getRole())) {
        response.sendError(403);
        return;
    }

    boolean success = "true".equals(request.getParameter("success"));
    String pageTitle = "Election Results";
    String activeSection = "results";
    String pageError = request.getAttribute("pageError") != null
        ? request.getAttribute("pageError").toString()
        : null;
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
        <div class="portal-hero__eyebrow"><i class="fas fa-chart-simple"></i> Live counting</div>
        <h1 class="portal-hero__title">Election results in real time.</h1>
        <p class="portal-hero__subtitle">
            Watch vote totals change as ballots are submitted and see which candidates are currently leading each position.
        </p>
        <div class="portal-hero__stats">
            <div class="portal-stat">
                <span class="portal-stat__value">${totalVotes != null ? totalVotes : 0}</span>
                <span class="portal-stat__label">Total selections recorded</span>
            </div>
            <div class="portal-stat">
                <span class="portal-stat__value">Live</span>
                <span class="portal-stat__label">Saved ballots update every office live</span>
            </div>
        </div>
    </section>

    <section class="portal-stack" style="margin-top: 1.6rem;">
        <% if (success) { %>
            <div class="portal-alert portal-alert--success"><strong>Vote submitted.</strong> Your ballot has been recorded successfully.</div>
        <% } %>
        <% if (pageError != null && !pageError.isBlank()) { %>
            <div class="portal-alert portal-alert--warning"><strong>Heads up.</strong> <%= pageError %></div>
        <% } %>

        <c:if test="${empty candidatesByPosition}">
            <div class="portal-card">
                <div class="portal-empty">
                    <h2>No results to display yet</h2>
                    <p>Once approved candidates receive votes, the live scoreboard will appear here.</p>
                </div>
            </div>
        </c:if>

        <c:forEach var="section" items="${candidatesByPosition}">
            <article class="portal-card">
                <div class="portal-card__header">
                    <div>
                        <h2 class="portal-card__title">${section.key}</h2>
                        <p class="portal-card__subtitle">Current standings for this office.</p>
                    </div>
                    <span class="portal-chip"><i class="fas fa-signal"></i> Live board</span>
                </div>
                <div class="portal-card__body portal-stack">
                    <c:set var="maxForPosition" value="0" />
                    <c:forEach var="candidate" items="${section.value}">
                        <c:set var="candidateVotes" value="${voteCounts[candidate.id] != null ? voteCounts[candidate.id] : 0}" />
                        <c:if test="${candidateVotes > maxForPosition}">
                            <c:set var="maxForPosition" value="${candidateVotes}" />
                        </c:if>
                    </c:forEach>

                    <c:forEach var="candidate" items="${section.value}">
                        <c:set var="candidateVotes" value="${voteCounts[candidate.id] != null ? voteCounts[candidate.id] : 0}" />
                        <c:set var="candidatePct" value="${maxForPosition > 0 ? (candidateVotes * 100 / maxForPosition) : 0}" />
                        <div class="portal-result">
                            <div class="portal-result__top">
                                <div>
                                    <p class="portal-result__title">
                                        ${candidate.user.firstName} ${candidate.user.lastName}
                                        <c:if test="${candidateVotes == maxForPosition && candidateVotes > 0}">
                                            <span class="portal-lead-badge"><i class="fas fa-crown"></i> Leading</span>
                                        </c:if>
                                    </p>
                                    <p class="portal-result__meta">${candidate.user.email}</p>
                                </div>
                                <div class="portal-result__count">${candidateVotes} vote${candidateVotes != 1 ? 's' : ''}</div>
                            </div>
                            <div class="portal-progress">
                                <div class="portal-progress__fill" style="width:${candidatePct}%;"></div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </article>
        </c:forEach>
    </section>
</main>

</body>
</html>
