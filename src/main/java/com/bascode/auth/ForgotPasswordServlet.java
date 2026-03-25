package com.bascode.auth;

import com.bascode.model.entity.User;
import com.bascode.util.JPAUtil;
import jakarta.mail.MessagingException;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.Instant;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {
    private static final long TOKEN_TTL_MS = 1000L * 60 * 60; // 1 hour

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = trimToNull(req.getParameter("email"));
        if (email == null) {
            req.setAttribute("error", "Please provide your email address.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            User user = em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
                    .setParameter("email", email)
                    .getSingleResult();

            em.getTransaction().begin();
            String token = VerificationSupport.generateVerificationCode();
            user.setPasswordResetToken(token);
            user.setResetTokenExpiry(Instant.now().toEpochMilli() + TOKEN_TTL_MS);
            em.merge(user);
            em.getTransaction().commit();

            try {
                VerificationSupport.sendPasswordResetEmail(getServletContext(), user, token);
                req.setAttribute("message", "If an account with that email exists, a reset code has been sent.");
            } catch (MessagingException mex) {
                getServletContext().log("Failed to send password reset code to " + user.getEmail(), mex);
                req.setAttribute("error", VerificationSupport.deliveryErrorMessage(
                        "We found the account, but could not send the reset code right now. Please try again later.",
                        mex));
            }

            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
        } catch (NoResultException nre) {
            req.setAttribute("message", "If an account with that email exists, a reset code has been sent.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            req.setAttribute("error", "An error occurred. Please try again.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
        } finally {
            em.close();
        }
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
