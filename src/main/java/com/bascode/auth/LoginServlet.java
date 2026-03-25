package com.bascode.auth;

import com.bascode.model.entity.User;
import com.bascode.model.enums.Role;
import com.bascode.util.AgeEligibility;
import com.bascode.util.JPAUtil;
import jakarta.mail.MessagingException;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = trimToNull(req.getParameter("email"));
        String password = req.getParameter("password");

        if (email == null || password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            User user = em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
                    .setParameter("email", email)
                    .getSingleResult();

            if (AdminEmailSupport.shouldPromoteToAdmin(user)) {
                try {
                    em.getTransaction().begin();
                    user.setRole(Role.ADMIN);
                    user = em.merge(user);
                    em.getTransaction().commit();
                } catch (RuntimeException ex) {
                    if (em.getTransaction().isActive()) {
                        em.getTransaction().rollback();
                    }
                    throw ex;
                }
            }

            if (!AuthUtil.checkPassword(password, user.getPasswordHash())) {
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
                return;
            }

            if (AgeEligibility.requiresAdultStatus(user.getRole()) &&
                    !AgeEligibility.isAtLeast18(user.getBirthYear())) {
                clearAuthenticatedSession(req);
                req.setAttribute("error", AgeEligibility.loginRefusalMessage(user.getRole()));
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
                return;
            }

            if (!user.isEmailVerified()) {
                handleUnverifiedLogin(req, resp, em, user);
                return;
            }

            HttpSession session = req.getSession(true);
            VerificationSupport.clearRememberedEmail(req);
            session.setAttribute("userId", user.getId());
            session.setAttribute("user", user);
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("userName", user.getFirstName() + " " + user.getLastName());
            session.setAttribute("userRole", user.getRole() != null ? user.getRole().name() : null);

            String redirect = trimToNull(req.getParameter("redirect"));
            if (redirect != null && redirect.startsWith(req.getContextPath() + "/")) {
                resp.sendRedirect(redirect);
                return;
            }

            if (Role.ADMIN.equals(user.getRole())) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            } else {
                resp.sendRedirect(req.getContextPath() + "/voterDashboard.jsp");
            }
        } catch (NoResultException ex) {
            req.setAttribute("error", "Invalid email or password.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        } finally {
            em.close();
        }
    }

    private void handleUnverifiedLogin(HttpServletRequest req, HttpServletResponse resp, EntityManager em, User user)
            throws ServletException, IOException {
        clearAuthenticatedSession(req);
        VerificationSupport.rememberUnverifiedEmail(req, user.getEmail());

        String verificationCode = VerificationSupport.generateVerificationCode();
        try {
            em.getTransaction().begin();
            user.setVerificationCode(verificationCode);
            em.merge(user);
            em.getTransaction().commit();

            try {
                VerificationSupport.sendVerificationEmail(getServletContext(), user, verificationCode);
                req.setAttribute("message",
                        "Your account is not verified yet. We sent a fresh verification code to " + user.getEmail() + ".");
            } catch (MessagingException mex) {
                getServletContext().log("Failed to send fresh verification code to " + user.getEmail(), mex);
                req.setAttribute("error", VerificationSupport.deliveryErrorMessage(
                        "Your account is not verified yet, and we could not send a fresh verification code. Please use the resend option.",
                        mex));
            }
        } catch (RuntimeException ex) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            throw ex;
        }

        req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
    }

    private static void clearAuthenticatedSession(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return;
        }

        session.removeAttribute("userId");
        session.removeAttribute("user");
        session.removeAttribute("userEmail");
        session.removeAttribute("userName");
        session.removeAttribute("userRole");
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
