<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Change Password | Go Voter</title>
    <style>
        body { font-family: "Segoe UI", Arial, sans-serif; margin: 0; background: #f5f7fb; color: #1f2937; }
        .wrap { max-width: 620px; margin: 40px auto; background: #fff; border-radius: 12px; padding: 28px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); }
        h1 { margin-top: 0; color: #1e40af; }
        .hint { color: #4b5563; font-size: 14px; margin-bottom: 14px; }
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
        <h1>Change Password</h1>
        <p class="hint">Use at least 8 characters for the new password.</p>

        <!-- Error message -->
        <c:if test="${not empty errorMessage}">
            <div class="err"><c:out value="${errorMessage}" /></div>
        </c:if>

        <!-- Change password form -->
        <form method="post" action="${pageContext.request.contextPath}/profile/change-password">
            <div>
                <label for="currentPassword">Current Password</label>
                <input id="currentPassword" name="currentPassword" type="password" required>
            </div>

            <div>
                <label for="newPassword">New Password</label>
                <!-- pattern ensures minimum 8 characters -->
                <input id="newPassword" name="newPassword" type="password" pattern=".{8,}" title="At least 8 characters" required>
            </div>

            <div>
                <label for="confirmPassword">Confirm New Password</label>
                <input id="confirmPassword" name="confirmPassword" type="password" pattern=".{8,}" title="At least 8 characters" required>
            </div>

            <div class="actions">
                <button class="btn btn-primary" type="submit">Change Password</button>
                <a class="btn btn-light" href="${pageContext.request.contextPath}/profile">Cancel</a>
            </div>
        </form>
    </div>
</body>
</html>