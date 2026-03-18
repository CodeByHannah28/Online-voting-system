<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pending Approvals | Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/admin-layout.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
        <li><a href="${pageContext.request.contextPath}/admin/pending-approvals" class="active"><i class="fas fa-user-check"></i> Approvals</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/voter-stats"><i class="fas fa-chart-bar"></i> Voting Results</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/monitor"><i class="fas fa-server"></i> System Monitor</a></li>
    </ul>
</div>

<div class="main-content">
    <div class="header">
        <h1>Pending Approvals</h1>
        <p style="color: var(--text-muted)">Review and approve/deny contester applications.</p>
    </div>

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Position</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="c" items="${pendingContesters}">
                    <tr>
                        <td>#${c.id}</td>
                        <td><strong>${c.user.firstName} ${c.user.lastName}</strong></td>
                        <td>${c.user.email}</td>
                        <td>${c.position}</td>
                        <td style="display: flex; gap: 0.5rem;">
                            <form action="${pageContext.request.contextPath}/admin/pending-approvals" method="POST" style="display: inline;">
                                <input type="hidden" name="id" value="${c.id}">
                                <input type="hidden" name="action" value="approve">
                                <button type="submit" class="btn btn-success" style="padding: 0.25rem 0.75rem; font-size: 0.75rem;">Approve</button>
                            </form>
                            <form action="${pageContext.request.contextPath}/admin/pending-approvals" method="POST" style="display: inline;">
                                <input type="hidden" name="id" value="${c.id}">
                                <input type="hidden" name="action" value="deny">
                                <button type="submit" class="btn btn-danger" style="padding: 0.25rem 0.75rem; font-size: 0.75rem;">Deny</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty pendingContesters}">
                    <tr>
                        <td colspan="5" style="text-align: center; padding: 2rem; color: var(--text-muted)">
                            <i class="fas fa-check-circle" style="font-size: 2rem; display: block; margin-bottom: 1rem; color: var(--success)"></i>
                            All caught up! No pending approvals.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>