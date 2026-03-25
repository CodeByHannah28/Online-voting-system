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

    String error = (String) request.getAttribute("error");
    Boolean alreadyVoted = (Boolean) request.getAttribute("alreadyVoted");
    Boolean votingClosed = request.getAttribute("votingClosed") instanceof Boolean
        ? (Boolean) request.getAttribute("votingClosed")
        : Boolean.FALSE;
    Boolean votingDeadlineActive = request.getAttribute("votingDeadlineActive") instanceof Boolean
        ? (Boolean) request.getAttribute("votingDeadlineActive")
        : Boolean.FALSE;
    String votingDeadlineDisplay = request.getAttribute("votingDeadlineDisplay") != null
        ? request.getAttribute("votingDeadlineDisplay").toString()
        : "No voting deadline is scheduled.";
    int ballotOfficeCount = request.getAttribute("ballotOfficeCount") instanceof Number
        ? ((Number) request.getAttribute("ballotOfficeCount")).intValue()
        : 0;
    String ballotOfficeLabel = ballotOfficeCount <= 0
        ? "the active election offices"
        : ballotOfficeCount + (ballotOfficeCount == 1 ? " office" : " offices");
    String pageTitle = "Cast Ballot";
    String activeSection = "vote";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/portal-head.jspf" %>
</head>
<body class="portal-body">
<%@ include file="/WEB-INF/views/fragment/portal-navbar.jspf" %>

<main class="portal-shell portal-shell--narrow">
    <section class="portal-hero">
        <div class="portal-hero__eyebrow"><i class="fas fa-check-to-slot"></i> Secure ballot</div>
        <h1 class="portal-hero__title">Cast your vote with confidence.</h1>
        <p class="portal-hero__subtitle">
            Review the approved ballot below and complete one professional selection for every office before you submit.
        </p>
    </section>

    <section class="portal-card" style="margin-top: 1.6rem;">
        <div class="portal-card__header">
            <div>
                <h2 class="portal-card__title">Ballot submission</h2>
                <p class="portal-card__subtitle">You can submit one complete ballot covering <%= ballotOfficeLabel %> in the current election cycle.</p>
            </div>
            <span class="portal-chip"><i class="fas fa-lock"></i> Protected</span>
        </div>
        <div class="portal-card__body">
            <% if (Boolean.TRUE.equals(alreadyVoted)) { %>
                <div class="portal-status-card portal-status-card--approved">
                    <h2 class="portal-status-card__title">Vote already recorded</h2>
                    <p class="portal-status-card__text">Your ballot has already been submitted for this election. You can still monitor the live results below.</p>
                    <div class="portal-actions" style="margin-top: 1rem; justify-content: flex-start;">
                        <a class="portal-button portal-button--primary" href="${pageContext.request.contextPath}/voter/results">View live results</a>
                    </div>
                </div>
            <% } else { %>
                <% if (error != null) { %>
                    <div class="portal-alert portal-alert--error"><strong>Unable to submit ballot.</strong> <%= error %></div>
                <% } %>

                <% if (Boolean.TRUE.equals(votingClosed)) { %>
                    <div class="portal-status-card portal-status-card--pending">
                        <h2 class="portal-status-card__title">Voting window closed</h2>
                        <p class="portal-status-card__text">
                            Ballot submission closed at <strong><%= votingDeadlineDisplay %></strong>. You can still review the live results.
                        </p>
                        <div class="portal-actions" style="margin-top: 1rem; justify-content: flex-start;">
                            <a class="portal-button portal-button--primary" href="${pageContext.request.contextPath}/voter/results">View live results</a>
                        </div>
                    </div>
                <% } else { %>
                    <% if (Boolean.TRUE.equals(votingDeadlineActive)) { %>
                        <div class="portal-alert portal-alert--info">
                            <strong>Voting window active.</strong> Ballot submission is scheduled to close at <%= votingDeadlineDisplay %>.
                        </div>
                    <% } %>

                    <c:if test="${empty candidatesByPosition}">
                        <div class="portal-empty">
                            <h3>No candidates available</h3>
                            <p>No approved candidates are available for voting right now.</p>
                        </div>
                    </c:if>

                    <c:if test="${not empty candidatesByPosition}">
                        <form method="post" action="${pageContext.request.contextPath}/voter/vote" class="portal-stack">
                            <c:forEach var="section" items="${candidatesByPosition}">
                                <div class="portal-section">
                                    <div class="portal-section__header">
                                        <div>
                                            <h3 class="portal-section__title">${section.key}</h3>
                                            <p class="portal-section__subtitle">Choose one approved candidate for this office to complete your ballot.</p>
                                        </div>
                                        <span class="portal-chip"><i class="fas fa-list-check"></i> 1 choice required</span>
                                    </div>
                                    <c:forEach var="candidate" items="${section.value}">
                                        <label class="portal-choice">
                                            <input type="radio" name="selection_${candidate.position}" value="${candidate.id}" required>
                                            <span class="portal-choice__content">
                                                <span class="portal-choice__title">${candidate.user.firstName} ${candidate.user.lastName}</span>
                                                <span class="portal-choice__meta">${candidate.user.email}</span>
                                            </span>
                                            <span class="portal-pill"><i class="fas fa-award"></i> ${section.key}</span>
                                        </label>
                                    </c:forEach>
                                </div>
                            </c:forEach>

                            <div class="portal-actions" style="justify-content: flex-start;">
                                <button type="submit" class="portal-button portal-button--primary">
                                    <i class="fas fa-paper-plane"></i> Submit full ballot
                                </button>
                            </div>
                        </form>
                    </c:if>
                <% } %>
            <% } %>
        </div>
    </section>
</main>

</body>
</html>
