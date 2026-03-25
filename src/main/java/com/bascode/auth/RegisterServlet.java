package com.bascode.auth;

import com.bascode.model.entity.User;
import com.bascode.model.enums.Role;
import com.bascode.util.AgeEligibility;
import com.bascode.util.JPAUtil;
import jakarta.mail.MessagingException;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String firstName = trimToNull(req.getParameter("firstName"));
        String lastName = trimToNull(req.getParameter("lastName"));
        String email = trimToNull(req.getParameter("email"));
        String birthYearStr = trimToNull(req.getParameter("birthYear"));
        String state = trimToNull(req.getParameter("state"));
        String country = trimToNull(req.getParameter("country"));
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        Role role = AdminEmailSupport.resolveRole(email, Role.VOTER);

        if (firstName == null || lastName == null || email == null || birthYearStr == null ||
                state == null || country == null) {
            req.setAttribute("error", "All fields are required.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        if (password == null || confirmPassword == null || !password.equals(confirmPassword)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        if (password.length() < 6) {
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        int birthYear;
        try {
            birthYear = Integer.parseInt(birthYearStr);
            if (AgeEligibility.requiresAdultStatus(role) && !AgeEligibility.isAtLeast18(birthYear)) {
                req.setAttribute("error", AgeEligibility.registrationRefusalMessage(role));
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
                return;
            }
        } catch (NumberFormatException ex) {
            req.setAttribute("error", "Invalid birth year selected.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            long count = em.createQuery("SELECT COUNT(u) FROM User u WHERE u.email = :email", Long.class)
                    .setParameter("email", email)
                    .getSingleResult();
            if (count > 0) {
                req.setAttribute("error", "Email already registered.");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
                return;
            }

            String verificationCode = VerificationSupport.generateVerificationCode();

            User user = new User();
            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setEmail(email);
            user.setBirthYear(birthYear);
            user.setState(state);
            user.setCountry(country);
            user.setPasswordHash(AuthUtil.hashPassword(password));
            user.setRole(role);
            user.setEmailVerified(false);
            user.setVerificationCode(verificationCode);

            em.getTransaction().begin();
            em.persist(user);
            em.getTransaction().commit();

            VerificationSupport.rememberUnverifiedEmail(req, user.getEmail());
            try {
                VerificationSupport.sendVerificationEmail(getServletContext(), user, verificationCode);
                String message = "Registration successful. We sent a verification code to " + user.getEmail() + ".";
                if (Role.ADMIN.equals(role)) {
                    message += " This account has been assigned administrator access.";
                }
                req.setAttribute("message", message);
            } catch (MessagingException mex) {
                getServletContext().log("Registration email delivery failed for " + user.getEmail(), mex);
                req.setAttribute("error", VerificationSupport.deliveryErrorMessage(
                        "Registration succeeded, but we could not send your verification code. Please use the resend option.",
                        mex));
            }

            req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            getServletContext().log("Registration failed", ex);
            req.setAttribute("error", "An error occurred during registration. Please try again later.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
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
