package com.bascode.voter;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.enums.ContesterStatus;
import com.bascode.model.enums.Position;
import com.bascode.model.enums.Role;
import com.bascode.util.AgeEligibility;
import com.bascode.util.ContesterSupport;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

public class ContesterRegistrationServlet extends HttpServlet {

    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");
    }

    /** GET: Show registration form */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        req.setAttribute("positionOptions", Collections.emptyList());

        EntityManagerFactory factory = emf();
        if (factory == null) {
            if (req.getAttribute("error") == null) {
                req.setAttribute("error", "Contester registration is temporarily unavailable.");
            }
            req.getRequestDispatcher("/register-contester.jsp").forward(req, resp);
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            populateViewAttributes(req, em, userId);
        } catch (RuntimeException ex) {
            getServletContext().log("Failed to load contester registration page for userId=" + userId, ex);
            req.setAttribute("positionOptions", Collections.emptyList());
            if (req.getAttribute("error") == null) {
                req.setAttribute("error", "We couldn't load your contester details right now. Please try again.");
            }
        } finally {
            em.close();
        }

        req.getRequestDispatcher("/register-contester.jsp").forward(req, resp);
    }

    /** POST: Submit contester registration */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Long userId = (session != null) ? (Long) session.getAttribute("userId") : null;
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String positionStr = req.getParameter("position");
        if (positionStr == null || positionStr.trim().isEmpty()) {
            req.setAttribute("error", "Please select a position.");
            doGet(req, resp);
            return;
        }

        Position position;
        try {
            position = Position.valueOf(positionStr);
        } catch (IllegalArgumentException e) {
            req.setAttribute("error", "Invalid position selected.");
            doGet(req, resp);
            return;
        }

        EntityManagerFactory factory = emf();
        if (factory == null) {
            req.setAttribute("error", "Database unavailable.");
            doGet(req, resp);
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            Contester existingContester = loadExistingContester(em, userId);
            if (ContesterSupport.hasSelectedPosition(existingContester)) {
                req.setAttribute("error", "You have already registered as a contester.");
                req.setAttribute("alreadyRegistered", true);
                req.setAttribute("contester", existingContester);
                applyContesterDetails(req, existingContester);
                doGet(req, resp);
                return;
            }

            // Rule: Max 3 approved contesters per position
            Long approvedCount = em.createQuery(
                "SELECT COUNT(c) FROM Contester c WHERE c.position = :pos AND c.status = :approved", Long.class)
                .setParameter("pos", position)
                .setParameter("approved", ContesterStatus.APPROVED)
                .getSingleResult();
            if (approvedCount >= 3) {
                req.setAttribute("error", "This position already has the maximum 3 approved contesters. Please choose another position.");
                doGet(req, resp);
                return;
            }

            User user = em.find(User.class, userId);
            if (user == null) {
                req.setAttribute("error", "User not found.");
                doGet(req, resp);
                return;
            }

            // Age validation for contester (must be 18+)
            if (!AgeEligibility.isAtLeast18(user.getBirthYear())) {
                req.setAttribute("error", AgeEligibility.contesterRefusalMessage());
                doGet(req, resp);
                return;
            }

            em.getTransaction().begin();
            if (!Role.CONTESTER.equals(user.getRole())) {
                user.setRole(Role.CONTESTER);
            }

            Contester contester = existingContester;
            if (contester == null) {
                contester = ContesterSupport.newPendingApplication(user);
                em.persist(contester);
            } else if (contester.getStatus() == null) {
                contester.setStatus(ContesterStatus.PENDING);
            }

            contester.setUser(user);
            contester.setPosition(position);
            em.getTransaction().commit();

            req.setAttribute("success", "Your contester application for " + position.name().replace('_', ' ') + " has been submitted! It is pending admin approval.");
            req.setAttribute("alreadyRegistered", true);
            req.setAttribute("contester", contester);
            applyContesterDetails(req, contester);
            session.setAttribute("user", user);
            session.setAttribute("userRole", user.getRole() != null ? user.getRole().name() : null);
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            getServletContext().log("Failed to submit contester registration for userId=" + userId, e);
            req.setAttribute("error", "An error occurred. Please try again.");
        } finally {
            em.close();
        }
        doGet(req, resp);
    }

    private void populateViewAttributes(HttpServletRequest req, EntityManager em, Long userId) {
        req.setAttribute("positionOptions", buildPositionOptions(em));

        Contester contester = loadExistingContester(em, userId);
        if (contester != null) {
            req.setAttribute("contester", contester);
            if (ContesterSupport.hasSelectedPosition(contester)) {
                req.setAttribute("alreadyRegistered", true);
                applyContesterDetails(req, contester);
            } else {
                req.setAttribute("incompleteApplication", true);
                if (req.getAttribute("warning") == null && req.getAttribute("success") == null) {
                    req.setAttribute("warning", "Choose a position to complete your contester application.");
                }
            }
        }
    }

    private List<PositionOption> buildPositionOptions(EntityManager em) {
        List<PositionOption> options = new ArrayList<>();
        for (Position pos : Position.values()) {
            Long approvedCount = em.createQuery(
                    "SELECT COUNT(c) FROM Contester c WHERE c.position = :pos AND c.status = :approved",
                    Long.class)
                .setParameter("pos", pos)
                .setParameter("approved", ContesterStatus.APPROVED)
                .getSingleResult();

            options.add(new PositionOption(
                pos.name(),
                VoterPortalSupport.formatPosition(pos),
                approvedCount != null ? approvedCount : 0L
            ));
        }
        return options;
    }

    private Contester loadExistingContester(EntityManager em, Long userId) {
        List<Contester> results = em.createQuery(
                "SELECT c FROM Contester c WHERE c.user.id = :uid ORDER BY c.id DESC",
                Contester.class)
            .setParameter("uid", userId)
            .setMaxResults(1)
            .getResultList();

        return results.isEmpty() ? null : results.get(0);
    }

    private void applyContesterDetails(HttpServletRequest req, Contester contester) {
        if (contester == null) {
            return;
        }

        req.setAttribute("contesterPositionLabel", VoterPortalSupport.formatPosition(contester.getPosition()));
        req.setAttribute("contesterStatusClass", formatStatusClass(contester.getStatus()));
    }

    private String formatStatusClass(ContesterStatus status) {
        if (status == null) {
            return "pending";
        }
        return status.name().toLowerCase(Locale.ENGLISH);
    }

    public static final class PositionOption {
        private final String value;
        private final String label;
        private final long approvedCount;

        PositionOption(String value, String label, long approvedCount) {
            this.value = value;
            this.label = label;
            this.approvedCount = approvedCount;
        }

        public String getValue() {
            return value;
        }

        public String getLabel() {
            return label;
        }

        public long getApprovedCount() {
            return approvedCount;
        }

        public boolean isFull() {
            return approvedCount >= 3;
        }
    }
}
