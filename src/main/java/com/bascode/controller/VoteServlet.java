package com.bascode.controller;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.entity.Vote;
import com.bascode.model.enums.ContesterStatus;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/vote")
public class VoteServlet extends HttpServlet {
    private EntityManagerFactory emf = Persistence.createEntityManagerFactory("VotingPU");

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        EntityManager em = emf.createEntityManager();
        HttpSession session = request.getSession();

        Long userId = null;
        try {
            userId = (Long) session.getAttribute("userId");
        } catch (Exception ignore) {
            // in case session stores as String or other type
        }

        if (userId == null) {
            response.sendRedirect("index.jsp?error=LoginRequired");
            return;
        }

        String contesterParam = request.getParameter("contesterId");
        Long contesterId = null;
        try {
            if (contesterParam == null || contesterParam.isEmpty()) {
                response.sendRedirect("vote-page.jsp?error=NoCandidateSelected");
                return;
            }
            contesterId = Long.parseLong(contesterParam);
        } catch (NumberFormatException nfe) {
            response.sendRedirect("vote-page.jsp?error=InvalidCandidateId");
            return;
        }

        try {
            // Rule 1: Enforce One vote per user
            Long voteCount = em.createQuery(
                    "SELECT COUNT(v) FROM Vote v WHERE v.voter.id = :uId", Long.class)
                    .setParameter("uId", userId)
                    .getSingleResult();

            if (voteCount != null && voteCount > 0) {
                response.sendRedirect("results.jsp?error=AlreadyVoted");
                return;
            }

            // Rule 2: Enforce Only approved contesters
            Contester candidate = em.find(Contester.class, contesterId);
            if (candidate == null || candidate.getStatus() != ContesterStatus.APPROVED) {
                response.sendRedirect("vote-page.jsp?error=InvalidCandidate");
                return;
            }

            User voter = em.find(User.class, userId);
            if (voter == null) {
                response.sendRedirect("index.jsp?error=LoginRequired");
                return;
            }

            // Save the Vote if rules pass
            em.getTransaction().begin();
            Vote newVote = new Vote();
            // Link the vote to the current user and the chosen candidate
            newVote.setVoter(voter);
            newVote.setContester(candidate);

            em.persist(newVote);
            em.getTransaction().commit();

            response.sendRedirect("index.jsp?success=Voted");

        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
            response.sendRedirect("vote-page.jsp?error=SystemError");
        } finally {
            em.close();
        }
    }
}