package com.bascode.voter;

import com.bascode.model.entity.Contester;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class ResultsServlet extends HttpServlet {

    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        EntityManagerFactory factory = emf();
        if (factory == null) {
            forwardResultsPage(req, resp, Collections.emptyList(), Collections.emptyMap(), Collections.emptyMap(),
                    0L, "We couldn't load the live results right now. Please try again shortly.");
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            List<Contester> candidates = VoterPortalSupport.loadApprovedCandidates(em);
            Map<String, List<Contester>> candidatesByPosition = VoterPortalSupport.groupCandidatesByPosition(candidates);
            Map<Long, Long> voteCounts = VoterPortalSupport.loadVoteCounts(em);
            Long totalVotes = em.createQuery("SELECT COUNT(v) FROM Vote v", Long.class).getSingleResult();

            forwardResultsPage(req, resp, candidates, candidatesByPosition, voteCounts, totalVotes, null);
        } catch (RuntimeException ex) {
            getServletContext().log("[ResultsServlet] Unable to load election results.", ex);
            forwardResultsPage(req, resp, Collections.emptyList(), Collections.emptyMap(), Collections.emptyMap(),
                    0L, "We couldn't load the live results right now. Please refresh or try again shortly.");
        } finally {
            em.close();
        }
    }

    private void forwardResultsPage(HttpServletRequest req, HttpServletResponse resp, List<Contester> candidates,
                                    Map<String, List<Contester>> candidatesByPosition, Map<Long, Long> voteCounts,
                                    Long totalVotes, String pageError)
            throws ServletException, IOException {
        req.setAttribute("candidates", candidates != null ? candidates : Collections.emptyList());
        req.setAttribute("candidatesByPosition", candidatesByPosition != null ? candidatesByPosition : Collections.emptyMap());
        req.setAttribute("voteCounts", voteCounts != null ? voteCounts : Collections.emptyMap());
        req.setAttribute("totalVotes", totalVotes != null ? totalVotes : 0L);
        req.setAttribute("pageError", pageError);
        req.getRequestDispatcher("/results.jsp").forward(req, resp);
    }
}
