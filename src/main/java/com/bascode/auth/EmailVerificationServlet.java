package com.bascode.auth;

import com.bascode.model.entity.User;
import com.bascode.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "EmailVerificationServlet", urlPatterns = {"/verify"})
public class EmailVerificationServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String code = req.getParameter("code");

        if (code == null || code.trim().isEmpty()) {
            req.setAttribute("message", "Invalid verification link.");
            req.getRequestDispatcher("/auth.jsp").forward(req, resp);
            return;
        }

EntityManager em = JPAUtil.getEntityManager();
        try {
            User user = em.createQuery("SELECT u FROM User u WHERE u.verificationCode = :code", User.class)
                    .setParameter("code", code)
                    .getSingleResult();

            em.getTransaction().begin();
            user.setEmailVerified(true);
            user.setVerificationCode(null); // Clear code
            em.merge(user);
            em.getTransaction().commit();

            VerificationSupport.clearRememberedEmail(req);
            req.setAttribute("message", "Email verified successfully! You can now login.");
            req.getRequestDispatcher("/verify.jsp").forward(req, resp);

        } catch (Exception e) {
            req.setAttribute("error", "Invalid or expired verification code.");
            req.getRequestDispatcher("/verify.jsp").forward(req, resp);
        } finally {
            em.close();
        }
    }
}

