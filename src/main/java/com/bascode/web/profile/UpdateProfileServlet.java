package com.bascode.web.profile;

import java.io.IOException;

import com.bascode.model.entity.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/profile/update")
public class UpdateProfileServlet extends ProfileBaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long userId = getLoggedInUserId(req);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth.jsp");
            return;
        }

        User user = userService.getUserById(userId);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth.jsp");
            return;
        }

        req.setAttribute("user", user);
        req.getRequestDispatcher("/editProfile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long userId = getLoggedInUserId(req);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth.jsp");
            return;
        }

        String firstName = req.getParameter("firstName");
        String lastName = req.getParameter("lastName");
        String email = req.getParameter("email");
        String birthYear = req.getParameter("birthYear");
        String state = req.getParameter("state");
        String country = req.getParameter("country");

        String error = userService.updateProfile(userId, firstName, lastName, email, birthYear, state, country);
        if (error != null) {
            User user = userService.getUserById(userId);
            if (user != null) {
                user.setFirstName(firstName);
                user.setLastName(lastName);
                user.setEmail(email);
                user.setState(state);
                user.setCountry(country);
            }
            req.setAttribute("errorMessage", error);
            req.setAttribute("user", user);
            req.setAttribute("birthYearInput", birthYear);
            req.getRequestDispatcher("/editProfile.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession();
        session.setAttribute("flashMessage", "Profile updated successfully.");
        resp.sendRedirect(req.getContextPath() + "/profile");
    }
}
