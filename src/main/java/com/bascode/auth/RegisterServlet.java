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

import java.io.IOException;
import java.util.UUID;

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

        } catch (NoResultException ignored) {
            // Email available, proceed
        }

        // Create user
        User user = new User();
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setBirthYear(Integer.parseInt(birthYearStr));
        user.setState(state);
        user.setCountry(country);
        user.setPasswordHash(BCrypt.hashpw(password, BCrypt.gensalt()));
        user.setRole(Role.VOTER);
        user.setEmailVerified(false);
        user.setVerificationCode(UUID.randomUUID().toString());

        em.getTransaction().begin();
        em.persist(user);
        em.getTransaction().commit();

        // For dev: Show code in redirect
        resp.sendRedirect("verify.jsp?code=" + user.getVerificationCode());
    }
}