<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Voters | Admin</title>
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
        <li><a href="${pageContext.request.contextPath}/voters" class="active"><i class="fas fa-users"></i> Voters</a></li>
        <li><a href="${pageContext.request.contextPath}/contesters"><i class="fas fa-user-tie"></i> Contesters</a></li>
        <li><a href="${pageContext.request.contextPath}/pending-approvals"><i class="fas fa-user-check"></i> Approvals</a></li>
        <li><a href="${pageContext.request.contextPath}/voter-stats"><i class="fas fa-chart-bar"></i> Voting Results</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/monitor"><i class="fas fa-server"></i> System Monitor</a></li>
    </ul>
</div>

<div class="main-content">
    <div class="header">
        <h1>Voters Management</h1>
        <p style="color: var(--text-muted)">View and manage all registered voters in the system.</p>
    </div>

    <div class="card" style="margin-bottom: 2rem;">
        <form action="${pageContext.request.contextPath}/voters" method="GET" style="display: flex; gap: 1rem;">
            <input type="text" name="search" value="${search}" placeholder="Search by name or email..." 
                   style="flex: 1; padding: 0.5rem 1rem; border-radius: 0.375rem; border: 1px solid var(--border-color);">
            <button type="submit" class="btn btn-primary">Search</button>
            <c:if test="${not empty search}">
                <a href="${pageContext.request.contextPath}/voters" class="btn" style="background: #e5e7eb; color: var(--text-main)">Clear</a>
            </c:if>
        </form>
    </div>

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Birth Year</th>
                    <th>Location</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="v" items="${voters}">
                    <tr>
                        <td>#${v.id}</td>
                        <td><strong>${v.firstName} ${v.lastName}</strong></td>
                        <td>${v.email}</td>
                        <td>${v.birthYear}</td>
                        <td>${v.state}, ${v.country}</td>
                        <td>
                            <c:choose>
                                <c:when test="${v.emailVerified}">
                                    <span class="badge badge-approved">Verified</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-pending">Pending</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty voters}">
                    <tr>
                        <td colspan="6" style="text-align: center; color: var(--text-muted)">No voters found.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>