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

import java.io.IOException;

@WebServlet(name = "VerifyCodeServlet", urlPatterns = {"/verify-code"})
public class VerifyCodeServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String code = req.getParameter("code");
        if (code == null || code.trim().isEmpty()) {
            req.setAttribute("error", "Please provide a verification code.");
            req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
            return;
        }

        code = code.trim(); // Trim any invisible spaces

        EntityManager em = JPAUtil.getEntityManager();
        try {
            User user = em.createQuery("SELECT u FROM User u WHERE u.verificationCode = :code", User.class)
                    .setParameter("code", code)
                    .getSingleResult();

            em.getTransaction().begin();
            user.setEmailVerified(true);
            user.setVerificationCode(null);
            em.merge(user);
            em.getTransaction().commit();

            VerificationSupport.clearRememberedEmail(req);
            req.setAttribute("message", "Email verified. You can now login.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        } catch (NoResultException nre) {
            req.setAttribute("error", "Invalid or expired verification code.");
            req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            req.setAttribute("error", "An error occurred while verifying.");
            req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
        } finally {
            em.close();
        }
    }
}
