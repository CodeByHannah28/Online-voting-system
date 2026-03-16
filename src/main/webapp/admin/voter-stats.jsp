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
</head>
<body>

<div class="sidebar">
    <div class="sidebar-header">
        <i class="fas fa-vote-yea"></i> Voting Admin
    </div>
    <ul class="nav-links">
        <li><a href="${pageContext.request.contextPath}/dashboard"><i class="fas fa-home"></i> Overview</a></li>
        <li><a href="${pageContext.request.contextPath}/voters"><i class="fas fa-users"></i> Voters</a></li>
        <li><a href="${pageContext.request.contextPath}/contesters"><i class="fas fa-user-tie"></i> Contesters</a></li>
        <li><a href="${pageContext.request.contextPath}/pending-approvals"><i class="fas fa-user-check"></i> Approvals</a></li>
        <li><a href="${pageContext.request.contextPath}/voter-stats" class="active"><i class="fas fa-chart-bar"></i> Voting Results</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/monitor"><i class="fas fa-server"></i> System Monitor</a></li>
    </ul>
</div>

<div class="main-content">
    <div class="header">
        <h1>Voting Results</h1>
        <p style="color: var(--text-muted)">Live vote counts for each contester.</p>
    </div>

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>Contester ID</th>
                    <th>Name</th>
                    <th>Position</th>
                    <th>Votes</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="c" items="${contesters}">
                    <tr>
                        <td>#${c.id}</td>
                        <td><strong>${c.user.firstName} ${c.user.lastName}</strong></td>
                        <td>${c.position}</td>
                        <td>
                            <div style="display: flex; align-items: center; gap: 1rem;">
                                <span class="badge badge-approved" style="min-width: 40px; text-align: center;">
                                    <c:out value="${voteCounts[c.id] == null ? 0 : voteCounts[c.id]}"/>
                                </span>
                                <!-- Progress bar could go here if we had total votes -->
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty contesters}">
                    <tr>
                        <td colspan="4" style="text-align: center; color: var(--text-muted)">No contesters available.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>