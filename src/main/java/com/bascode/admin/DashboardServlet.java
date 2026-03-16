package com.bascode.admin;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.entity.Vote;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.TypedQuery;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Collections;
import java.util.List;

// Minimal dashboard servlet that collects basic counts and forwards to JSP
public class DashboardServlet extends HttpServlet {

    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        EntityManagerFactory factory = emf();
        if (factory == null) {
            req.setAttribute("votersCount", 0L);
            req.setAttribute("contestersCount", 0L);
            req.setAttribute("votesCount", 0L);
            req.getRequestDispatcher("/admin/dashboard.jsp").forward(req, resp);
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            Long votersCount = em.createQuery("SELECT COUNT(u) FROM User u WHERE u.role = com.bascode.model.enums.Role.VOTER", Long.class)
                    .getSingleResult();
            Long contestersCount = em.createQuery("SELECT COUNT(c) FROM Contester c", Long.class).getSingleResult();
            Long votesCount = em.createQuery("SELECT COUNT(v) FROM Vote v", Long.class).getSingleResult();
            Long pendingApprovals = em.createQuery("SELECT COUNT(c) FROM Contester c WHERE c.status = com.bascode.model.enums.ContesterStatus.PENDING", Long.class)
                    .getSingleResult();

            // Stats breakdown by position
            List<Object[]> positionStats = em.createQuery("SELECT c.position, COUNT(c) FROM Contester c WHERE c.status = com.bascode.model.enums.ContesterStatus.APPROVED GROUP BY c.position", Object[].class)
                    .getResultList();

            req.setAttribute("votersCount", votersCount);
            req.setAttribute("contestersCount", contestersCount);
            req.setAttribute("votesCount", votesCount);
            req.setAttribute("pendingApprovals", pendingApprovals);
            req.setAttribute("positionStats", positionStats);

            req.getRequestDispatcher("/admin/dashboard.jsp").forward(req, resp);

        } finally {
            em.close();
        }
    }
}