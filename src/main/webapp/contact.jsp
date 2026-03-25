<%@ page contentType="text/html;charset=UTF-8" %>
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
%>
<%
    String pageTitle = "Contact";
    String activePage = "contact";
    String success = request.getAttribute("success") != null ? request.getAttribute("success").toString() : null;
    String error = request.getAttribute("error") != null ? request.getAttribute("error").toString() : null;
    String departmentValue = request.getAttribute("department") != null ? request.getAttribute("department").toString() : "Support";
    String organizationValue = request.getAttribute("organization") != null ? request.getAttribute("organization").toString() : "";
    String nameValue = request.getAttribute("name") != null ? request.getAttribute("name").toString() : "";
    String emailValue = request.getAttribute("email") != null ? request.getAttribute("email").toString() : "";
    String messageValue = request.getAttribute("messageValue") != null ? request.getAttribute("messageValue").toString() : "";

    Object sessionUser = session.getAttribute("user");
    if (sessionUser instanceof com.bascode.model.entity.User) {
        com.bascode.model.entity.User user = (com.bascode.model.entity.User) sessionUser;
        if (nameValue.isBlank()) {
            nameValue = (user.getFirstName() != null ? user.getFirstName() : "")
                    + ((user.getFirstName() != null && user.getLastName() != null) ? " " : "")
                    + (user.getLastName() != null ? user.getLastName() : "");
            nameValue = nameValue.trim();
        }
        if (emailValue.isBlank() && user.getEmail() != null) {
            emailValue = user.getEmail();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/site-head.jspf" %>
</head>
<body class="public-body">
<%@ include file="/WEB-INF/views/fragment/public-navbar.jspf" %>

<main>
    <section class="site-section" style="padding-top: 3.2rem;">
        <div class="site-shell site-split-panel">
            <div class="site-stack">
                <div class="site-section__header" style="margin-bottom: 0.4rem;">
                    <div class="site-section__eyebrow"><i class="fas fa-headset"></i> Contact</div>
                    <h1 class="site-section__title">Reach the Go Voter team.</h1>
                    <p class="site-section__text">
                        Whether you need implementation support, sales information, or partnership discussions in Nigeria or South Africa, this page gives your team a cleaner starting point.
                    </p>
                </div>

                <div class="site-card-grid" style="grid-template-columns: 1fr;">
                    <article class="site-card">
                        <div class="site-card__icon"><i class="fas fa-phone-volume"></i></div>
                        <h2 class="site-card__title">Nigeria</h2>
                        <p class="site-card__text">08134018568</p>
                    </article>
                    <article class="site-card">
                        <div class="site-card__icon"><i class="fas fa-earth-africa"></i></div>
                        <h2 class="site-card__title">South Africa</h2>
                        <p class="site-card__text">08134018568</p>
                    </article>
                    <article class="site-card">
                        <div class="site-card__icon"><i class="fas fa-envelope-open-text"></i></div>
                        <h2 class="site-card__title">Email</h2>
                        <p class="site-card__text">thormas66199@gmail.com</p>
                    </article>
                </div>
            </div>

            <div class="site-form-card">
                <span class="site-kicker"><i class="fas fa-paper-plane"></i> Contact form</span>
                <h3 style="margin-top: 1rem;">Let's talk.</h3>
                <p>Share a few details below and a team member can follow up with the right context.</p>

                <% if (success != null && !success.isBlank()) { %>
                    <div class="site-notice site-notice--success"><strong>Message recorded.</strong> <%= h(success) %></div>
                <% } %>
                <% if (error != null && !error.isBlank()) { %>
                    <div class="site-notice site-notice--error"><strong>We need one more step.</strong> <%= h(error) %></div>
                <% } %>

                <form class="auth-form" style="margin-top: 1.4rem;" action="<%= request.getContextPath() %>/contact" method="post">
                    <div class="auth-field">
                        <label for="department">Department</label>
                        <select id="department" name="department" class="auth-select">
                            <option value="Sales" <%= "Sales".equals(departmentValue) ? "selected" : "" %>>Sales</option>
                            <option value="Support" <%= "Support".equals(departmentValue) ? "selected" : "" %>>Support</option>
                            <option value="Partnerships" <%= "Partnerships".equals(departmentValue) ? "selected" : "" %>>Partnerships</option>
                        </select>
                    </div>
                    <div class="auth-form__grid">
                        <div class="auth-field">
                            <label for="organization">Organization</label>
                            <input id="organization" name="organization" class="auth-input" type="text" value="<%= h(organizationValue) %>" placeholder="Organization name">
                        </div>
                        <div class="auth-field">
                            <label for="name">Your name</label>
                            <input id="name" name="name" class="auth-input" type="text" value="<%= h(nameValue) %>" placeholder="Full name" required>
                        </div>
                    </div>
                    <div class="auth-field">
                        <label for="email">Email</label>
                        <input id="email" name="email" class="auth-input" type="email" value="<%= h(emailValue) %>" placeholder="Email address" required>
                    </div>
                    <div class="auth-field">
                        <label for="message">Message</label>
                        <textarea id="message" name="message" class="auth-input" rows="5" placeholder="How can we help?" style="resize: vertical;" required><%= h(messageValue) %></textarea>
                    </div>
                    <div class="auth-form__footer">
                        <div class="auth-links">
                            <span>Messages are saved to the admin operations inbox for follow-up.</span>
                        </div>

                        <button type="submit" class="site-button site-button--primary">Send message</button>
                    </div>
                </form>
            </div>
        </div>
    </section>
</main>


<%@ include file="/WEB-INF/views/fragment/public-footer.jspf" %>

</body>
</html>
