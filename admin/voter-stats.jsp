<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Voting Results | Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/admin-layout.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

<div class="sidebar">
    <div class="sidebar-header">
        <i class="fas fa-vote-yea"></i> Voting Admin
    </div>
    <ul class="nav-links">
        <li><a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fas fa-home"></i> Overview</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/voters"><i class="fas fa-users"></i> Voters</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/contesters"><i class="fas fa-user-tie"></i> Contesters</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/pending-approvals"><i class="fas fa-user-check"></i> Approvals</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/voter-stats" class="active"><i class="fas fa-chart-bar"></i> Voting Results</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/monitor"><i class="fas fa-server"></i> System Monitor</a></li>
    </ul>
</div>

<div class="main-content">
    <div class="header">
        <h1>Voting Results</h1>
        <p style="color: var(--text-muted)">Live vote counts across positions and contesters. Total votes: <strong>${totalVotes}</strong></p>
    </div>

    <!-- Charts Section -->
    <div class="stats-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 2rem;">
        <div class="card">
            <canvas id="positionChart"></canvas>
        </div>
        <div class="card">
            <canvas id="topContestersChart"></canvas>
        </div>
    </div>

    <!-- Position Summary Table -->
    <div class="header" style="margin-top: 2rem;">
        <h2>Results by Position</h2>
    </div>
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>Position</th>
                    <th>Total Votes</th>
                    <th>Vote %</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="stat" items="${positionTotals}">
                    <c:set var="votes" value="${stat[1]}" />
                    <c:set var="percent" value="${totalVotes > 0 ? (votes * 100 / totalVotes) : 0}" />
                    <tr>
                        <td><strong>${stat[0]}</strong></td>
                        <td>${votes}</td>
                        <td>${percent}%</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Contesters Table -->
    <div class="header" style="margin-top: 3rem;">
        <h2>Contesters Vote Details</h2>
    </div>
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Position</th>
                    <th>Votes</th>
                    <th>%</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="c" items="${contesters}">
                    <c:set var="cVotes" value="${voteCounts[c.id] == null ? 0 : voteCounts[c.id]}" />
                    <c:set var="cPercent" value="${totalVotes > 0 ? (cVotes * 100 / totalVotes) : 0}" />
                    <tr>
                        <td>#${c.id}</td>
                        <td><strong>${c.user.firstName} ${c.user.lastName}</strong></td>
                        <td>${c.position}</td>
                        <td><span class="badge badge-approved">${cVotes}</span></td>
                        <td>${cPercent > 0 ? cPercent : '<1'}%</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty contesters}">
                    <tr>
                        <td colspan="5" style="text-align: center; color: var(--text-muted)">No approved contesters.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<script>
    // Position Chart
    <c:if test="${not empty positionTotals}">
    const ctxPos = document.getElementById('positionChart').getContext('2d');
    new Chart(ctxPos, {
        type: 'doughnut',
        data: {
            labels: [<c:forEach var="stat" items="${positionTotals}" varStatus="status">[${status.index > 0 ? ',' : ''} "${stat[0]}"]</c:forEach>],
            datasets: [{ data: [<c:forEach var="stat" items="${positionTotals}" varStatus="status">[${status.index > 0 ? ',' : ''} ${stat[1]}]</c:forEach>], backgroundColor: ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'] }]
        },
        options: { responsive: true, plugins: { title: { display: true, text: 'Votes by Position' } } }
    });
    </c:if>

    // Top Contesters (top 5 by votes)
    <c:if test="${not empty contesters}">
    const topContesters = [<c:forEach var="c" items="${contesters}" varStatus="status">
        {name: '${c.user.firstName} ${c.user.lastName}', votes: ${voteCounts[c.id] == null ? 0 : voteCounts[c.id]}<c:if test="${!status.last}">,</c:if>}
    </c:forEach>];
    topContesters.sort((a,b) => b.votes - a.votes).slice(0,5);
    const ctxTop = document.getElementById('topContestersChart').getContext('2d');
    new Chart(ctxTop, {
        type: 'bar',
        data: {
            labels: topContesters.map(c => c.name),
            datasets: [{ label: 'Votes', data: topContesters.map(c => c.votes), backgroundColor: '#3b82f6' }]
        },
        options: { responsive: true, plugins: { title: { display: true, text: 'Top 5 Contesters' } }, scales: { y: { beginAtZero: true } } }
    });
    </c:if>
</script>

</body>
</html>
