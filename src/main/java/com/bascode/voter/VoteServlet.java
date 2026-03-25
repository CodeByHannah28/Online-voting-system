package com.bascode.voter;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.ElectionSetting;
import com.bascode.model.entity.User;
import com.bascode.model.entity.Vote;
import com.bascode.model.enums.Position;
import com.bascode.util.AgeEligibility;
import com.bascode.util.ElectionSettingsSupport;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class VoteServlet extends HttpServlet {

    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");
    }

    /** GET: Show the voting form with approved candidates */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        EntityManagerFactory factory = emf();
        HttpSession session = req.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;

        if (factory == null) {
            req.setAttribute("candidates", Collections.emptyList());
            req.setAttribute("candidatesByPosition", Collections.emptyMap());
            req.setAttribute("error", "We couldn't load the ballot right now. Please try again shortly.");
            req.getRequestDispatcher("/vote.jsp").forward(req, resp);
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            ElectionSetting electionSetting = ElectionSettingsSupport.load(em);
            req.setAttribute("votingDeadlineDisplay",
                    ElectionSettingsSupport.formatDisplay(electionSetting != null ? electionSetting.getVotingDeadline() : null));
            req.setAttribute("votingDeadlineActive",
                    electionSetting != null && electionSetting.getVotingDeadline() != null);
            req.setAttribute("votingClosed", ElectionSettingsSupport.isVotingClosed(electionSetting));

            if (VoterPortalSupport.countVotesForVoter(em, userId) > 0) {
                req.setAttribute("alreadyVoted", true);
            }

            List<Contester> candidates = VoterPortalSupport.loadApprovedCandidates(em);
            Map<String, List<Contester>> candidatesByPosition = VoterPortalSupport.groupCandidatesByPosition(candidates);
            req.setAttribute("candidates", candidates);
            req.setAttribute("candidatesByPosition", candidatesByPosition);
            req.setAttribute("ballotOfficeCount", candidatesByPosition.size());
            req.getRequestDispatcher("/vote.jsp").forward(req, resp);
        } catch (RuntimeException ex) {
            getServletContext().log("[VoteServlet] Unable to load ballot.", ex);
            req.setAttribute("candidates", Collections.emptyList());
            req.setAttribute("candidatesByPosition", Collections.emptyMap());
            req.setAttribute("error", "We couldn't load the ballot right now. Please refresh or try again shortly.");
            req.getRequestDispatcher("/vote.jsp").forward(req, resp);
        } finally {
            em.close();
        }
    }

    /** POST: Submit a vote */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;

        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        EntityManagerFactory factory = emf();
        if (factory == null) {
            req.setAttribute("error", "Database unavailable. Please try again later.");
            doGet(req, resp);
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            Long voteCount = VoterPortalSupport.countVotesForVoter(em, userId);

            if (voteCount > 0) {
                req.setAttribute("error", "You have already submitted your ballot.");
                req.setAttribute("alreadyVoted", true);
                doGet(req, resp);
                return;
            }

            ElectionSetting electionSetting = ElectionSettingsSupport.load(em);
            if (ElectionSettingsSupport.isVotingClosed(electionSetting)) {
                req.setAttribute("error", "Voting has closed for this election. New ballots are no longer being accepted.");
                doGet(req, resp);
                return;
            }

            List<Contester> candidates = VoterPortalSupport.loadApprovedCandidates(em);
            Map<Position, List<Contester>> candidatesByPosition = VoterPortalSupport.groupCandidatesByPositionValue(candidates);
            if (candidatesByPosition.isEmpty()) {
                req.setAttribute("error", "No approved candidates are available for voting right now.");
                doGet(req, resp);
                return;
            }

            Map<Long, Contester> candidateIndex = new HashMap<>();
            for (Contester candidate : candidates) {
                if (candidate != null && candidate.getId() != null) {
                    candidateIndex.put(candidate.getId(), candidate);
                }
            }

            Map<Position, Contester> selections = new LinkedHashMap<>();
            for (Map.Entry<Position, List<Contester>> section : candidatesByPosition.entrySet()) {
                Position position = section.getKey();
                String contesterIdStr = req.getParameter(selectionParamName(position));
                if (contesterIdStr == null || contesterIdStr.trim().isEmpty()) {
                    req.setAttribute("error", "Please choose one candidate for every position on the ballot.");
                    doGet(req, resp);
                    return;
                }

                Long contesterId;
                try {
                    contesterId = Long.parseLong(contesterIdStr);
                } catch (NumberFormatException ex) {
                    req.setAttribute("error", "One of the ballot selections was invalid. Please try again.");
                    doGet(req, resp);
                    return;
                }

                Contester contester = candidateIndex.get(contesterId);
                if (contester == null || contester.getPosition() != position) {
                    req.setAttribute("error", "One of the ballot selections did not match the expected office. Please review and try again.");
                    doGet(req, resp);
                    return;
                }

                selections.put(position, contester);
            }

            User voter = em.find(User.class, userId);

            if (voter == null) {
                req.setAttribute("error", "Invalid selection. Please try again.");
                doGet(req, resp);
                return;
            }

            // Age validation for voter
            if (!AgeEligibility.isAtLeast18(voter.getBirthYear())) {
                req.setAttribute("error", AgeEligibility.votingRefusalMessage());
                doGet(req, resp);
                return;
            }

            em.getTransaction().begin();
            for (Map.Entry<Position, Contester> selection : selections.entrySet()) {
                Vote vote = new Vote();
                vote.setVoter(voter);
                vote.setContester(selection.getValue());
                vote.setPosition(selection.getKey());
                em.persist(vote);
            }
            em.getTransaction().commit();

            resp.sendRedirect(req.getContextPath() + "/voter/results?success=true");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            req.setAttribute("error", "An error occurred while submitting your vote. Please try again.");
            doGet(req, resp);
        } finally {
            em.close();
        }
    }

    private String selectionParamName(Position position) {
        return "selection_" + position.name();
    }
}
