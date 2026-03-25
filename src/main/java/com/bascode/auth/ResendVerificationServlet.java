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

@WebServlet(name = "ResendVerificationServlet", urlPatterns = {"/resend-verification"})
public class ResendVerificationServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = trimToNull(req.getParameter("email"));
        if (email == null) {
            req.setAttribute("error", "Please provide your email address.");
            req.getRequestDispatcher("/resend-verification.jsp").forward(req, resp);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            User user = em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
                    .setParameter("email", email)
                    .getSingleResult();

            if (user.isEmailVerified()) {
                req.setAttribute("message", "If an account with that email exists, it is already verified and ready to sign in.");
                req.getRequestDispatcher("/resend-verification.jsp").forward(req, resp);
                return;
            }

            String verificationCode = VerificationSupport.generateVerificationCode();
            em.getTransaction().begin();
            user.setVerificationCode(verificationCode);
            em.merge(user);
            em.getTransaction().commit();

            VerificationSupport.rememberUnverifiedEmail(req, user.getEmail());
            try {
                VerificationSupport.sendVerificationEmail(getServletContext(), user, verificationCode);
                req.setAttribute("message",
                        "If an account with that email exists, a verification email has been sent.");
            } catch (MessagingException mex) {
                getServletContext().log("Failed to resend verification email to " + user.getEmail(), mex);
                req.setAttribute("error", VerificationSupport.deliveryErrorMessage(
                        "We found the account, but could not send the verification email right now. Please try again later.",
                        mex));
            }

            req.getRequestDispatcher("/resend-verification.jsp").forward(req, resp);
        } catch (NoResultException ex) {
            req.setAttribute("message",
                    "If an account with that email exists, a verification email has been sent.");
            req.getRequestDispatcher("/resend-verification.jsp").forward(req, resp);
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            getServletContext().log("Resend verification failed", ex);
            req.setAttribute("error", "An error occurred. Please try again later.");
            req.getRequestDispatcher("/resend-verification.jsp").forward(req, resp);
        } finally {
            if (em.isOpen()) {
                em.close();
            }
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
