package com.bascode.admin;

import com.bascode.model.entity.Contester;


import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.TypedQuery;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class VoterStatsServlet extends HttpServlet {

    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        EntityManagerFactory factory = emf();
        if (factory == null) {
            forwardResultsPage(req, resp, Collections.emptyList(), Collections.emptyMap(),
                    Collections.emptyList(), 0L,
                    "We couldn't load voting analytics right now. Please try again shortly.");
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            // Fetch approved contesters only (for results)
            TypedQuery<Contester> cQ = em.createQuery("SELECT c FROM Contester c WHERE c.status = com.bascode.model.enums.ContesterStatus.APPROVED ORDER BY c.position", Contester.class);
            List<Contester> contesters = cQ.getResultList();

            // Position totals
            List<Object[]> positionTotals = em.createQuery("SELECT v.position, COUNT(v) FROM Vote v GROUP BY v.position ORDER BY COUNT(v) DESC", Object[].class).getResultList();

            Map<Long, Long> counts = new HashMap<>();
            TypedQuery<Object[]> vQ = em.createQuery("SELECT v.contester.id, COUNT(v) FROM Vote v GROUP BY v.contester.id", Object[].class);
            List<Object[]> rows = vQ.getResultList();
            for (Object[] r : rows) {
                Long contesterId = (Long) r[0];
                Long count = (Long) r[1];
                counts.put(contesterId, count);
            }

            Long totalVotes = em.createQuery("SELECT COUNT(v) FROM Vote v", Long.class).getSingleResult();

            forwardResultsPage(req, resp, contesters, counts, positionTotals, totalVotes, null);
        } catch (RuntimeException ex) {
            getServletContext().log("[VoterStatsServlet] Unable to load voting analytics.", ex);
            forwardResultsPage(req, resp, Collections.emptyList(), Collections.emptyMap(),
                    Collections.emptyList(), 0L,
                    "We couldn't load voting analytics right now. Please refresh or try again shortly.");
        } finally {
            em.close();
        }
    }

    private void forwardResultsPage(HttpServletRequest req, HttpServletResponse resp, List<Contester> contesters,
                                    Map<Long, Long> voteCounts, List<Object[]> positionTotals, Long totalVotes,
                                    String pageError) throws ServletException, IOException {
        req.setAttribute("contesters", contesters != null ? contesters : Collections.emptyList());
        req.setAttribute("voteCounts", voteCounts != null ? voteCounts : Collections.emptyMap());
        req.setAttribute("positionTotals", positionTotals != null ? positionTotals : Collections.emptyList());
        req.setAttribute("totalVotes", totalVotes != null ? totalVotes : 0L);
        req.setAttribute("pageError", pageError);
        req.getRequestDispatcher("/admin/voter-stats.jsp").forward(req, resp);
    }
}
