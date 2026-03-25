<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.Collections,java.util.List,java.util.Map,com.bascode.model.entity.AdminAuditLog,com.bascode.model.entity.ContactMessage"%>
<%!
    private String h(Object value) {
        if (value == null) {
            return "";
        }
        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String formatTimestamp(Object value) {
        if (value == null) {
            return "Not recorded";
        }
        return value.toString().replace('T', ' ');
    }

    private String preview(String message) {
        if (message == null || message.isBlank()) {
            return "No message body was provided.";
        }
        String normalized = message.replace("\r", " ").replace("\n", " ").trim();
        return normalized.length() <= 130 ? normalized : normalized.substring(0, 127) + "...";
    }

    private String actionLabel(AdminAuditLog log) {
        if (log == null || log.getAction() == null) {
            return "Unknown action";
        }
        return log.getAction().replace('_', ' ');
    }
%>
<%
    String adminPageTitle = "System Monitor";
    String activeAdminSection = "monitor";
    String pageError = request.getAttribute("pageError") != null
        ? request.getAttribute("pageError").toString()
        : null;
    String pageSuccess = request.getAttribute("pageSuccess") != null
        ? request.getAttribute("pageSuccess").toString()
        : null;
    @SuppressWarnings("unchecked")
    Map<String, Object> stats = request.getAttribute("stats") instanceof Map<?, ?>
        ? (Map<String, Object>) request.getAttribute("stats")
        : Collections.emptyMap();
    @SuppressWarnings("unchecked")
    List<AdminAuditLog> auditLogs = request.getAttribute("auditLogs") instanceof List<?>
        ? (List<AdminAuditLog>) request.getAttribute("auditLogs")
        : Collections.emptyList();
    @SuppressWarnings("unchecked")
    List<ContactMessage> contactMessages = request.getAttribute("contactMessages") instanceof List<?>
        ? (List<ContactMessage>) request.getAttribute("contactMessages")
        : Collections.emptyList();
    boolean votingClosed = request.getAttribute("votingClosed") instanceof Boolean
        ? (Boolean) request.getAttribute("votingClosed")
        : false;
    String votingDeadlineInputValue = request.getAttribute("votingDeadlineInputValue") != null
        ? request.getAttribute("votingDeadlineInputValue").toString()
        : "";
    String votingDeadlineDisplay = request.getAttribute("votingDeadlineDisplay") != null
        ? request.getAttribute("votingDeadlineDisplay").toString()
        : "No voting deadline is scheduled.";
    String votingDeadlineUpdatedBy = request.getAttribute("votingDeadlineUpdatedBy") != null
        ? request.getAttribute("votingDeadlineUpdatedBy").toString()
        : "No administrator has updated the deadline yet.";
    String votingDeadlineUpdatedAt = request.getAttribute("votingDeadlineUpdatedAt") != null
        ? request.getAttribute("votingDeadlineUpdatedAt").toString()
        : "No deadline updates have been recorded yet.";
    long auditLogCount = request.getAttribute("auditLogCount") instanceof Number
        ? ((Number) request.getAttribute("auditLogCount")).longValue()
        : 0L;
    long contactMessageCount = request.getAttribute("contactMessageCount") instanceof Number
        ? ((Number) request.getAttribute("contactMessageCount")).longValue()
        : 0L;
    long pendingApprovals = request.getAttribute("pendingApprovals") instanceof Number
        ? ((Number) request.getAttribute("pendingApprovals")).longValue()
        : 0L;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/admin-head.jspf" %>
</head>
<body>

<%@ include file="/WEB-INF/views/fragment/admin-sidebar.jspf" %>

<div class="main-content">
    <div class="stack">
        <div class="header">
            <h1>System monitor</h1>
            <p>Track runtime health, manage the voting window, and review recent admin activity from one operations screen.</p>
        </div>

        <% if (pageError != null && !pageError.isBlank()) { %>
            <div class="admin-alert admin-alert--warning"><strong>We hit a snag.</strong> <%= h(pageError) %></div>
        <% } %>
        <% if (pageSuccess != null && !pageSuccess.isBlank()) { %>
            <div class="admin-alert admin-alert--success"><strong>Saved.</strong> <%= h(pageSuccess) %></div>
        <% } %>

        <div class="stats-grid">
            <article class="card">
                <div class="card-title">JVM Heap Used</div>
                <div class="card-value">${stats.heapUsed / 1024 / 1024} MB</div>
                <div class="meta-note">${stats.heapUsagePercent}% of available heap is currently in use.</div>
                <div class="meter">
                    <div class="meter__fill" style="width: ${stats.heapUsagePercent}%;"></div>
                </div>
            </article>
            <article class="card">
                <div class="card-title">JVM Heap Max</div>
                <div class="card-value">${stats.heapMax / 1024 / 1024} MB</div>
                <div class="meta-note">Maximum heap available to the application.</div>
            </article>
            <article class="card">
                <div class="card-title">Active Threads</div>
                <div class="card-value">${stats.threadCount}</div>
                <div class="meta-note">Peak threads observed: ${stats.peakThreadCount}</div>
            </article>
            <article class="card">
                <div class="card-title">System Uptime</div>
                <div class="card-value">${stats.uptimeSeconds} sec</div>
                <div class="meta-note">Time since the monitor servlet booted.</div>
            </article>
            <article class="card">
                <div class="card-title">Contact Requests</div>
                <div class="card-value"><%= contactMessageCount %></div>
                <div class="meta-note">Total public contact messages saved to the operations inbox.</div>
            </article>
            <article class="card">
                <div class="card-title">Audit Entries</div>
                <div class="card-value"><%= auditLogCount %></div>
                <div class="meta-note">Admin actions recorded for approvals, assignments, and controls.</div>
            </article>
        </div>

        <div class="section-grid">
            <article class="card">
                <div class="card-title">Voting Window</div>
                <div class="card-value"><%= votingClosed ? "Closed" : "Open" %></div>
                <div class="meta-note">Current deadline: <strong><%= h(votingDeadlineDisplay) %></strong></div>
                <div class="meta-note">Last updated by <strong><%= h(votingDeadlineUpdatedBy) %></strong>.</div>
                <div class="meta-note">Last change recorded at <strong><%= h(votingDeadlineUpdatedAt) %></strong>.</div>

                <form action="<%= request.getContextPath() %>/admin/monitor" method="POST" class="stack" style="margin-top: 1rem;">
                    <input type="hidden" name="action" value="save-deadline">
                    <label class="admin-form-field">
                        <span>Voting deadline</span>
                        <input class="admin-input" type="datetime-local" name="votingDeadline" value="<%= h(votingDeadlineInputValue) %>">
                    </label>
                    <div class="table-actions">
                        <button type="submit" class="btn btn-primary"><i class="fas fa-clock"></i> Save deadline</button>
                    </div>
                </form>

                <form action="<%= request.getContextPath() %>/admin/monitor" method="POST" style="margin-top: 0.8rem;">
                    <input type="hidden" name="action" value="clear-deadline">
                    <button type="submit" class="btn btn-muted"><i class="fas fa-rotate-left"></i> Clear deadline</button>
                </form>
            </article>

            <article class="card">
                <div class="card-title">Operations Snapshot</div>
                <div class="card-value"><%= pendingApprovals %></div>
                <div class="meta-note">Pending contester approvals still waiting in the queue.</div>
                <div class="stack" style="margin-top: 1rem;">
                    <div class="table-cell-stack">
                        <strong>Support inbox</strong>
                        <span class="meta-note"><%= contactMessageCount %> contact messages are currently available for review.</span>
                    </div>
                    <div class="table-cell-stack">
                        <strong>Admin trail</strong>
                        <span class="meta-note"><%= auditLogCount %> audit entries are on file for operational review.</span>
                    </div>
                    <div class="table-cell-stack">
                        <strong>Voting state</strong>
                        <span class="meta-note">The election is currently <%= votingClosed ? "closed for new ballots." : "open for ballot submission." %></span>
                    </div>
                </div>
            </article>
        </div>

        <div class="header">
            <h2>Recent admin activity</h2>
            <p>Every major control action is captured here for quick review.</p>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Time</th>
                        <th>Admin</th>
                        <th>Action</th>
                        <th>Target</th>
                        <th>Details</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (auditLogs.isEmpty()) { %>
                        <tr>
                            <td colspan="5">
                                <div class="empty-state">
                                    <i class="fas fa-clipboard-list"></i>
                                    No admin actions have been recorded yet.
                                </div>
                            </td>
                        </tr>
                    <% } else {
                        for (AdminAuditLog auditLog : auditLogs) {
                    %>
                        <tr>
                            <td><%= h(formatTimestamp(auditLog.getCreatedAt())) %></td>
                            <td>
                                <div class="table-cell-stack">
                                    <strong><%= h(auditLog.getAdminName()) %></strong>
                                    <span class="meta-note"><%= h(auditLog.getAdminEmail()) %></span>
                                </div>
                            </td>
                            <td><span class="badge badge-approved"><%= h(actionLabel(auditLog)) %></span></td>
                            <td><%= h(auditLog.getTargetType()) %>#<%= auditLog.getTargetId() != null ? auditLog.getTargetId() : 0 %></td>
                            <td><%= h(auditLog.getDetails()) %></td>
                        </tr>
                    <%  }
                       } %>
                </tbody>
            </table>
        </div>

        <div class="header">
            <h2>Recent contact messages</h2>
            <p>The latest inbound messages from the public contact form are shown below.</p>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Time</th>
                        <th>Sender</th>
                        <th>Department</th>
                        <th>Organization</th>
                        <th>Message</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (contactMessages.isEmpty()) { %>
                        <tr>
                            <td colspan="5">
                                <div class="empty-state">
                                    <i class="fas fa-envelope-open-text"></i>
                                    No contact requests have been received yet.
                                </div>
                            </td>
                        </tr>
                    <% } else {
                        for (ContactMessage contactMessage : contactMessages) {
                    %>
                        <tr>
                            <td><%= h(formatTimestamp(contactMessage.getCreatedAt())) %></td>
                            <td>
                                <div class="table-cell-stack">
                                    <strong><%= h(contactMessage.getName()) %></strong>
                                    <span class="meta-note"><%= h(contactMessage.getEmail()) %></span>
                                </div>
                            </td>
                            <td><span class="badge badge-pending"><%= h(contactMessage.getDepartment()) %></span></td>
                            <td><%= h(contactMessage.getOrganization() != null ? contactMessage.getOrganization() : "Not provided") %></td>
                            <td><%= h(preview(contactMessage.getMessage())) %></td>
                        </tr>
                    <%  }
                       } %>
                </tbody>
            </table>
        </div>

        <div class="header">
            <h2>Environment information</h2>
            <p>Useful runtime details for troubleshooting deployment and configuration issues.</p>
        </div>

        <div class="table-container">
            <table>
                <tbody>
                    <tr>
                        <td><strong>Operating System</strong></td>
                        <td>${stats.osName} (${stats.osArch})</td>
                    </tr>
                    <tr>
                        <td><strong>OS Version</strong></td>
                        <td>${stats.osVersion}</td>
                    </tr>
                    <tr>
                        <td><strong>Servlet Container</strong></td>
                        <td>${pageContext.servletContext.serverInfo}</td>
                    </tr>
                    <tr>
                        <td><strong>Java Version</strong></td>
                        <td><%= System.getProperty("java.version") %></td>
                    </tr>
                    <tr>
                        <td><strong>Context Path</strong></td>
                        <td><code>${pageContext.request.contextPath}</code></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

</body>
</html>
