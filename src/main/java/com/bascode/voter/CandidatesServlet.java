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


public class CandidatesServlet extends HttpServlet {

    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        EntityManagerFactory factory = emf();
        if (factory == null) {
            forwardCandidatesPage(req, resp, Collections.emptyList(), Collections.emptyMap(),
                    "We couldn't load the candidates right now. Please try again shortly.");
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            List<Contester> candidates = VoterPortalSupport.loadApprovedCandidates(em);
            Map<String, List<Contester>> candidatesByPosition = VoterPortalSupport.groupCandidatesByPosition(candidates);
            forwardCandidatesPage(req, resp, candidates, candidatesByPosition, null);
        } catch (RuntimeException ex) {
            getServletContext().log("[CandidatesServlet] Unable to load approved candidates.", ex);
            forwardCandidatesPage(req, resp, Collections.emptyList(), Collections.emptyMap(),
                    "We couldn't load the candidates right now. Please refresh or try again shortly.");
        } finally {
            em.close();
        }
    }

    private void forwardCandidatesPage(HttpServletRequest req, HttpServletResponse resp, List<Contester> candidates,
                                       Map<String, List<Contester>> candidatesByPosition, String pageError)
            throws ServletException, IOException {
        req.setAttribute("candidates", candidates != null ? candidates : Collections.emptyList());
        req.setAttribute("candidatesByPosition", candidatesByPosition != null ? candidatesByPosition : Collections.emptyMap());
        req.setAttribute("pageError", pageError);
        req.getRequestDispatcher("/candidates.jsp").forward(req, resp);
    }
}
