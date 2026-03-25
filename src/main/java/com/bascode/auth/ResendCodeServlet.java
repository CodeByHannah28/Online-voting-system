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

@WebServlet(name = "ResendCodeServlet", urlPatterns = {"/resend-code"})
public class ResendCodeServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = resolveEmail(req);
        if (email == null) {
            req.setAttribute("error", "Could not detect your email. Please try logging in again.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            User user = em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
                    .setParameter("email", email)
                    .getSingleResult();

            if (user.isEmailVerified()) {
                req.setAttribute("message", "This email is already verified. Please log in.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
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
                req.setAttribute("message", "A new verification code has been sent to your email.");
            } catch (MessagingException mex) {
                getServletContext().log("Failed to resend verification code to " + user.getEmail(), mex);
                req.setAttribute("error", VerificationSupport.deliveryErrorMessage(
                        "We generated a new verification code, but could not send the email right now. Please try again later.",
                        mex));
            }

            req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
        } catch (NoResultException ex) {
            req.setAttribute("error", "User not found.");
            req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            req.setAttribute("error", "An error occurred. Please try again.");
            req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
        } finally {
            if (em.isOpen()) {
                em.close();
            }
        }
    }

    private static String resolveEmail(HttpServletRequest req) {
        String email = trimToNull(req.getParameter("email"));
        if (email != null) {
            return email;
        }

        Object verificationEmail = req.getSession(false) != null
                ? req.getSession(false).getAttribute("verificationEmail")
                : null;
        return verificationEmail != null ? trimToNull(verificationEmail.toString()) : null;
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
