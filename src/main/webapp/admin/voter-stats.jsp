<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.ArrayList,java.util.Collections,java.util.Comparator,java.util.List,java.util.Map,com.bascode.model.entity.Contester"%>
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

    private String js(Object value) {
        if (value == null) {
            return "";
        }
        return String.valueOf(value)
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", "\\n");
    }

    private long toLong(Object value) {
        return value instanceof Number ? ((Number) value).longValue() : 0L;
    }

    private String formatPositionLabel(Object value) {
        if (value == null) {
            return "Unknown position";
        }

        String raw = value.toString().trim();
        if (raw.isEmpty()) {
            return "Unknown position";
        }

        StringBuilder label = new StringBuilder();
        for (String word : raw.split("_")) {
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

    private String contesterName(Contester contester) {
        if (contester == null || contester.getUser() == null) {
            return "Unnamed contester";
        }
        String first = contester.getUser().getFirstName() != null ? contester.getUser().getFirstName().trim() : "";
        String last = contester.getUser().getLastName() != null ? contester.getUser().getLastName().trim() : "";
        String fullName = (first + " " + last).trim();
        return fullName.isEmpty() ? "Unnamed contester" : fullName;
    }

    private long voteCount(Map<Long, Long> voteCounts, Long contesterId) {
        if (voteCounts == null || contesterId == null) {
            return 0L;
        }
        Long count = voteCounts.get(contesterId);
        return count != null ? count : 0L;
    }

    private String voteShare(long totalVotes, long contesterVotes) {
        if (totalVotes <= 0 || contesterVotes <= 0) {
            return "&lt;1%";
        }

        long rounded = Math.round((contesterVotes * 100.0d) / totalVotes);
        if (rounded <= 0) {
            return "&lt;1%";
        }
        return rounded + "%";
    }
%>
<%
    String adminPageTitle = "Voting Results";
    String activeAdminSection = "results";
    String pageError = request.getAttribute("pageError") != null
        ? request.getAttribute("pageError").toString()
        : null;
    @SuppressWarnings("unchecked")
    List<Object[]> positionTotals = request.getAttribute("positionTotals") instanceof List<?>
        ? (List<Object[]>) request.getAttribute("positionTotals")
        : Collections.emptyList();
    @SuppressWarnings("unchecked")
    List<Contester> contesters = request.getAttribute("contesters") instanceof List<?>
        ? (List<Contester>) request.getAttribute("contesters")
        : Collections.emptyList();
    @SuppressWarnings("unchecked")
    Map<Long, Long> voteCounts = request.getAttribute("voteCounts") instanceof Map<?, ?>
        ? (Map<Long, Long>) request.getAttribute("voteCounts")
        : Collections.emptyMap();
    long totalVotes = toLong(request.getAttribute("totalVotes"));

    StringBuilder positionLabelsJs = new StringBuilder();
    StringBuilder positionDataJs = new StringBuilder();
    for (Object[] stat : positionTotals) {
        if (positionLabelsJs.length() > 0) {
            positionLabelsJs.append(", ");
            positionDataJs.append(", ");
        }
        positionLabelsJs.append('"').append(js(formatPositionLabel(stat != null && stat.length > 0 ? stat[0] : null))).append('"');
        positionDataJs.append(stat != null && stat.length > 1 ? toLong(stat[1]) : 0L);
    }

    List<Contester> topContesters = new ArrayList<>(contesters);
    topContesters.sort(new Comparator<Contester>() {
        @Override
        public int compare(Contester left, Contester right) {
            return Long.compare(voteCount(voteCounts, right.getId()), voteCount(voteCounts, left.getId()));
        }
    });
    if (topContesters.size() > 5) {
        topContesters = new ArrayList<>(topContesters.subList(0, 5));
    }

    StringBuilder topContestersDataJs = new StringBuilder();
    for (Contester contester : topContesters) {
        if (topContestersDataJs.length() > 0) {
            topContestersDataJs.append(", ");
        }
        topContestersDataJs.append("{name:\"")
                .append(js(contesterName(contester)))
                .append("\",votes:")
                .append(voteCount(voteCounts, contester.getId()))
                .append('}');
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/admin-head.jspf" %>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

<%@ include file="/WEB-INF/views/fragment/admin-sidebar.jspf" %>

<div class="main-content">
    <div class="stack">
        <div class="header">
            <h1>Voting results</h1>
            <p>Live vote counts across positions and contesters. Total selections recorded: <strong><%= totalVotes %></strong>.</p>
        </div>

        <% if (pageError != null && !pageError.isBlank()) { %>
            <div class="admin-alert admin-alert--warning"><strong>We hit a snag.</strong> <%= h(pageError) %></div>
        <% } %>

        <div class="chart-grid">
            <div class="card">
                <div class="card-title">Votes by position</div>
                <% if (!positionTotals.isEmpty()) { %>
                    <canvas id="positionChart"></canvas>
                <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-chart-pie"></i>
                        No vote distribution is available yet.
                    </div>
                <% } %>
            </div>
            <div class="card">
                <div class="card-title">Top contesters</div>
                <% if (!topContesters.isEmpty()) { %>
                    <canvas id="topContestersChart"></canvas>
                <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-chart-column"></i>
                        Approved contesters will appear here when voting data is available.
                    </div>
                <% } %>
            </div>
        </div>

        <div class="header">
            <h2>Results by position</h2>
            <p>Each row shows how much of the total vote count belongs to that office.</p>
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
                    <% if (positionTotals.isEmpty()) { %>
                        <tr>
                            <td colspan="3">
                                <div class="empty-state">
                                    <i class="fas fa-inbox"></i>
                                    No votes have been recorded by position yet.
                                </div>
                            </td>
                        </tr>
                    <% } else {
                        for (Object[] stat : positionTotals) {
                            long votes = stat != null && stat.length > 1 ? toLong(stat[1]) : 0L;
                            long percent = totalVotes > 0 ? Math.round((votes * 100.0d) / totalVotes) : 0L;
                    %>
                        <tr>
                            <td><strong><%= h(formatPositionLabel(stat != null && stat.length > 0 ? stat[0] : null)) %></strong></td>
                            <td><%= votes %></td>
                            <td><%= percent %>%</td>
                        </tr>
                    <%  }
                       } %>
                </tbody>
            </table>
        </div>

        <div class="header">
            <h2>Contester vote details</h2>
            <p>Compare each approved contester's raw vote total and share of the election.</p>
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
                    <% if (contesters.isEmpty()) { %>
                        <tr>
                            <td colspan="5">
                                <div class="empty-state">
                                    <i class="fas fa-inbox"></i>
                                    No approved contesters are available for vote analysis yet.
                                </div>
                            </td>
                        </tr>
                    <% } else {
                        for (Contester contester : contesters) {
                            long contesterVotes = voteCount(voteCounts, contester.getId());
                    %>
                        <tr>
                            <td>#<%= contester.getId() != null ? contester.getId() : 0 %></td>
                            <td><strong><%= h(contesterName(contester)) %></strong></td>
                            <td><%= h(formatPositionLabel(contester.getPosition())) %></td>
                            <td><span class="badge badge-approved"><%= contesterVotes %></span></td>
                            <td><%= voteShare(totalVotes, contesterVotes) %></td>
                        </tr>
                    <%  }
                       } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    <% if (!positionTotals.isEmpty()) { %>
    const positionLabels = [<%= positionLabelsJs %>];
    const positionData = [<%= positionDataJs %>];
    const ctxPos = document.getElementById('positionChart').getContext('2d');
    new Chart(ctxPos, {
        type: 'doughnut',
        data: {
            labels: positionLabels,
            datasets: [{
                data: positionData,
                backgroundColor: ['#1d4ed8', '#0f766e', '#d97706', '#dc2626', '#475569']
            }]
        },
        options: {
            responsive: true,
            plugins: {
                title: {
                    display: true,
                    text: 'Votes by Position'
                }
            }
        }
    });
    <% } %>

    <% if (!topContesters.isEmpty()) { %>
    const topContestersData = [<%= topContestersDataJs %>];
    const ctxTop = document.getElementById('topContestersChart').getContext('2d');
    new Chart(ctxTop, {
        type: 'bar',
        data: {
            labels: topContestersData.map(contester => contester.name),
            datasets: [{
                label: 'Votes',
                data: topContestersData.map(contester => contester.votes),
                backgroundColor: '#1d4ed8'
            }]
        },
        options: {
            responsive: true,
            plugins: {
                title: {
                    display: true,
                    text: 'Top 5 Contesters'
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
    <% } %>
</script>

</body>
</html>
