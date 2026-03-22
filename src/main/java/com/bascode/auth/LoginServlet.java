package com.bascode.auth;

import com.bascode.model.entity.User;
import com.bascode.model.enums.Role;
import com.bascode.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            User user = em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
                    .setParameter("email", email)
                    .getSingleResult();
            
            if (!user.isEmailVerified()) {
                req.setAttribute("error", "Please verify your email first.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
                return;
            }

            if (BCrypt.checkpw(password, user.getPasswordHash())) {
                HttpSession session = req.getSession();
                session.setAttribute("userId", user.getId());
                session.setAttribute("userRole", user.getRole().name());
                session.setAttribute("userEmail", user.getEmail());
                session.setAttribute("userName", user.getFirstName() + " " + user.getLastName());

                // Respect redirect param from AuthFilter
                String redirect = req.getParameter("redirect");
                if (redirect != null && !redirect.trim().isEmpty()) {
                    resp.sendRedirect(redirect);
                } else {
                    resp.sendRedirect("index.jsp");
                }
            } else {
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
            }
        } catch (NoResultException e) {
            req.setAttribute("error", "Invalid email or password.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        } finally {
            em.close();
        }
    }
}