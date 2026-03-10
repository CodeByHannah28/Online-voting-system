package com.bascode.web.profile;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/profile/change-password")
public class ChangePasswordServlet extends ProfileBaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long userId = getLoggedInUserId(req);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth.jsp");
            return;
        }
        req.getRequestDispatcher("/changePassword.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long userId = getLoggedInUserId(req);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth.jsp");
            return;
        }

        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        String error = userService.changePassword(userId, currentPassword, newPassword, confirmPassword);
        if (error != null) {
            req.setAttribute("errorMessage", error);
            req.getRequestDispatcher("/changePassword.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession();
        session.setAttribute("flashMessage", "Password changed successfully.");
        resp.sendRedirect(req.getContextPath() + "/profile");
    }
}
