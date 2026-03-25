<%@ page contentType="text/html;charset=UTF-8" %>
<%
    Object userObj = session.getAttribute("user");
    if (!(userObj instanceof com.bascode.model.entity.User)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    com.bascode.model.entity.User sessionUser = (com.bascode.model.entity.User) userObj;
    com.bascode.model.entity.User user = (com.bascode.model.entity.User) request.getAttribute("user");
    if (user == null) {
        user = sessionUser;
    }
    String adminPageTitle = "Profile";
    String activeAdminSection = "profile";
    String loadError = (String) request.getAttribute("loadError");
    String updateSuccess = (String) request.getAttribute("updateSuccess");
    String updateError = (String) request.getAttribute("updateError");
    String passwordSuccess = (String) request.getAttribute("passwordSuccess");
    String passwordError = (String) request.getAttribute("passwordError");
    String deleteError = (String) request.getAttribute("deleteError");
    String fullName = ((user.getFirstName() != null ? user.getFirstName() : "") + " " +
            (user.getLastName() != null ? user.getLastName() : "")).trim();
    String stateValue = user.getState() != null ? user.getState() : "";
    String countryValue = user.getCountry() != null ? user.getCountry() : "";
    String location = "";
    if (!stateValue.isBlank()) {
        location = stateValue;
    }
    if (!countryValue.isBlank()) {
        location = location.isEmpty() ? countryValue : location + ", " + countryValue;
    }
    String initial = user.getFirstName() != null && !user.getFirstName().isBlank()
        ? user.getFirstName().substring(0, 1).toUpperCase()
        : "?";
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
        <section class="admin-profile-hero">
            <div class="admin-profile-hero__avatar"><%= initial %></div>
            <div class="admin-profile-hero__content">
                <div class="dashboard-section__eyebrow">Profile</div>
                <h1 class="admin-profile-hero__title"><%= fullName.isEmpty() ? "Profile" : fullName %></h1>
                <p class="admin-profile-hero__email"><%= user.getEmail() %></p>
                <div class="admin-profile-hero__chips">
                    <span class="badge badge-approved"><i class="fas fa-user-shield"></i> <%= user.getRole() %></span>
                    <span class="badge badge-pending"><i class="fas fa-location-dot"></i> <%= location.isEmpty() ? "Location not set" : location %></span>
                </div>
            </div>
            <div class="admin-profile-hero__meta">
                <div class="admin-profile-stat">
                    <span>Birth year</span>
                    <strong><%= user.getBirthYear() %></strong>
                </div>
                <div class="admin-profile-stat">
                    <span>Workspace</span>
                    <strong>Administrator</strong>
                </div>
            </div>
        </section>

        <% if (loadError != null) { %>
            <div class="admin-alert admin-alert--warning"><strong>Profile info may be outdated.</strong> <%= loadError %></div>
        <% } %>

        <div class="admin-profile-grid">
            <article class="card">
                <div class="header" style="margin-bottom: 1.1rem;">
                    <h2>Edit profile</h2>
                    <p>Keep your personal details current and accurate.</p>
                </div>
                <div class="stack">
                    <% if (updateSuccess != null) { %>
                        <div class="admin-alert admin-alert--success"><strong>Saved.</strong> <%= updateSuccess %></div>
                    <% } %>
                    <% if (updateError != null) { %>
                        <div class="admin-alert admin-alert--error"><strong>Profile update failed.</strong> <%= updateError %></div>
                    <% } %>

                    <form method="post" action="${pageContext.request.contextPath}/profile" class="stack">
                        <input type="hidden" name="action" value="update">
                        <div class="admin-form-grid">
                            <label class="admin-form-field">
                                <span>First name</span>
                                <input class="admin-input" type="text" name="firstName" value="<%= user.getFirstName() != null ? user.getFirstName() : "" %>" required>
                            </label>
                            <label class="admin-form-field">
                                <span>Last name</span>
                                <input class="admin-input" type="text" name="lastName" value="<%= user.getLastName() != null ? user.getLastName() : "" %>" required>
                            </label>
                        </div>
                        <div class="admin-form-grid">
                            <label class="admin-form-field">
                                <span>Email address</span>
                                <input class="admin-input" type="email" value="<%= user.getEmail() %>" readonly>
                            </label>
                            <label class="admin-form-field">
                                <span>Birth year</span>
                                <input class="admin-input" type="number" value="<%= user.getBirthYear() %>" readonly>
                            </label>
                        </div>
                        <div class="admin-form-grid">
                            <label class="admin-form-field">
                                <span>State</span>
                                <input class="admin-input" type="text" name="state" value="<%= stateValue %>">
                            </label>
                            <label class="admin-form-field">
                                <span>Country</span>
                                <input class="admin-input" type="text" name="country" value="<%= countryValue %>">
                            </label>
                        </div>
                        <div class="table-actions">
                            <button type="submit" class="btn btn-primary"><i class="fas fa-floppy-disk"></i> Save changes</button>
                        </div>
                    </form>
                </div>
            </article>

            <article class="card">
                <div class="header" style="margin-bottom: 1.1rem;">
                    <h2>Change password</h2>
                    <p>Use a strong password to keep your account secure.</p>
                </div>
                <div class="stack">
                    <% if (passwordSuccess != null) { %>
                        <div class="admin-alert admin-alert--success"><strong>Password updated.</strong> <%= passwordSuccess %></div>
                    <% } %>
                    <% if (passwordError != null) { %>
                        <div class="admin-alert admin-alert--error"><strong>Password update failed.</strong> <%= passwordError %></div>
                    <% } %>

                    <form method="post" action="${pageContext.request.contextPath}/profile" class="stack">
                        <input type="hidden" name="action" value="password">
                        <label class="admin-form-field">
                            <span>Current password</span>
                            <input class="admin-input" type="password" name="currentPassword" required>
                        </label>
                        <div class="admin-form-grid">
                            <label class="admin-form-field">
                                <span>New password</span>
                                <input class="admin-input" type="password" name="newPassword" minlength="8" required>
                            </label>
                            <label class="admin-form-field">
                                <span>Confirm new password</span>
                                <input class="admin-input" type="password" name="confirmPassword" minlength="8" required>
                            </label>
                        </div>
                        <div class="table-actions">
                            <button type="submit" class="btn btn-primary"><i class="fas fa-key"></i> Update password</button>
                        </div>
                    </form>
                </div>
            </article>
        </div>

        <article class="card admin-danger-card">
            <div class="header" style="margin-bottom: 1.1rem;">
                <h2>Account controls</h2>
                <p>High-impact actions stay here so they don't interrupt the rest of your admin workflow.</p>
            </div>
            <div class="stack">
                <% if (deleteError != null) { %>
                    <div class="admin-alert admin-alert--error"><strong>Account not deleted.</strong> <%= deleteError %></div>
                <% } %>
                <div class="admin-danger-card__copy">
                    <strong>Delete account</strong>
                    <span>This permanently removes your account, votes, and contester record from the system.</span>
                </div>
                <form method="post" action="${pageContext.request.contextPath}/profile" class="admin-danger-form">
                    <input type="hidden" name="action" value="delete">
                    <label class="admin-form-field">
                        <span>Confirm with your password</span>
                        <input class="admin-input" type="password" name="deletePassword" required>
                    </label>
                    <div class="table-actions">
                        <button type="submit" class="btn btn-danger"><i class="fas fa-trash"></i> Delete account</button>
                    </div>
                </form>
            </div>
        </article>
    </div>
</div>

</body>
</html>
