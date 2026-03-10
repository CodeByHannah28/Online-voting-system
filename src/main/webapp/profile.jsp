<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile | Go Voter</title>
    <style>
        body { font-family: "Segoe UI", Arial, sans-serif; margin: 0; background: #f5f7fb; color: #1f2937; }
        .wrap { max-width: 800px; margin: 40px auto; background: #fff; border-radius: 12px; padding: 28px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); }
        h1 { margin-top: 0; color: #1e40af; }
        .msg { padding: 10px 14px; border-radius: 8px; margin-bottom: 18px; background: #ecfeff; color: #155e75; border: 1px solid #67e8f9; }
        .grid { display: grid; grid-template-columns: 170px 1fr; gap: 10px 20px; }
        .label { font-weight: 600; color: #4b5563; }
        .value { color: #111827; }
        .actions { margin-top: 26px; display: flex; gap: 12px; flex-wrap: wrap; }
        .btn { text-decoration: none; border: none; border-radius: 8px; padding: 10px 16px; cursor: pointer; display: inline-block; font-weight: 600; text-align: center; }
        .btn-primary { background: #2563eb; color: #fff; }
        .btn-secondary { background: #111827; color: #fff; }
        .btn-light { background: #e5e7eb; color: #111827; }
    </style>
</head>
<body>
    <div class="wrap">
        <h1>My Profile</h1>

        <!-- Flash message (safely escaped) -->
        <c:if test="${not empty flashMessage}">
            <div class="msg"><c:out value="${flashMessage}" /></div>
        </c:if>

        <!-- User profile details -->
        <c:if test="${not empty user}">
            <div class="grid">
                <div class="label">First Name</div><div class="value"><c:out value="${user.firstName}" /></div>
                <div class="label">Last Name</div><div class="value"><c:out value="${user.lastName}" /></div>
                <div class="label">Email</div><div class="value"><c:out value="${user.email}" /></div>
                <div class="label">Birth Year</div><div class="value"><c:out value="${user.birthYear}" /></div>
                <div class="label">State</div><div class="value"><c:out value="${user.state}" /></div>
                <div class="label">Country</div><div class="value"><c:out value="${user.country}" /></div>
                <div class="label">Role</div><div class="value"><c:out value="${user.role}" /></div>
            </div>

            <div class="actions">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/profile/update">Edit Profile</a>
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/profile/change-password">Change Password</a>
                <a class="btn btn-light" href="${pageContext.request.contextPath}/index.jsp">Back Home</a>
            </div>
        </c:if>

        <c:if test="${empty user}">
            <p>User information is not available. Please log in.</p>
        </c:if>
    </div>
</body>
</html>