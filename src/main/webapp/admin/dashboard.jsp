<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%!
    private long toLong(Object value) {
        return value instanceof Number ? ((Number) value).longValue() : 0L;
    }

    private String formatPositionLabel(Object value) {
        if (value == null) {
            return "Unknown position";
        }

        String raw = value.toString().trim();
        if (raw.isEmpty()) {
            return "Unknown position";
        }

        StringBuilder label = new StringBuilder();
        for (String word : raw.split("_")) {
            if (word == null || word.isBlank()) {
                continue;
            }
            if (label.length() > 0) {
                label.append(' ');
            }
            label.append(Character.toUpperCase(word.charAt(0)));
            if (word.length() > 1) {
                label.append(word.substring(1).toLowerCase());
            }
        }
        return label.length() > 0 ? label.toString() : raw;
    }
%>
<%
    String adminPageTitle = "Dashboard";
    String activeAdminSection = "dashboard";
    String dashboardAdminName = session.getAttribute("userName") != null
        ? session.getAttribute("userName").toString()
        : "Administrator";
    long votersCount = toLong(request.getAttribute("votersCount"));
    long contestersCount = toLong(request.getAttribute("contestersCount"));
    long votesCount = toLong(request.getAttribute("votesCount"));
    long pendingApprovals = toLong(request.getAttribute("pendingApprovals"));
    List<?> positionStats = request.getAttribute("positionStats") instanceof List<?>
        ? (List<?>) request.getAttribute("positionStats")
        : java.util.Collections.emptyList();
    int trackedPositions = positionStats.size();
    String queueStatus = pendingApprovals > 0 ? "Needs attention" : "All clear";
    String queueStatusClass = pendingApprovals > 0
        ? "dashboard-pulse__status dashboard-pulse__status--warning"
        : "dashboard-pulse__status dashboard-pulse__status--success";
    String queueMessage = pendingApprovals == 0
        ? "No approval backlog is waiting on the admin team."
        : pendingApprovals + (pendingApprovals == 1 ? " application is waiting for review." : " applications are waiting for review.");
    String approvalLabel = pendingApprovals == 1 ? "Approval waiting" : "Approvals waiting";
    String ballotCoverage = trackedPositions == 0
        ? "No approved positions yet"
        : trackedPositions + (trackedPositions == 1 ? " position populated" : " positions populated");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/admin-head.jspf" %>
</head>
<body>

<%@ include file="/WEB-INF/views/fragment/admin-sidebar.jspf" %>

<div class="main-content">
    <div class="dashboard-shell">
        <% if (request.getAttribute("pageError") != null) { %>
            <div class="admin-alert admin-alert--warning"><strong>We hit a snag.</strong> <%= request.getAttribute("pageError") %></div>
        <% } %>
        <section class="dashboard-hero">
            <div class="dashboard-hero__main">
                <div class="dashboard-hero__eyebrow">
                    <span class="dashboard-hero__eyebrow-dot"></span>
                    Election command center
                </div>
                <div class="dashboard-hero__header">
                    <div>
                        <h1 class="dashboard-hero__title">Welcome back, <%= dashboardAdminName %>.</h1>
                        <p class="dashboard-hero__text">
                            Keep voter records tidy, move approvals forward, and monitor ballot activity from one focused workspace built for day-to-day election operations.
                        </p>
                    </div>
                    <span class="dashboard-hero__chip"><i class="fas fa-shield-halved"></i> Admin workspace</span>
                </div>
                <div class="dashboard-hero__actions">
                    <a href="${pageContext.request.contextPath}/admin/pending-approvals" class="btn btn-primary"><i class="fas fa-user-check"></i> Review approvals</a>
                    <a href="${pageContext.request.contextPath}/admin/voter-stats" class="btn btn-muted"><i class="fas fa-chart-column"></i> Open analytics</a>
                    <a href="${pageContext.request.contextPath}/profile" class="btn btn-muted"><i class="fas fa-id-badge"></i> Open profile</a>
                </div>
                <div class="dashboard-hero__highlights">
                    <div class="dashboard-highlight">
                        <span class="dashboard-highlight__label">Eligible voters</span>
                        <strong><%= votersCount %></strong>
                    </div>
                    <div class="dashboard-highlight">
                        <span class="dashboard-highlight__label"><%= approvalLabel %></span>
                        <strong><%= pendingApprovals %></strong>
                    </div>
                    <div class="dashboard-highlight">
                        <span class="dashboard-highlight__label">Ballot coverage</span>
                        <strong><%= ballotCoverage %></strong>
                    </div>
                </div>
            </div>

            <aside class="dashboard-pulse">
                <div class="dashboard-pulse__label">Operations pulse</div>
                <div class="<%= queueStatusClass %>">
                    <span class="dashboard-pulse__status-dot"></span>
                    <%= queueStatus %>
                </div>
                <p class="dashboard-pulse__text"><%= queueMessage %></p>
                <div class="dashboard-pulse__grid">
                    <div class="dashboard-pulse__metric">
                        <span>Pending queue</span>
                        <strong><%= pendingApprovals %></strong>
                    </div>
                    <div class="dashboard-pulse__metric">
                        <span>Tracked positions</span>
                        <strong><%= trackedPositions %></strong>
                    </div>
                    <div class="dashboard-pulse__metric">
                        <span>Total contesters</span>
                        <strong><%= contestersCount %></strong>
                    </div>
                    <div class="dashboard-pulse__metric">
                        <span>Ballots recorded</span>
                        <strong><%= votesCount %></strong>
                    </div>
                </div>
            </aside>
        </section>

        <section class="dashboard-section">
            <div class="dashboard-section__header">
                <div>
                    <div class="dashboard-section__eyebrow">Snapshot</div>
                    <h2 class="dashboard-section__title">Election overview</h2>
                    <p class="dashboard-section__text">The core health signals for your election workspace, laid out for quick scanning.</p>
                </div>
            </div>

            <div class="dashboard-metric-grid">
                <article class="metric-card metric-card--voters">
                    <div class="metric-card__topline">
                        <span class="metric-card__icon"><i class="fas fa-users"></i></span>
                        <span class="metric-card__tag">Participation</span>
                    </div>
                    <div class="metric-card__label">Eligible voters</div>
                    <div class="metric-card__value"><%= votersCount %></div>
                    <p class="metric-card__text">Registered voter accounts, including contesters who can still cast a ballot.</p>
                </article>

                <article class="metric-card metric-card--contesters">
                    <div class="metric-card__topline">
                        <span class="metric-card__icon"><i class="fas fa-user-tie"></i></span>
                        <span class="metric-card__tag">Ballot</span>
                    </div>
                    <div class="metric-card__label">Total contesters</div>
                    <div class="metric-card__value"><%= contestersCount %></div>
                    <p class="metric-card__text">Applications submitted across every office on the ballot.</p>
                </article>

                <article class="metric-card metric-card--votes">
                    <div class="metric-card__topline">
                        <span class="metric-card__icon"><i class="fas fa-check-to-slot"></i></span>
                        <span class="metric-card__tag">Activity</span>
                    </div>
                    <div class="metric-card__label">Ballots cast</div>
                    <div class="metric-card__value"><%= votesCount %></div>
                    <p class="metric-card__text">Ballots already recorded through the live voting workflow.</p>
                </article>

                <article class="metric-card metric-card--approvals">
                    <div class="metric-card__topline">
                        <span class="metric-card__icon"><i class="fas fa-user-check"></i></span>
                        <span class="metric-card__tag">Queue</span>
                    </div>
                    <div class="metric-card__label">Pending approvals</div>
                    <div class="metric-card__value"><%= pendingApprovals %></div>
                    <p class="metric-card__text">Applications still waiting for an admin decision or follow-up.</p>
                </article>
            </div>
        </section>

        <div class="dashboard-columns">
            <section class="dashboard-section dashboard-section--compact">
                <div class="dashboard-section__header">
                    <div>
                        <div class="dashboard-section__eyebrow">Admin tasks</div>
                        <h2 class="dashboard-section__title">Move work forward</h2>
                        <p class="dashboard-section__text">Jump into the parts of the workflow that usually need attention first.</p>
                    </div>
                </div>

                <div class="dashboard-action-grid">
                    <a class="dashboard-action-card" href="${pageContext.request.contextPath}/admin/voters">
                        <span class="dashboard-action-card__icon"><i class="fas fa-users"></i></span>
                        <span class="dashboard-action-card__content">
                            <span class="dashboard-action-card__eyebrow">Records</span>
                            <strong>Manage voters</strong>
                            <span>Search voter records, verify registration data, and keep the voter roll healthy.</span>
                        </span>
                        <span class="dashboard-action-card__arrow"><i class="fas fa-arrow-right"></i></span>
                    </a>

                    <a class="dashboard-action-card" href="${pageContext.request.contextPath}/admin/contesters">
                        <span class="dashboard-action-card__icon"><i class="fas fa-user-tie"></i></span>
                        <span class="dashboard-action-card__content">
                            <span class="dashboard-action-card__eyebrow">Ballot review</span>
                            <strong>Review contesters</strong>
                            <span>Inspect application status, check ballot coverage, and keep the candidate list organized.</span>
                        </span>
                        <span class="dashboard-action-card__arrow"><i class="fas fa-arrow-right"></i></span>
                    </a>

                    <a class="dashboard-action-card" href="${pageContext.request.contextPath}/admin/voter-stats">
                        <span class="dashboard-action-card__icon"><i class="fas fa-chart-line"></i></span>
                        <span class="dashboard-action-card__content">
                            <span class="dashboard-action-card__eyebrow">Insights</span>
                            <strong>Open analytics</strong>
                            <span>Compare turnout, approved candidates, and election movement from the reporting view.</span>
                        </span>
                        <span class="dashboard-action-card__arrow"><i class="fas fa-arrow-right"></i></span>
                    </a>
                </div>
            </section>

            <section class="dashboard-section dashboard-section--compact">
                <div class="dashboard-section__header">
                    <div>
                        <div class="dashboard-section__eyebrow">Ballot readiness</div>
                        <h2 class="dashboard-section__title">Approved contesters by position</h2>
                        <p class="dashboard-section__text">Each office can hold up to three approved contesters.</p>
                    </div>
                </div>

                <% if (positionStats.isEmpty()) { %>
                    <div class="dashboard-empty">
                        <i class="fas fa-inbox"></i>
                        <strong>No approved contesters yet</strong>
                        <span>Approved candidates will appear here as soon as the admin team starts clearing the ballot.</span>
                    </div>
                <% } else { %>
                    <div class="position-overview">
                        <%
                            for (Object statObj : positionStats) {
                                if (!(statObj instanceof Object[])) {
                                    continue;
                                }
                                Object[] stat = (Object[]) statObj;
                                long approvedCount = stat.length > 1 ? toLong(stat[1]) : 0L;
                                int fillWidth = approvedCount <= 0
                                    ? 0
                                    : (int) Math.min(100, Math.round((approvedCount / 3.0d) * 100));
                        %>
                            <div class="position-row">
                                <div class="position-row__header">
                                    <div>
                                        <strong><%= formatPositionLabel(stat.length > 0 ? stat[0] : null) %></strong>
                                        <span>Approved candidate coverage</span>
                                    </div>
                                    <span class="position-row__count"><%= approvedCount %>/3</span>
                                </div>
                                <div class="meter">
                                    <div class="meter__fill" style="width: <%= fillWidth %>%"></div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </section>
        </div>
    </div>
</div>

</body>
</html>
