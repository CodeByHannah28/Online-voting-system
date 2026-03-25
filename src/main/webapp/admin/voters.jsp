<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.net.URLEncoder,java.nio.charset.StandardCharsets,java.util.Collections,java.util.List,com.bascode.model.entity.User"%>
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

    private String displayName(User user) {
        if (user == null) {
            return "Unnamed voter";
        }
        String first = user.getFirstName() != null ? user.getFirstName().trim() : "";
        String last = user.getLastName() != null ? user.getLastName().trim() : "";
        String fullName = (first + " " + last).trim();
        return fullName.isEmpty() ? "Unnamed voter" : fullName;
    }

    private String locationLabel(User user) {
        if (user == null) {
            return "Location not set";
        }
        String state = user.getState() != null ? user.getState().trim() : "";
        String country = user.getCountry() != null ? user.getCountry().trim() : "";
        if (state.isEmpty() && country.isEmpty()) {
            return "Location not set";
        }
        if (state.isEmpty()) {
            return country;
        }
        if (country.isEmpty()) {
            return state;
        }
        return state + ", " + country;
    }

    private String roleLabel(User user) {
        if (user == null || user.getRole() == null) {
            return "Unassigned";
        }
        String raw = user.getRole().name().toLowerCase();
        return Character.toUpperCase(raw.charAt(0)) + raw.substring(1);
    }

    private String pageHref(String contextPath, String search, int page) {
        StringBuilder href = new StringBuilder(contextPath).append("/admin/voters?page=").append(page);
        if (search != null && !search.isBlank()) {
            href.append("&search=").append(URLEncoder.encode(search, StandardCharsets.UTF_8));
        }
        return href.toString();
    }
%>
<%
    String adminPageTitle = "Voters";
    String activeAdminSection = "voters";
    String searchValue = request.getAttribute("search") != null
        ? request.getAttribute("search").toString()
        : "";
    String pageError = request.getAttribute("pageError") != null
        ? request.getAttribute("pageError").toString()
        : null;
    @SuppressWarnings("unchecked")
    List<User> voters = request.getAttribute("voters") instanceof List<?>
        ? (List<User>) request.getAttribute("voters")
        : Collections.emptyList();
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
            <h1>Voters management</h1>
            <p>View and filter every registered voter and contester account from one streamlined table.</p>
        </div>

        <% if (pageError != null && !pageError.isBlank()) { %>
            <div class="admin-alert admin-alert--warning"><strong>We hit a snag.</strong> <%= h(pageError) %></div>
        <% } %>

        <div class="card">
            <div class="toolbar">
                <form action="<%= request.getContextPath() %>/admin/voters" method="GET">
                    <input class="admin-input" type="text" name="search" value="<%= h(searchValue) %>" placeholder="Search by name or email">
                    <button type="submit" class="btn btn-primary"><i class="fas fa-magnifying-glass"></i> Search</button>
                    <% if (!searchValue.isBlank()) { %>
                        <a href="<%= request.getContextPath() %>/admin/voters" class="btn btn-muted"><i class="fas fa-rotate-left"></i> Clear</a>
                    <% } %>
                </form>
            </div>
        </div>

        <div class="page-summary">
            <span>Showing <strong><%= showingFrom %>-<%= showingTo %></strong> of <strong><%= totalResults %></strong> eligible voter accounts.</span>
            <span>Page <strong><%= currentPage %></strong> of <strong><%= totalPages %></strong></span>
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
                        <th>Role</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (voters.isEmpty()) { %>
                        <tr>
                            <td colspan="7">
                                <div class="empty-state">
                                    <i class="fas fa-inbox"></i>
                                    No voters matched the current search.
                                </div>
                            </td>
                        </tr>
                    <% } else {
                        for (User voter : voters) {
                    %>
                        <tr>
                            <td>#<%= voter.getId() != null ? voter.getId() : 0 %></td>
                            <td><strong><%= h(displayName(voter)) %></strong></td>
                            <td><%= h(voter.getEmail()) %></td>
                            <td><%= voter.getBirthYear() %></td>
                            <td><%= h(locationLabel(voter)) %></td>
                            <td><%= h(roleLabel(voter)) %></td>
                            <td>
                                <% if (voter.isEmailVerified()) { %>
                                    <span class="badge badge-approved">Verified</span>
                                <% } else { %>
                                    <span class="badge badge-pending">Pending</span>
                                <% } %>
                            </td>
                        </tr>
                    <%  }
                       } %>
                </tbody>
            </table>
        </div>

        <% if (totalPages > 1) { %>
            <div class="pagination-bar">
                <div class="meta-note">Use the pager to move through the voter roll without losing your current search.</div>
                <div class="pagination">
                    <% if (currentPage > 1) { %>
                        <a class="pagination__link" href="<%= h(pageHref(request.getContextPath(), searchValue, currentPage - 1)) %>">
                            <i class="fas fa-arrow-left"></i> Previous
                        </a>
                    <% } %>
                    <% for (int pageNumber = 1; pageNumber <= totalPages; pageNumber++) { %>
                        <% if (pageNumber == currentPage) { %>
                            <span class="pagination__current"><%= pageNumber %></span>
                        <% } else { %>
                            <a class="pagination__link" href="<%= h(pageHref(request.getContextPath(), searchValue, pageNumber)) %>"><%= pageNumber %></a>
                        <% } %>
                    <% } %>
                    <% if (currentPage < totalPages) { %>
                        <a class="pagination__link" href="<%= h(pageHref(request.getContextPath(), searchValue, currentPage + 1)) %>">
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
