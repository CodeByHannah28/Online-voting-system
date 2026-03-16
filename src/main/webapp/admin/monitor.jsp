<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Monitor | Admin</title>
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
        <li><a href="${pageContext.request.contextPath}/voter-stats"><i class="fas fa-chart-bar"></i> Voting Results</a></li>
        <li><a href="${pageContext.request.contextPath}/admin/monitor" class="active"><i class="fas fa-server"></i> System Monitor</a></li>
    </ul>
</div>

<div class="main-content">
    <div class="header">
        <h1>System Performance</h1>
        <p style="color: var(--text-muted)">Real-time server health and resource monitoring.</p>
    </div>

    <div class="stats-grid">
        <div class="card">
            <div class="card-title">JVM Heap Used</div>
            <div class="card-value">${stats.heapUsed / 1024 / 1024} <span style="font-size: 0.875rem; color: var(--text-muted)">MB</span></div>
            <div style="background: #e5e7eb; height: 8px; border-radius: 4px; margin-top: 10px; overflow: hidden;">
                <div style="background: var(--primary-color); height: 100%; width: ${stats.heapUsagePercent}%"></div>
            </div>
        </div>
        <div class="card">
            <div class="card-title">JVM Heap Max</div>
            <div class="card-value">${stats.heapMax / 1024 / 1024} <span style="font-size: 0.875rem; color: var(--text-muted)">MB</span></div>
        </div>
        <div class="card">
            <div class="card-title">Active Threads</div>
            <div class="card-value">${stats.threadCount} <span style="font-size: 0.875rem; color: var(--text-muted)">(Peak: ${stats.peakThreadCount})</span></div>
        </div>
        <div class="card">
            <div class="card-title">System Uptime</div>
            <div class="card-value">${stats.uptimeSeconds} <span style="font-size: 0.875rem; color: var(--text-muted)">seconds</span></div>
        </div>
    </div>

    <div class="header" style="margin-top: 3rem;">
        <h2>Environment Information</h2>
    </div>
    
    <div class="table-container">
        <table>
            <tbody>
                <tr>
                    <td style="width: 200px; font-weight: 600;">Operating System</td>
                    <td>${stats.osName} (${stats.osArch})</td>
                </tr>
                <tr>
                    <td style="font-weight: 600;">Servlet Container</td>
                    <td>${pageContext.servletContext.serverInfo}</td>
                </tr>
                <tr>
                    <td style="font-weight: 600;">Java Version</td>
                    <td><%= System.getProperty("java.version") %></td>
                </tr>
                <tr>
                    <td style="font-weight: 600;">Context Path</td>
                    <td><code>${pageContext.request.contextPath}</code></td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>