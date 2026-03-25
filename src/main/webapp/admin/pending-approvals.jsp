<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.Collections,java.util.List,java.util.Map,com.bascode.model.entity.Contester"%>
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
%>
<%
    String adminPageTitle = "Pending Approvals";
    String activeAdminSection = "approvals";
    String pageError = request.getAttribute("pageError") != null
        ? request.getAttribute("pageError").toString()
        : null;
    String pageSuccess = request.getAttribute("pageSuccess") != null
        ? request.getAttribute("pageSuccess").toString()
        : null;
    @SuppressWarnings("unchecked")
    List<Contester> pendingContesters = request.getAttribute("pendingContesters") instanceof List<?>
        ? (List<Contester>) request.getAttribute("pendingContesters")
        : Collections.emptyList();
    @SuppressWarnings("unchecked")
    Map<String, String> positionLabels = request.getAttribute("positionLabels") instanceof Map<?, ?>
        ? (Map<String, String>) request.getAttribute("positionLabels")
        : Collections.emptyMap();
    Object[] positions = request.getAttribute("positions") instanceof Object[]
        ? (Object[]) request.getAttribute("positions")
        : new Object[0];
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
            <h1>Pending approvals</h1>
            <p>Approve, deny, or repair position assignments without leaving the review queue.</p>
        </div>

        <% if (pageError != null && !pageError.isBlank()) { %>
            <div class="admin-alert admin-alert--warning"><strong>We hit a snag.</strong> <%= h(pageError) %></div>
        <% } %>
        <% if (pageSuccess != null && !pageSuccess.isBlank()) { %>
            <div class="admin-alert admin-alert--success"><strong>Saved.</strong> <%= h(pageSuccess) %></div>
        <% } %>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Position</th>
                        <th>Decision Controls</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (pendingContesters.isEmpty()) { %>
                        <tr>
                            <td colspan="5">
                                <div class="empty-state">
                                    <i class="fas fa-circle-check"></i>
                                    All caught up. There are no pending approvals right now.
                                </div>
                            </td>
                        </tr>
                    <% } else {
                        for (Contester contester : pendingContesters) {
                    %>
                        <tr>
                            <td>#<%= contester.getId() != null ? contester.getId() : 0 %></td>
                            <td><strong><%= h(displayName(contester)) %></strong></td>
                            <td><%= h(contester.getUser() != null ? contester.getUser().getEmail() : "") %></td>
                            <td>
                                <div class="table-cell-stack">
                                    <strong><%= h(positionOptionLabel(positionLabels, contester.getPosition())) %></strong>
                                    <% if (contester.getPosition() == null) { %>
                                        <span class="meta-note">This application needs a position before approval.</span>
                                    <% } %>
                                </div>
                            </td>
                            <td>
                                <form class="inline-form" action="<%= request.getContextPath() %>/admin/pending-approvals" method="POST">
                                    <input type="hidden" name="id" value="<%= contester.getId() != null ? contester.getId() : 0 %>">
                                    <div class="table-actions table-actions--stacked">
                                        <select class="admin-select admin-select--compact" name="position">
                                            <option value="">Keep current position</option>
                                            <% for (Object position : positions) { %>
                                                <option value="<%= h(position) %>" <%= contester.getPosition() == position ? "selected" : "" %>>
                                                    <%= h(positionOptionLabel(positionLabels, position)) %>
                                                </option>
                                            <% } %>
                                        </select>
                                        <div class="table-actions">
                                            <button type="submit" name="action" value="save-position" class="btn btn-primary">
                                                <i class="fas fa-location-dot"></i> Save position
                                            </button>
                                            <button type="submit" name="action" value="approve" class="btn btn-success">
                                                <i class="fas fa-check"></i> Approve
                                            </button>
                                            <button type="submit" name="action" value="deny" class="btn btn-danger">
                                                <i class="fas fa-xmark"></i> Deny
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </td>
                        </tr>
                    <%  }
                       } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

</body>
</html>
