<%@ page contentType="text/html;charset=UTF-8"
    import="java.util.Collections,java.util.List,com.bascode.model.entity.Contester,com.bascode.model.enums.ContesterStatus,com.bascode.voter.ContesterRegistrationServlet.PositionOption" %>
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

    private String statusTitle(Contester contester) {
        if (contester == null || contester.getStatus() == null) {
            return "Application pending review";
        }
        if (contester.getStatus() == ContesterStatus.APPROVED) {
            return "Application approved";
        }
        if (contester.getStatus() == ContesterStatus.DENIED) {
            return "Application denied";
        }
        return "Application pending review";
    }

    private String statusClass(Contester contester, Object statusClassAttr) {
        if (statusClassAttr != null && !statusClassAttr.toString().isBlank()) {
            return statusClassAttr.toString();
        }
        if (contester == null || contester.getStatus() == null) {
            return "pending";
        }
        return contester.getStatus().name().toLowerCase();
    }

    private String optionIconClass(PositionOption option) {
        return option != null && option.isFull() ? "fa-ban" : "fa-bullseye";
    }

    private String optionStateLabel(PositionOption option) {
        return option != null && option.isFull() ? "Position full" : "Open position";
    }

    private String optionMeta(PositionOption option) {
        if (option == null) {
            return "";
        }
        String base = option.getApprovedCount() + "/3 approved slots filled.";
        if (option.isFull()) {
            return base + " New applications for this office are declined automatically.";
        }
        return base;
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
    String error = (String) request.getAttribute("error");
    String warning = (String) request.getAttribute("warning");
    String success = (String) request.getAttribute("success");
    Boolean alreadyRegistered = (Boolean) request.getAttribute("alreadyRegistered");
    String pageTitle = "Contester Registration";
    String activeSection = "contester";
    Contester contester = request.getAttribute("contester") instanceof Contester
        ? (Contester) request.getAttribute("contester")
        : null;
    String contesterPositionLabel = request.getAttribute("contesterPositionLabel") != null
        ? request.getAttribute("contesterPositionLabel").toString()
        : "";
    Object contesterStatusClass = request.getAttribute("contesterStatusClass");
    @SuppressWarnings("unchecked")
    List<PositionOption> positionOptions = request.getAttribute("positionOptions") instanceof List<?>
        ? (List<PositionOption>) request.getAttribute("positionOptions")
        : Collections.emptyList();
    boolean hasAvailablePositions = false;
    for (PositionOption option : positionOptions) {
        if (option != null && !option.isFull()) {
            hasAvailablePositions = true;
            break;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/portal-head.jspf" %>
</head>
<body class="portal-body">
<%@ include file="/WEB-INF/views/fragment/portal-navbar.jspf" %>

<main class="portal-shell portal-shell--narrow">
    <section class="portal-hero">
        <div class="portal-hero__eyebrow"><i class="fas fa-user-plus"></i> Election participation</div>
        <h1 class="portal-hero__title">Register as a contester.</h1>
        <p class="portal-hero__subtitle">
            Apply for the office you want to contest and track your approval status in one place.
        </p>
    </section>

    <section class="portal-card" style="margin-top: 1.6rem;">
        <div class="portal-card__header">
            <div>
                <h2 class="portal-card__title">Application portal</h2>
                <p class="portal-card__subtitle">Each position can have up to three approved contesters at a time.</p>
            </div>
            <span class="portal-chip"><i class="fas fa-file-signature"></i> Application flow</span>
        </div>
        <div class="portal-card__body portal-stack">
            <% if (success != null) { %>
                <div class="portal-alert portal-alert--success"><strong>Application submitted.</strong> <%= h(success) %></div>
            <% } %>
            <% if (error != null) { %>
                <div class="portal-alert portal-alert--error"><strong>Something needs attention.</strong> <%= h(error) %></div>
            <% } %>
            <% if (warning != null) { %>
                <div class="portal-alert portal-alert--warning"><strong>Heads up.</strong> <%= h(warning) %></div>
            <% } %>

            <% if (Boolean.TRUE.equals(alreadyRegistered)) { %>
                <% if (contester != null) { %>
                    <div class="portal-status-card portal-status-card--<%= h(statusClass(contester, contesterStatusClass)) %>">
                        <h2 class="portal-status-card__title"><%= h(statusTitle(contester)) %></h2>
                        <p class="portal-status-card__text">
                            Position on file: <strong><%= h(contesterPositionLabel) %></strong>
                        </p>
                    </div>
                <% } %>
            <% } else { %>
                <% if (positionOptions.isEmpty()) { %>
                    <div class="portal-empty">
                        <h2>No positions available right now</h2>
                        <p>Refresh the page in a moment or contact an administrator if this keeps happening.</p>
                    </div>
                <% } else { %>
                    <form method="post" action="<%= request.getContextPath() %>/voter/register-contester" class="portal-stack">
                        <% for (PositionOption option : positionOptions) { %>
                            <label class="portal-choice">
                                <input type="radio" name="position" value="<%= h(option.getValue()) %>" <%= option.isFull() ? "disabled" : "" %> <%= hasAvailablePositions ? "required" : "" %>>
                                <span class="portal-choice__content">
                                    <span class="portal-choice__title"><%= h(option.getLabel()) %></span>
                                    <span class="portal-choice__meta"><%= h(optionMeta(option)) %></span>
                                </span>
                                <span class="portal-pill">
                                    <i class="fas <%= optionIconClass(option) %>"></i>
                                    <%= h(optionStateLabel(option)) %>
                                </span>
                            </label>
                        <% } %>

                        <% if (hasAvailablePositions) { %>
                            <div class="portal-actions" style="justify-content: flex-start;">
                                <button type="submit" class="portal-button portal-button--primary">
                                    <i class="fas fa-paper-plane"></i> Submit application
                                </button>
                            </div>
                        <% } else { %>
                            <div class="portal-empty">
                                <h2>All positions are currently full</h2>
                                <p>A maximum of three approved contesters is allowed per position. Please check back later.</p>
                            </div>
                        <% } %>
                    </form>
                <% } %>
            <% } %>
        </div>
    </section>
</main>

</body>
</html>
