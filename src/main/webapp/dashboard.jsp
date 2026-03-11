<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.bascode.model.entity.User" %>
<%@ page import="com.bascode.model.enums.Role" %>
<%
    Object userObj = session.getAttribute("user");
    Role role = null;

    if (userObj instanceof User) {
        role = ((User) userObj).getRole();
    }

    if (role == null) {
        Object roleObj = session.getAttribute("role");
        if (roleObj instanceof Role) {
            role = (Role) roleObj;
        } else if (roleObj != null) {
            try {
                role = Role.valueOf(roleObj.toString());
            } catch (IllegalArgumentException ignored) {
                role = null;
            }
        }
    }

    if (role == Role.ADMIN) {
        response.sendRedirect("adminDashboard.jsp");
        return;
    }

    if (role == Role.VOTER) {
        response.sendRedirect("voterDashboard.jsp");
        return;
    }

    if (role != null) {
        response.sendError(403);
        return;
    }

    response.sendRedirect("auth.jsp?mode=login");
%>
