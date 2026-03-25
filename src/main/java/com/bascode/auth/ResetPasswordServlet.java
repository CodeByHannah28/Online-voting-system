package com.bascode.auth;

import com.bascode.model.entity.User;
import com.bascode.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.time.Instant;

@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/reset-password"})
public class ResetPasswordServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // forward to JSP which reads token query param (kept for compatibility)
        req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String code = req.getParameter("code");
        String password = req.getParameter("password");
        String confirm = req.getParameter("confirmPassword");

        if (code == null || code.trim().isEmpty()) {
            req.setAttribute("error", "Invalid or missing verification code.");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
            return;
        }

        if (password == null || confirm == null || !password.equals(confirm) || password.length() < 6) {
            req.setAttribute("error", "Passwords must match and be at least 6 characters.");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            User user = em.createQuery("SELECT u FROM User u WHERE u.passwordResetToken = :token", User.class)
                    .setParameter("token", code)
                    .getSingleResult();

            long expiry = user.getResetTokenExpiry() != null ? user.getResetTokenExpiry() : 0L;
            if (expiry < Instant.now().toEpochMilli()) {
                req.setAttribute("error", "Verification code has expired.");
                req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
                return;
            }

            em.getTransaction().begin();
            user.setPasswordHash(BCrypt.hashpw(password, BCrypt.gensalt()));
            user.setPasswordResetToken(null);
            user.setResetTokenExpiry(null);
            em.merge(user);
            em.getTransaction().commit();

            req.setAttribute("message", "Password reset successful. You can now login.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);

        } catch (NoResultException nre) {
            req.setAttribute("error", "Invalid verification code.");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            req.setAttribute("error", "An error occurred. Please try again.");
            req.getRequestDispatcher("/reset-password.jsp").forward(req, resp);
        } finally {
            em.close();
        }
    }
}