package com.bascode.admin;

import com.bascode.model.entity.User;
import com.bascode.model.enums.Role;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// Dev-only servlet to place a test user into session for manual testing of admin pages.
// Remove or secure before production.
public class DevLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String adminParam = req.getParameter("admin");
        boolean admin = "true".equalsIgnoreCase(adminParam);

        User u = new User();
        u.setId(0L);
        u.setFirstName("Dev");
        u.setLastName("User");
        u.setEmail(admin ? "admin@example.local" : "user@example.local");
        u.setRole(admin ? Role.ADMIN : Role.VOTER);

        HttpSession session = req.getSession(true);
        session.setAttribute("user", u);

        resp.setContentType("text/plain");
        resp.getWriter().println("Dev user placed in session: " + u.getEmail() + " role=" + u.getRole());
    }
}
