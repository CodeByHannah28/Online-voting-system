package com.bascode.web.profile;

import java.io.IOException;

import com.bascode.model.entity.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/profile")
public class ViewProfileServlet extends ProfileBaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long userId = getLoggedInUserId(req);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth.jsp");
            return;
        }

        User user = userService.getUserById(userId);
        if (user == null) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            resp.sendRedirect(req.getContextPath() + "/auth.jsp");
            return;
        }

        HttpSession session = req.getSession(false);
        if (session != null) {
            Object flashMessage = session.getAttribute("flashMessage");
            if (flashMessage != null) {
                req.setAttribute("flashMessage", flashMessage);
                session.removeAttribute("flashMessage");
            }
        }

        req.setAttribute("user", user);
        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }
}
