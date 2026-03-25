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
    String updateSuccess = (String) request.getAttribute("updateSuccess");
    String updateError = (String) request.getAttribute("updateError");
    String passwordSuccess = (String) request.getAttribute("passwordSuccess");
    String passwordError = (String) request.getAttribute("passwordError");
    String deleteError = (String) request.getAttribute("deleteError");
    String pageTitle = "My Profile";
    String activeSection = "profile";
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
<%@ include file="/WEB-INF/views/fragment/portal-head.jspf" %>
</head>
<body class="portal-body">
<%@ include file="/WEB-INF/views/fragment/portal-navbar.jspf" %>

<main class="portal-shell portal-shell--narrow">
    <section class="portal-hero">
        <div class="portal-profile-summary">
            <div class="portal-profile-summary__avatar"><%= initial %></div>
            <div class="portal-chip"><i class="fas fa-user-shield"></i> <%= user.getRole() %></div>
            <h1 class="portal-profile-summary__name"><%= fullName.isEmpty() ? "Profile" : fullName %></h1>
            <p class="portal-profile-summary__email"><%= user.getEmail() %></p>
            <div class="portal-profile-list">
                <div class="portal-profile-list__item">
                    <span>Birth year</span>
                    <strong><%= user.getBirthYear() %></strong>
                </div>
                <div class="portal-profile-list__item">
                    <span>Location</span>
                    <strong><%= location.isEmpty() ? "Not set" : location %></strong>
                </div>
            </div>
        </div>
    </section>

    <section class="portal-grid portal-grid--split" style="margin-top: 1.6rem;">
        <article class="portal-card">
            <div class="portal-card__header">
                <div>
                    <h2 class="portal-card__title">Edit profile</h2>
                    <p class="portal-card__subtitle">Keep your personal details current and accurate.</p>
                </div>
            </div>
            <div class="portal-card__body portal-stack">
                <% if (updateSuccess != null) { %>
                    <div class="portal-alert portal-alert--success"><strong>Saved.</strong> <%= updateSuccess %></div>
                <% } %>
                <% if (updateError != null) { %>
                    <div class="portal-alert portal-alert--error"><strong>Profile update failed.</strong> <%= updateError %></div>
                <% } %>

                <form method="post" action="${pageContext.request.contextPath}/profile" class="portal-stack">
                    <input type="hidden" name="action" value="update">
                    <div class="portal-form-grid">
                        <div class="portal-form-group">
                            <label for="firstName">First name</label>
                            <input id="firstName" class="portal-input" type="text" name="firstName" value="<%= user.getFirstName() != null ? user.getFirstName() : "" %>" required>
                        </div>
                        <div class="portal-form-group">
                            <label for="lastName">Last name</label>
                            <input id="lastName" class="portal-input" type="text" name="lastName" value="<%= user.getLastName() != null ? user.getLastName() : "" %>" required>
                        </div>
                    </div>
                    <div class="portal-form-grid">
                        <div class="portal-form-group">
                            <label for="email">Email address</label>
                            <input id="email" class="portal-input" type="email" value="<%= user.getEmail() %>" readonly>
                        </div>
                        <div class="portal-form-group">
                            <label for="birthYear">Birth year</label>
                            <input id="birthYear" class="portal-input" type="number" value="<%= user.getBirthYear() %>" readonly>
                        </div>
                    </div>
                    <div class="portal-form-grid">
                        <div class="portal-form-group">
                            <label for="state">State</label>
                            <input id="state" class="portal-input" type="text" name="state" value="<%= stateValue %>">
                        </div>
                        <div class="portal-form-group">
                            <label for="country">Country</label>
                            <input id="country" class="portal-input" type="text" name="country" value="<%= countryValue %>">
                        </div>
                    </div>
                    <div class="portal-actions">
                        <button type="submit" class="portal-button portal-button--primary">
                            <i class="fas fa-floppy-disk"></i> Save changes
                        </button>
                    </div>
                </form>
            </div>
        </article>

        <article class="portal-card">
            <div class="portal-card__header">
                <div>
                    <h2 class="portal-card__title">Change password</h2>
                    <p class="portal-card__subtitle">Use a strong password to keep your account secure.</p>
                </div>
            </div>
            <div class="portal-card__body portal-stack">
                <% if (passwordSuccess != null) { %>
                    <div class="portal-alert portal-alert--success"><strong>Password updated.</strong> <%= passwordSuccess %></div>
                <% } %>
                <% if (passwordError != null) { %>
                    <div class="portal-alert portal-alert--error"><strong>Password update failed.</strong> <%= passwordError %></div>
                <% } %>

                <form method="post" action="${pageContext.request.contextPath}/profile" class="portal-stack">
                    <input type="hidden" name="action" value="password">
                    <div class="portal-form-group">
                        <label for="currentPassword">Current password</label>
                        <input id="currentPassword" class="portal-input" type="password" name="currentPassword" required>
                    </div>
                    <div class="portal-form-group">
                        <label for="newPassword">New password</label>
                        <input id="newPassword" class="portal-input" type="password" name="newPassword" minlength="8" required>
                    </div>
                    <div class="portal-form-group">
                        <label for="confirmPassword">Confirm new password</label>
                        <input id="confirmPassword" class="portal-input" type="password" name="confirmPassword" minlength="8" required>
                    </div>
                    <div class="portal-actions">
                        <button type="submit" class="portal-button portal-button--primary">
                            <i class="fas fa-key"></i> Update password
                        </button>
                    </div>
                </form>
            </div>
        </article>

        <article class="portal-card" style="grid-column: 1 / -1;">
            <div class="portal-card__header">
                <div>
                    <h2 class="portal-card__title">Account controls</h2>
                    <p class="portal-card__subtitle">Manage high-impact actions carefully.</p>
                </div>
                <span class="portal-chip"><i class="fas fa-triangle-exclamation"></i> Sensitive</span>
            </div>
            <div class="portal-card__body">
                <div class="portal-danger-zone">
                    <h3>Delete account</h3>
                    <p>This action permanently removes your account, associated votes, and saved election data.</p>
                    <% if (deleteError != null) { %>
                        <div class="portal-alert portal-alert--error" style="margin-top: 1rem;"><strong>Account not deleted.</strong> <%= deleteError %></div>
                    <% } %>
                    <div class="portal-actions" style="margin-top: 1rem; justify-content: flex-start;">
                        <button type="button" class="portal-button portal-button--danger" onclick="openDeleteModal()">
                            <i class="fas fa-trash"></i> Delete my account
                        </button>
                    </div>
                </div>
            </div>
        </article>
    </section>
</main>

<div class="portal-modal-backdrop" id="deleteModal">
    <div class="portal-modal">
        <div class="portal-modal__header">
            <div>
                <h2 class="portal-modal__title">Confirm account deletion</h2>
            </div>
            <button type="button" class="portal-modal__close" onclick="closeDeleteModal()">
                <i class="fas fa-xmark"></i>
            </button>
        </div>
        <p class="portal-modal__text">
            This will permanently delete your account. Enter your password to confirm the action.
        </p>
        <form method="post" action="${pageContext.request.contextPath}/profile" class="portal-stack">
            <input type="hidden" name="action" value="delete">
            <div class="portal-form-group">
                <label for="deletePassword">Password</label>
                <input id="deletePassword" class="portal-input" type="password" name="deletePassword" required>
            </div>
            <div class="portal-actions">
                <button type="button" class="portal-button portal-button--muted" onclick="closeDeleteModal()">Cancel</button>
                <button type="submit" class="portal-button portal-button--danger">Delete account</button>
            </div>
        </form>
    </div>
</div>

<script>
function openDeleteModal() {
    document.getElementById("deleteModal").classList.add("is-active");
}

function closeDeleteModal() {
    document.getElementById("deleteModal").classList.remove("is-active");
}
</script>

</body>
</html>
