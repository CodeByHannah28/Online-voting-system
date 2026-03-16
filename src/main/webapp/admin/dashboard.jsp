<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/admin-layout.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>

<div class="sidebar">
    <div class="sidebar-header">
        <i class="fas fa-vote-yea"></i> Voting Admin
    </div>
    <ul class="nav-links">
        <li><a href="${pageContext.request.contextPath}/dashboard" class="active"><i class="fas fa-home"></i> Overview</a></li>
        <li><a href="${pageContext.request.contextPath}/voters"><i class="fas fa-users"></i> Voters</a></li>
        <li><a href="${pageContext.request.contextPath}/contesters"><i class="fas fa-user-tie"></i> Contesters</a></li>
        <li><a href="${pageContext.request.contextPath}/pending-approvals"><i class="fas fa-user-check"></i> Approvals <c:if test="${pendingApprovals > 0}"><span class="badge badge-pending" style="font-size: 10px; padding: 2px 6px; margin-left: 5px;">${pendingApprovals}</span></c:if></a></li>
        <li><a href="${pageContext.request.contextPath}/voter-stats"><i class="fas fa-chart-bar"></i> Voting Results</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/monitor"><i class="fas fa-server"></i> System Monitor</a></li>
    </ul>
</div>

<div class="main-content">
    <div class="header">
        <h1>Dashboard Overview</h1>
        <p style="color: var(--text-muted)">Welcome back, Joshua. Here's what's happening today.</p>
    </div>

    <div class="stats-grid">
        <div class="card">
            <div class="card-title">Total Voters</div>
            <div class="card-value">${votersCount}</div>
        </div>
        <div class="card">
            <div class="card-title">Total Contesters</div>
            <div class="card-value">${contestersCount}</div>
        </div>
        <div class="card">
            <div class="card-title">Votes Cast</div>
            <div class="card-value">${votesCount}</div>
        </div>
        <div class="card">
            <div class="card-title">Pending Approvals</div>
            <div class="card-value" style="color: var(--warning)">${pendingApprovals}</div>
        </div>
    </div>

    <div class="header" style="margin-top: 3rem;">
        <h2>Contesters by Position</h2>
    </div>
    
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>Position</th>
                    <th>Count</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="stat" items="${positionStats}">
                    <tr>
                        <td><strong>${stat[0]}</strong></td>
                        <td>${stat[1]}</td>
                    </tr>
                </c:forEach>
                <c:if test="${empty positionStats}">
                    <tr>
                        <td colspan="2" style="text-align: center; color: var(--text-muted)">No approved contesters yet.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>