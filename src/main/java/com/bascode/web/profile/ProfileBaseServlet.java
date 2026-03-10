package com.bascode.web.profile;

import com.bascode.dao.UserDao;
import com.bascode.service.UserService;

import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public abstract class ProfileBaseServlet extends HttpServlet {

    protected UserService userService;

    @Override
    public void init() throws ServletException {
        EntityManagerFactory emf = (EntityManagerFactory) getServletContext().getAttribute("emf");
        if (emf == null) {
            throw new ServletException("EntityManagerFactory not initialized.");
        }
        this.userService = new UserService(new UserDao(emf));
    }

    protected Long getLoggedInUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return null;
        }

        Object userIdObj = session.getAttribute("userId");
        if (userIdObj == null) {
            return null;
        }

        if (userIdObj instanceof Number) {
            return ((Number) userIdObj).longValue();
        }

        try {
            return Long.parseLong(userIdObj.toString());
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
