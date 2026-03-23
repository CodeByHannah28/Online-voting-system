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
import org.mindrot.jbcrypt.BCrypt;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.Random;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String firstName = req.getParameter("firstName");
        String lastName = req.getParameter("lastName");
        String email = req.getParameter("email");
        String birthYearStr = req.getParameter("birthYear");
        String state = req.getParameter("state");
        String country = req.getParameter("country");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String roleParam = req.getParameter("role");

        // Validation
        if (firstName == null || lastName == null || email == null || birthYearStr == null || state == null || country == null
                || firstName.trim().isEmpty() || lastName.trim().isEmpty() || email.trim().isEmpty()
                || birthYearStr.trim().isEmpty() || state.trim().isEmpty() || country.trim().isEmpty()) {
            req.setAttribute("error", "All fields are required.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirmPassword)) {
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
        } catch (NumberFormatException nfe) {
            req.setAttribute("error", "Invalid birth year selected.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        // Map role parameter to enum; default to VOTER if not provided or unrecognized
        Role role = Role.VOTER;
        if (roleParam != null && !roleParam.trim().isEmpty()) {
            String rp = roleParam.trim().toUpperCase();
            if (rp.equals("CONTESTER") || rp.equals("CONTESTANT")) {
                role = Role.CONTESTER;
            } else if (rp.equals("ADMIN")) {
                role = Role.ADMIN;
            } else {
                role = Role.VOTER;
            }
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            // Check if email exists
            long count = em.createQuery("SELECT COUNT(u) FROM User u WHERE u.email = :email", Long.class)
                    .setParameter("email", email)
                    .getSingleResult();

            if (count > 0) {
                req.setAttribute("error", "Email already registered.");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
                return;
            }

            // Create user
            User user = new User();
            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setEmail(email);
            user.setBirthYear(birthYear);
            user.setState(state);
            user.setCountry(country);
            user.setPasswordHash(BCrypt.hashpw(password, BCrypt.gensalt()));
            user.setRole(role);
            user.setEmailVerified(true);

            em.getTransaction().begin();
            em.persist(user);
            em.getTransaction().commit();

            // Redirect immediately to login with success message
            req.setAttribute("message", "Registration successful! You can now log in.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);

        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            getServletContext().log("Registration failed", e);
            req.setAttribute("error", "An error occurred during registration. Please try again later.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }
}