package com.bascode.admin;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.Vote;

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
            req.setAttribute("contesters", Collections.emptyList());
            req.setAttribute("voteCounts", Collections.emptyMap());
            req.getRequestDispatcher("/admin/voter-stats.jsp").forward(req, resp);
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            // Fetch contesters and compute vote counts per contester
            TypedQuery<Contester> cQ = em.createQuery("SELECT c FROM Contester c", Contester.class);
            List<Contester> contesters = cQ.getResultList();

            Map<Long, Long> counts = new HashMap<>();
            TypedQuery<Object[]> vQ = em.createQuery("SELECT v.contester.id, COUNT(v) FROM Vote v GROUP BY v.contester.id", Object[].class);
            List<Object[]> rows = vQ.getResultList();
            for (Object[] r : rows) {
                Long contesterId = (Long) r[0];
                Long count = (Long) r[1];
                counts.put(contesterId, count);
            }

            req.setAttribute("contesters", contesters);
            req.setAttribute("voteCounts", counts);
            req.getRequestDispatcher("/admin/voter-stats.jsp").forward(req, resp);
        } finally {
            em.close();
        }
    }
}