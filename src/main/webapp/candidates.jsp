<%@ page contentType="text/html;charset=UTF-8"
    import="java.util.Collections,java.util.List,java.util.Map,com.bascode.model.entity.Contester" %>
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

    private String contesterName(Contester contester) {
        if (contester == null || contester.getUser() == null) {
            return "Unnamed candidate";
        }
        String first = contester.getUser().getFirstName() != null ? contester.getUser().getFirstName().trim() : "";
        String last = contester.getUser().getLastName() != null ? contester.getUser().getLastName().trim() : "";
        String fullName = (first + " " + last).trim();
        return fullName.isEmpty() ? "Unnamed candidate" : fullName;
    }

    private String contesterInitial(Contester contester) {
        if (contester != null && contester.getUser() != null) {
            String first = contester.getUser().getFirstName();
            if (first != null) {
                first = first.trim();
                if (!first.isEmpty()) {
                    return first.substring(0, 1).toUpperCase();
                }
            }
            String last = contester.getUser().getLastName();
            if (last != null) {
                last = last.trim();
                if (!last.isEmpty()) {
                    return last.substring(0, 1).toUpperCase();
                }
            }
        }
        return "?";
    }
%>
<%
    Object userObj = session.getAttribute("user");
    if (!(userObj instanceof com.bascode.model.entity.User)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    com.bascode.model.entity.User user = (com.bascode.model.entity.User) userObj;
    if (!com.bascode.model.enums.Role.VOTER.equals(user.getRole()) && !com.bascode.model.enums.Role.CONTESTER.equals(user.getRole())) {
        response.sendError(403);
        return;
    }

    String pageTitle = "Candidates";
    String activeSection = "candidates";
    String pageError = request.getAttribute("pageError") != null
        ? request.getAttribute("pageError").toString()
        : null;
    @SuppressWarnings("unchecked")
    Map<String, List<Contester>> candidatesByPosition = request.getAttribute("candidatesByPosition") instanceof Map<?, ?>
        ? (Map<String, List<Contester>>) request.getAttribute("candidatesByPosition")
        : Collections.emptyMap();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/portal-head.jspf" %>
</head>
<body class="portal-body">
<%@ include file="/WEB-INF/views/fragment/portal-navbar.jspf" %>

<main class="portal-shell">
    <section class="portal-hero">
        <div class="portal-hero__eyebrow"><i class="fas fa-users-viewfinder"></i> Approved ballot</div>
        <h1 class="portal-hero__title">Meet the candidates.</h1>
        <p class="portal-hero__subtitle">
            Every approved contester is grouped by position so you can compare the ballot quickly and move to voting with confidence.
        </p>
    </section>

    <section class="portal-stack" style="margin-top: 1.6rem;">
        <% if (pageError != null && !pageError.isBlank()) { %>
            <div class="portal-alert portal-alert--warning"><strong>Heads up.</strong> <%= h(pageError) %></div>
        <% } %>

        <% if (candidatesByPosition.isEmpty()) { %>
            <div class="portal-card">
                <div class="portal-empty">
                    <h2>No candidates yet</h2>
                    <p>No approved candidates have been registered for this election.</p>
                </div>
            </div>
        <% } %>

        <% for (Map.Entry<String, List<Contester>> section : candidatesByPosition.entrySet()) { %>
            <article class="portal-card">
                <div class="portal-card__header">
                    <div>
                        <h2 class="portal-card__title"><%= h(section.getKey()) %></h2>
                        <p class="portal-card__subtitle">Review the approved contesters for this office before you cast your vote.</p>
                    </div>
                    <span class="portal-chip"><i class="fas fa-id-card"></i> Verified slate</span>
                </div>
                <div class="portal-card__body">
                    <div class="portal-candidates">
                        <% for (Contester candidate : section.getValue()) { %>
                            <article class="portal-candidate-card">
                                <div class="portal-candidate-card__top">
                                    <div class="portal-candidate-card__avatar"><%= h(contesterInitial(candidate)) %></div>
                                    <div>
                                        <p class="portal-candidate-card__name"><%= h(contesterName(candidate)) %></p>
                                        <p class="portal-candidate-card__meta"><%= h(candidate.getUser() != null ? candidate.getUser().getEmail() : "") %></p>
                                    </div>
                                </div>
                                <div class="portal-pill"><i class="fas fa-award"></i> <%= h(section.getKey()) %></div>
                                <div class="portal-action-card__footer">
                                    <a class="portal-button portal-button--primary" href="<%= request.getContextPath() %>/voter/vote">Vote for candidate</a>
                                </div>
                            </article>
                        <% } %>
                    </div>
                </div>
            </article>
        <% } %>
    </section>
</main>

</body>
</html>
