<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.net.URLEncoder,java.nio.charset.StandardCharsets,java.util.Collections,java.util.List,java.util.Map,com.bascode.model.entity.Contester,com.bascode.model.enums.ContesterStatus"%>
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

    private String displayName(Contester contester) {
        if (contester == null || contester.getUser() == null) {
            return "Unnamed contester";
        }
        String first = contester.getUser().getFirstName() != null ? contester.getUser().getFirstName().trim() : "";
        String last = contester.getUser().getLastName() != null ? contester.getUser().getLastName().trim() : "";
        String fullName = (first + " " + last).trim();
        return fullName.isEmpty() ? "Unnamed contester" : fullName;
    }

    private String positionLabel(Contester contester) {
        if (contester == null || contester.getPosition() == null) {
            return "Unassigned";
        }
        String raw = contester.getPosition().name();
        String[] words = raw.split("_");
        StringBuilder label = new StringBuilder();
        for (String word : words) {
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

    private String statusClass(ContesterStatus status) {
        if (status == ContesterStatus.APPROVED) {
            return "badge badge-approved";
        }
        if (status == ContesterStatus.PENDING) {
            return "badge badge-pending";
        }
        return "badge badge-denied";
    }

    private String statusLabel(ContesterStatus status) {
        if (status == null) {
            return "Unknown";
        }
        String raw = status.name().toLowerCase();
        return Character.toUpperCase(raw.charAt(0)) + raw.substring(1);
    }

    private boolean awaitingPosition(Contester contester) {
        return contester == null || contester.getPosition() == null;
    }

    private String positionOptionLabel(Map<String, String> labels, Object value) {
        if (value == null) {
            return "Unassigned";
        }
        if (labels == null) {
            return value.toString();
        }
        String key = value.toString();
        String label = labels.get(key);
        return label != null ? label : key;
    }

    private String pageHref(String contextPath, String search, String status, int page) {
        StringBuilder href = new StringBuilder(contextPath).append("/admin/contesters?page=").append(page);
        if (search != null && !search.isBlank()) {
            href.append("&search=").append(URLEncoder.encode(search, StandardCharsets.UTF_8));
        }
        if (status != null && !status.isBlank()) {
            href.append("&status=").append(URLEncoder.encode(status, StandardCharsets.UTF_8));
        }
        return href.toString();
    }
%>
<%
    String adminPageTitle = "Contesters";
    String activeAdminSection = "contesters";
    String selectedStatus = request.getAttribute("statusFilter") != null
        ? request.getAttribute("statusFilter").toString()
        : "";
    String searchValue = request.getAttribute("search") != null
        ? request.getAttribute("search").toString()
        : "";
    String pageError = request.getAttribute("pageError") != null
        ? request.getAttribute("pageError").toString()
        : null;
    String pageSuccess = request.getAttribute("pageSuccess") != null
        ? request.getAttribute("pageSuccess").toString()
        : null;
    @SuppressWarnings("unchecked")
    List<Contester> contesters = request.getAttribute("contesters") instanceof List<?>
        ? (List<Contester>) request.getAttribute("contesters")
        : Collections.emptyList();
    @SuppressWarnings("unchecked")
    Map<String, String> positionLabels = request.getAttribute("positionLabels") instanceof Map<?, ?>
        ? (Map<String, String>) request.getAttribute("positionLabels")
        : Collections.emptyMap();
    Object[] positions = request.getAttribute("positions") instanceof Object[]
        ? (Object[]) request.getAttribute("positions")
        : new Object[0];
    int currentPage = request.getAttribute("currentPage") instanceof Number
        ? ((Number) request.getAttribute("currentPage")).intValue()
        : 1;
    int totalPages = request.getAttribute("totalPages") instanceof Number
        ? ((Number) request.getAttribute("totalPages")).intValue()
        : 1;
    long totalResults = request.getAttribute("totalResults") instanceof Number
        ? ((Number) request.getAttribute("totalResults")).longValue()
        : 0L;
    long showingFrom = request.getAttribute("showingFrom") instanceof Number
        ? ((Number) request.getAttribute("showingFrom")).longValue()
        : 0L;
    long showingTo = request.getAttribute("showingTo") instanceof Number
        ? ((Number) request.getAttribute("showingTo")).longValue()
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
            <h1>Contesters</h1>
            <p>Review applications by name, email, and approval status without leaving the admin workspace.</p>
        </div>

        <% if (pageError != null && !pageError.isBlank()) { %>
            <div class="admin-alert admin-alert--warning"><strong>We hit a snag.</strong> <%= h(pageError) %></div>
        <% } %>
        <% if (pageSuccess != null && !pageSuccess.isBlank()) { %>
            <div class="admin-alert admin-alert--success"><strong>Saved.</strong> <%= h(pageSuccess) %></div>
        <% } %>

        <div class="card">
            <div class="toolbar">
                <form action="<%= request.getContextPath() %>/admin/contesters" method="GET">
                    <input class="admin-input" type="text" name="search" value="<%= h(searchValue) %>" placeholder="Search by name or email">
                    <select class="admin-select" name="status">
                        <option value="">All statuses</option>
                        <option value="PENDING" <%= "PENDING".equals(selectedStatus) ? "selected" : "" %>>Pending</option>
                        <option value="APPROVED" <%= "APPROVED".equals(selectedStatus) ? "selected" : "" %>>Approved</option>
                        <option value="DENIED" <%= "DENIED".equals(selectedStatus) ? "selected" : "" %>>Denied</option>
                    </select>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-filter"></i> Apply</button>
                    <% if (!searchValue.isBlank() || !selectedStatus.isBlank()) { %>
                        <a href="<%= request.getContextPath() %>/admin/contesters" class="btn btn-muted"><i class="fas fa-rotate-left"></i> Clear</a>
                    <% } %>
                </form>
            </div>
        </div>

        <div class="card admin-danger-card">
            <div class="admin-danger-form">
                <div class="admin-danger-card__copy">
                    <strong>Restart the election</strong>
                    <span>Remove every contester, clear all recorded votes, and return contester accounts to voter status so a fresh election can begin.</span>
                </div>
                <form class="inline-form" action="<%= request.getContextPath() %>/admin/contesters" method="POST"
                      onsubmit="return confirm('This will remove all contesters and delete all recorded votes. Continue?');">
                    <input type="hidden" name="action" value="clear-all">
                    <button type="submit" class="btn btn-danger"><i class="fas fa-trash-can"></i> Clear all contesters</button>
                </form>
            </div>
        </div>

        <div class="page-summary">
            <span>Showing <strong><%= showingFrom %>-<%= showingTo %></strong> of <strong><%= totalResults %></strong> contester applications.</span>
            <span>Page <strong><%= currentPage %></strong> of <strong><%= totalPages %></strong></span>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Current Position</th>
                        <th>Status</th>
                        <th>Position Control</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (contesters.isEmpty()) { %>
                        <tr>
                            <td colspan="5">
                                <div class="empty-state">
                                    <i class="fas fa-inbox"></i>
                                    No contesters matched the current filters.
                                </div>
                            </td>
                        </tr>
                    <% } else {
                        for (Contester contester : contesters) {
                    %>
                        <tr>
                            <td>#<%= contester.getId() != null ? contester.getId() : 0 %></td>
                            <td>
                                <div class="table-cell-stack">
                                    <strong><%= h(displayName(contester)) %></strong>
                                    <div class="meta-note"><%= h(contester.getUser() != null ? contester.getUser().getEmail() : "") %></div>
                                </div>
                            </td>
                            <td>
                                <div class="table-cell-stack">
                                    <strong><%= h(positionLabel(contester)) %></strong>
                                    <% if (awaitingPosition(contester)) { %>
                                        <span class="meta-note">This application still needs a position before it can move cleanly through approvals.</span>
                                    <% } %>
                                </div>
                            </td>
                            <td>
                                <% if (awaitingPosition(contester)) { %>
                                    <span class="badge badge-pending">Awaiting position</span>
                                <% } else { %>
                                    <span class="<%= statusClass(contester.getStatus()) %>"><%= h(statusLabel(contester.getStatus())) %></span>
                                <% } %>
                            </td>
                            <td>
                                <form class="inline-form" action="<%= request.getContextPath() %>/admin/contesters" method="POST">
                                    <input type="hidden" name="id" value="<%= contester.getId() != null ? contester.getId() : 0 %>">
                                    <input type="hidden" name="action" value="assign-position">
                                    <input type="hidden" name="search" value="<%= h(searchValue) %>">
                                    <input type="hidden" name="status" value="<%= h(selectedStatus) %>">
                                    <input type="hidden" name="page" value="<%= currentPage %>">
                                    <div class="table-actions table-actions--stacked">
                                        <select class="admin-select admin-select--compact" name="position">
                                            <% for (Object position : positions) { %>
                                                <option value="<%= h(position) %>" <%= contester.getPosition() == position ? "selected" : "" %>>
                                                    <%= h(positionOptionLabel(positionLabels, position)) %>
                                                </option>
                                            <% } %>
                                        </select>
                                        <button type="submit" class="btn btn-primary"><i class="fas fa-location-dot"></i> Save position</button>
                                    </div>
                                </form>
                            </td>
                        </tr>
                    <%  }
                       } %>
                </tbody>
            </table>
        </div>

        <% if (totalPages > 1) { %>
            <div class="pagination-bar">
                <div class="meta-note">Move through the contester register without losing the current filters.</div>
                <div class="pagination">
                    <% if (currentPage > 1) { %>
                        <a class="pagination__link" href="<%= h(pageHref(request.getContextPath(), searchValue, selectedStatus, currentPage - 1)) %>">
                            <i class="fas fa-arrow-left"></i> Previous
                        </a>
                    <% } %>
                    <% for (int pageNumber = 1; pageNumber <= totalPages; pageNumber++) { %>
                        <% if (pageNumber == currentPage) { %>
                            <span class="pagination__current"><%= pageNumber %></span>
                        <% } else { %>
                            <a class="pagination__link" href="<%= h(pageHref(request.getContextPath(), searchValue, selectedStatus, pageNumber)) %>"><%= pageNumber %></a>
                        <% } %>
                    <% } %>
                    <% if (currentPage < totalPages) { %>
                        <a class="pagination__link" href="<%= h(pageHref(request.getContextPath(), searchValue, selectedStatus, currentPage + 1)) %>">
                            Next <i class="fas fa-arrow-right"></i>
                        </a>
                    <% } %>
                </div>
            </div>
        <% } %>
    </div>
</div>

</body>
</html>
