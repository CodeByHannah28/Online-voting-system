<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Profile | Go Voter</title>
    <style>
        body { font-family: "Segoe UI", Arial, sans-serif; margin: 0; background: #f5f7fb; color: #1f2937; }
        .wrap { max-width: 700px; margin: 40px auto; background: #fff; border-radius: 12px; padding: 28px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); }
        h1 { margin-top: 0; color: #1e40af; }
        .err { padding: 10px 14px; border-radius: 8px; margin-bottom: 18px; background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
        form { display: grid; gap: 14px; }
        label { font-weight: 600; color: #374151; display: block; margin-bottom: 6px; }
        input { width: 100%; box-sizing: border-box; border-radius: 8px; border: 1px solid #d1d5db; padding: 10px 12px; font-size: 14px; }
        .actions { margin-top: 10px; display: flex; gap: 12px; flex-wrap: wrap; }
        .btn { text-decoration: none; border: none; border-radius: 8px; padding: 10px 16px; cursor: pointer; display: inline-block; font-weight: 600; text-align: center; }
        .btn-primary { background: #2563eb; color: #fff; }
        .btn-light { background: #e5e7eb; color: #111827; }
    </style>
</head>
<body>
    <div class="wrap">
        <h1>Edit Profile</h1>

        <!-- Error message -->
        <c:if test="${not empty errorMessage}">
            <div class="err"><c:out value="${errorMessage}" /></div>
        </c:if>

        <!-- Edit profile form -->
        <c:if test="${not empty user}">
            <form method="post" action="${pageContext.request.contextPath}/profile/update">
                <div>
                    <label for="firstName">First Name</label>
                    <input id="firstName" name="firstName" type="text" value="${user.firstName}" required>
                </div>

                <div>
                    <label for="lastName">Last Name</label>
                    <input id="lastName" name="lastName" type="text" value="${user.lastName}" required>
                </div>

                <div>
                    <label for="email">Email</label>
                    <input id="email" name="email" type="email" value="${user.email}" required>
                </div>

                <div>
                    <label for="birthYear">Birth Year</label>
                    <c:choose>
                        <c:when test="${not empty birthYearInput}">
                            <input id="birthYear" name="birthYear" type="number" min="1900" max="2100" value="${birthYearInput}">
                        </c:when>
                        <c:otherwise>
                            <input id="birthYear" name="birthYear" type="number" min="1900" max="2100" value="${user.birthYear}">
                        </c:otherwise>
                    </c:choose>
                </div>

                <div>
                    <label for="state">State</label>
                    <input id="state" name="state" type="text" value="${user.state}">
                </div>

                <div>
                    <label for="country">Country</label>
                    <input id="country" name="country" type="text" value="${user.country}">
                </div>

                <div class="actions">
                    <button class="btn btn-primary" type="submit">Save Changes</button>
                    <a class="btn btn-light" href="${pageContext.request.contextPath}/profile">Cancel</a>
                </div>
            </form>
        </c:if>

        <c:if test="${empty user}">
            <p>User information is not available. Please log in.</p>
        </c:if>
    </div>
</body>
</html>