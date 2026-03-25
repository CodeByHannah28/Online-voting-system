package com.bascode.admin;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;

import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

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
            forwardDashboardPage(req, resp, 0L, 0L, 0L, 0L, java.util.Collections.emptyList(),
                    "We couldn't load the latest dashboard numbers right now. Please try again shortly.");
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            Long votersCount = em.createQuery(
                            "SELECT COUNT(u) FROM User u " +
                            "WHERE u.role = com.bascode.model.enums.Role.VOTER " +
                            "OR u.role = com.bascode.model.enums.Role.CONTESTER",
                            Long.class)
                    .getSingleResult();
            Long contestersCount = em.createQuery("SELECT COUNT(c) FROM Contester c", Long.class).getSingleResult();
            Long votesCount = em.createQuery("SELECT COUNT(DISTINCT v.voter.id) FROM Vote v", Long.class).getSingleResult();
            Long pendingApprovals = em.createQuery("SELECT COUNT(c) FROM Contester c WHERE c.status = com.bascode.model.enums.ContesterStatus.PENDING", Long.class)
                    .getSingleResult();

            // Stats breakdown by position
            List<Object[]> positionStats = em.createQuery("SELECT c.position, COUNT(c) FROM Contester c WHERE c.status = com.bascode.model.enums.ContesterStatus.APPROVED GROUP BY c.position", Object[].class)
                    .getResultList();

            forwardDashboardPage(req, resp, votersCount, contestersCount, votesCount, pendingApprovals,
                    positionStats, null);
        } catch (RuntimeException ex) {
            getServletContext().log("[DashboardServlet] Unable to load dashboard metrics.", ex);
            forwardDashboardPage(req, resp, 0L, 0L, 0L, 0L, java.util.Collections.emptyList(),
                    "We couldn't load the latest dashboard numbers right now. Please refresh or try again shortly.");

        } finally {
            em.close();
        }

    }

    private void forwardDashboardPage(HttpServletRequest req, HttpServletResponse resp, Long votersCount,
                                      Long contestersCount, Long votesCount, Long pendingApprovals,
                                      List<Object[]> positionStats, String pageError)
            throws ServletException, IOException {
        req.setAttribute("votersCount", votersCount != null ? votersCount : 0L);
        req.setAttribute("contestersCount", contestersCount != null ? contestersCount : 0L);
        req.setAttribute("votesCount", votesCount != null ? votesCount : 0L);
        req.setAttribute("pendingApprovals", pendingApprovals != null ? pendingApprovals : 0L);
        req.setAttribute("positionStats", positionStats != null ? positionStats : java.util.Collections.emptyList());
        req.setAttribute("pageError", pageError);
        req.getRequestDispatcher("/admin/dashboard.jsp").forward(req, resp);
    }
}
