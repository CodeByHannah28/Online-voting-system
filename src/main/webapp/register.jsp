<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String pageTitle = "Register";
    String authViewName = "register";
    String error = (String) request.getAttribute("error");
    String firstName = request.getParameter("firstName") != null ? request.getParameter("firstName") : "";
    String lastName = request.getParameter("lastName") != null ? request.getParameter("lastName") : "";
    String email = request.getParameter("email") != null ? request.getParameter("email") : "";
    String birthYearValue = request.getParameter("birthYear") != null ? request.getParameter("birthYear") : "";
    String stateValue = request.getParameter("state") != null ? request.getParameter("state") : "";
    String countryValue = request.getParameter("country") != null ? request.getParameter("country") : "Nigeria";
    String[] states = {
        "Abia", "Adamawa", "Akwa Ibom", "Anambra", "Bauchi", "Bayelsa", "Benue", "Borno",
        "Cross River", "Delta", "Ebonyi", "Edo", "Ekiti", "Enugu", "Gombe", "Imo", "Jigawa",
        "Kaduna", "Kano", "Katsina", "Kebbi", "Kogi", "Kwara", "Lagos", "Nasarawa", "Niger",
        "Ogun", "Ondo", "Osun", "Oyo", "Plateau", "Rivers", "Sokoto", "Taraba", "Yobe", "Zamfara"
    };
    String[] countries = {
        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina",
        "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh",
        "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia",
        "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso",
        "Burundi", "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic",
        "Chad", "Chile", "China", "Colombia", "Comoros", "Congo", "Costa Rica", "Croatia",
        "Cuba", "Cyprus", "Czechia", "Democratic Republic of the Congo", "Denmark", "Djibouti",
        "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea",
        "Eritrea", "Estonia", "Eswatini", "Ethiopia", "Fiji", "Finland", "France", "Gabon",
        "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea",
        "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Hungary", "Iceland", "India", "Indonesia",
        "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan",
        "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho",
        "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Madagascar", "Malawi",
        "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius",
        "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco",
        "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand",
        "Nicaragua", "Niger", "Nigeria", "North Korea", "North Macedonia", "Norway", "Oman",
        "Pakistan", "Palau", "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru",
        "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda",
        "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa",
        "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles",
        "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia",
        "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname",
        "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand",
        "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey",
        "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom",
        "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Vatican City", "Venezuela",
        "Vietnam", "Yemen", "Zambia", "Zimbabwe"
    };
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/fragment/site-head.jspf" %>
</head>
<body class="auth-body">
<%@ include file="/WEB-INF/views/fragment/auth-header.jspf" %>

<main class="auth-shell">
    <div class="auth-stage">
        <section class="auth-aside" style="background-image: url('${pageContext.request.contextPath}/Home-background.jpeg');">
            <div class="auth-aside__content">
                <div>
                    <div class="auth-aside__eyebrow"><i class="fas fa-user-plus"></i> Join the platform</div>
                    <h1 class="auth-aside__title">Create a voter-ready account.</h1>
                    <p class="auth-aside__text">
                        Register once, keep your details verified, and move smoothly into secure voting, candidate review, and election updates.
                    </p>
                </div>
                <div class="auth-points">
                    <div class="auth-point">
                        <i class="fas fa-id-card"></i>
                        <div>
                            <strong>Profile details in one pass</strong>
                            <span>Set up your identity and location in a single, guided registration flow.</span>
                        </div>
                    </div>
                    <div class="auth-point">
                        <i class="fas fa-check-double"></i>
                        <div>
                            <strong>Built for real participation</strong>
                            <span>Register as a voter first, then apply to contest a position after sign-in.</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="auth-card">
            <div class="auth-card__eyebrow"><i class="fas fa-address-card"></i> Registration</div>
            <h2 class="auth-card__title">Create your account.</h2>
            <p class="auth-card__text">
                Fill in your details below to get started with Go Voter.
            </p>

            <% if (error != null) { %>
                <div class="auth-alert auth-alert--error"><%= error %></div>
            <% } %>

            <form method="post" action="register" class="auth-form">
                <div class="auth-form__grid">
                    <div class="auth-field">
                        <label for="firstName">First name</label>
                        <input id="firstName" class="auth-input" type="text" name="firstName" value="<%= firstName %>" required>
                    </div>
                    <div class="auth-field">
                        <label for="lastName">Last name</label>
                        <input id="lastName" class="auth-input" type="text" name="lastName" value="<%= lastName %>" required>
                    </div>
                </div>

                <div class="auth-field">
                    <label for="email">Email address</label>
                    <input id="email" class="auth-input" type="email" name="email" value="<%= email %>" placeholder="you@example.com" required>
                </div>

                <div class="auth-form__grid">
                    <div class="auth-field">
                        <label for="birthYear">Birth year</label>
                        <select id="birthYear" class="auth-select" name="birthYear" required>
                            <option value="">Select year</option>
                            <%
                                int currentYear = java.time.Year.now().getValue();
                                for (int year = currentYear; year >= 1880; year--) {
                            %>
                                <option value="<%= year %>" <%= String.valueOf(year).equals(birthYearValue) ? "selected" : "" %>><%= year %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="auth-field">
                        <label for="state">State / Province / Region</label>
                        <input id="state" class="auth-input" type="text" name="state" value="<%= stateValue %>" list="stateSuggestions" placeholder="e.g. Lagos, Ontario, California" required>
                        <datalist id="stateSuggestions">
                            <% for (String state : states) { %>
                                <option value="<%= state %>">
                            <% } %>
                        </datalist>
                    </div>
                </div>

                <div class="auth-field">
                    <label for="country">Country</label>
                    <select id="country" class="auth-select" name="country" required>
                        <option value="">Select country</option>
                        <% for (String country : countries) { %>
                            <option value="<%= country %>" <%= country.equals(countryValue) ? "selected" : "" %>><%= country %></option>
                        <% } %>
                    </select>
                </div>

                <div class="auth-form__grid">
                    <div class="auth-field">
                        <label for="password">Password</label>
                        <input id="password" class="auth-input" type="password" name="password" placeholder="Minimum 6 characters" required>
                    </div>
                    <div class="auth-field">
                        <label for="confirmPassword">Confirm password</label>
                        <input id="confirmPassword" class="auth-input" type="password" name="confirmPassword" placeholder="Repeat your password" required>
                    </div>
                </div>

                <div class="auth-form__footer">
                    <div class="auth-links">
                        <span>Voters must be at least 18 years old to register.</span>
                        <span>Contesters start as voter accounts and choose their position after verification and sign-in.</span>
                        <span>Configured administrator emails are assigned admin access automatically after verification.</span>
                    </div>
                    <button type="submit" class="site-button site-button--accent">Create account</button>
                </div>
            </form>

            <div class="auth-note">
                Already have an account? <a href="login.jsp">Sign in instead</a>.
            </div>
        </section>
    </div>
</main>

</body>
</html>
