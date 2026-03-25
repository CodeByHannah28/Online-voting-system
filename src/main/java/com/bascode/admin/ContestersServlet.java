package com.bascode.admin;

import com.bascode.model.entity.Contester;
import com.bascode.model.enums.ContesterStatus;
import com.bascode.model.enums.Position;
import com.bascode.model.enums.Role;
import com.bascode.util.AdminAuditSupport;
import com.bascode.util.PositionSupport;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.List;

public class ContestersServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");  
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        EntityManagerFactory factory = emf();
        String search = trimToNull(req.getParameter("search"));
        String statusFilter = trimToNull(req.getParameter("status"));
        int requestedPage = parsePage(req.getParameter("page"));
        String pageError = req.getAttribute("pageError") instanceof String
                ? req.getAttribute("pageError").toString()
                : null;
        String pageSuccess = resolveSuccessMessage(req.getParameter("success"));
        if (factory == null) {
            forwardContestersPage(req, resp, Collections.emptyList(), search, statusFilter,
                    requestedPage, 1, 0L,
                    "We couldn't load contester records right now. Please try again shortly.");
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            ContesterStatus requestedStatus = parseStatus(statusFilter);
            if (statusFilter != null && requestedStatus == null) {
                forwardContestersPage(req, resp, Collections.emptyList(), search, null,
                        1, 1, 0L, "That status filter is not valid.");
                return;
            }

            StringBuilder whereClause = new StringBuilder(" WHERE 1=1");
            if (search != null) {
                whereClause.append(" AND (LOWER(c.user.firstName) LIKE :s OR LOWER(c.user.lastName) LIKE :s OR LOWER(c.user.email) LIKE :s)");
            }
            if (requestedStatus != null) {
                whereClause.append(" AND c.status = :status");
            }

            TypedQuery<Long> countQuery = em.createQuery("SELECT COUNT(c) FROM Contester c" + whereClause, Long.class);
            applyFilters(countQuery, search, requestedStatus);
            Long totalResults = countQuery.getSingleResult();

            int totalPages = totalResults == null || totalResults == 0L
                    ? 1
                    : (int) Math.ceil(totalResults / (double) PAGE_SIZE);
            int currentPage = Math.max(1, Math.min(requestedPage, totalPages));

            TypedQuery<Contester> q = em.createQuery(
                    "SELECT c FROM Contester c" + whereClause + " ORDER BY c.id DESC",
                    Contester.class);
            applyFilters(q, search, requestedStatus);
            q.setFirstResult((currentPage - 1) * PAGE_SIZE);
            q.setMaxResults(PAGE_SIZE);

            List<Contester> contesters = q.getResultList();
            forwardContestersPage(req, resp, contesters, search, statusFilter, currentPage, totalPages,
                    totalResults, pageError, pageSuccess);
        } catch (RuntimeException ex) {
            getServletContext().log("[ContestersServlet] Unable to load contester records.", ex);
            forwardContestersPage(req, resp, Collections.emptyList(), search, statusFilter,
                    requestedPage, 1, 0L,
                    "We couldn't load contester records right now. Please refresh or try again shortly.");
        } finally {
            em.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = trimToNull(req.getParameter("action"));
        if ("assign-position".equals(action)) {
            handleAssignPosition(req, resp);
            return;
        }
        if ("clear-all".equals(action)) {
            handleClearAllContesters(req, resp);
            return;
        }
        resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }

    private void handleAssignPosition(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idValue = trimToNull(req.getParameter("id"));
        String positionValue = trimToNull(req.getParameter("position"));
        if (idValue == null || positionValue == null) {
            req.setAttribute("pageError", "Select a position before saving the contester record.");
            doGet(req, resp);
            return;
        }

        Long contesterId;
        try {
            contesterId = Long.valueOf(idValue);
        } catch (NumberFormatException ex) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Position position;
        try {
            position = Position.valueOf(positionValue);
        } catch (IllegalArgumentException ex) {
            req.setAttribute("pageError", "That position is not recognized.");
            doGet(req, resp);
            return;
        }

        EntityManagerFactory factory = emf();
        if (factory == null) {
            req.setAttribute("pageError", "We couldn't save the position right now. Please try again shortly.");
            doGet(req, resp);
            return;
        }

        EntityManager em = factory.createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Contester contester = em.find(Contester.class, contesterId);
            if (contester == null) {
                tx.rollback();
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            if (isPositionFull(em, contester, position)) {
                tx.rollback();
                req.setAttribute("pageError",
                        "That office already has three approved contesters. Choose a different position.");
                doGet(req, resp);
                return;
            }

            contester.setPosition(position);
            if (contester.getStatus() == null) {
                contester.setStatus(ContesterStatus.PENDING);
            }

            em.merge(contester);
            AdminAuditSupport.record(em, req.getSession(false),
                    "ASSIGNED_CONTESTER_POSITION", "Contester", contester.getId(),
                    "Assigned " + PositionSupport.format(position) + " to contester #" + contester.getId() + ".");

            tx.commit();
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            getServletContext().log("[ContestersServlet] Unable to update contester position.", ex);
            req.setAttribute("pageError", "We couldn't update that contester position right now. Please try again.");
            doGet(req, resp);
            return;
        } finally {
            em.close();
        }

        resp.sendRedirect(buildRedirectUrl(req, "position-updated"));
    }

    private void handleClearAllContesters(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        EntityManagerFactory factory = emf();
        if (factory == null) {
            req.setAttribute("pageError", "We couldn't clear the contester register right now. Please try again shortly.");
            doGet(req, resp);
            return;
        }

        EntityManager em = factory.createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            List<Long> contesterUserIds = em.createQuery(
                            "SELECT DISTINCT c.user.id FROM Contester c WHERE c.user.id IS NOT NULL",
                            Long.class)
                    .getResultList();

            int revertedRoles = 0;
            if (!contesterUserIds.isEmpty()) {
                revertedRoles = em.createQuery(
                                "UPDATE User u SET u.role = :voterRole " +
                                        "WHERE u.role = :contesterRole AND u.id IN :userIds")
                        .setParameter("voterRole", Role.VOTER)
                        .setParameter("contesterRole", Role.CONTESTER)
                        .setParameter("userIds", contesterUserIds)
                        .executeUpdate();
            }

            int removedVotes = em.createQuery("DELETE FROM Vote v").executeUpdate();
            int removedContesters = em.createQuery("DELETE FROM Contester c").executeUpdate();

            AdminAuditSupport.record(em, req.getSession(false),
                    "CLEARED_CONTESTERS", "Election", null,
                    "Cleared " + removedContesters + " contesters, deleted " + removedVotes
                            + " votes, and reverted " + revertedRoles + " users to VOTER.");

            tx.commit();

            String successCode = removedContesters == 0 && removedVotes == 0 && revertedRoles == 0
                    ? "contesters-already-clear"
                    : "contesters-cleared";
            resp.sendRedirect(buildRedirectUrl(req, successCode, false));
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            getServletContext().log("[ContestersServlet] Unable to clear the contester register.", ex);
            req.setAttribute("pageError",
                    "We couldn't clear the contester register right now. Please try again.");
            doGet(req, resp);
        } finally {
            em.close();
        }
    }

    private void forwardContestersPage(HttpServletRequest req, HttpServletResponse resp, List<Contester> contesters,
                                       String search, String statusFilter, int currentPage, int totalPages,
                                       Long totalResults, String pageError)
            throws ServletException, IOException {
        forwardContestersPage(req, resp, contesters, search, statusFilter, currentPage, totalPages,
                totalResults, pageError, null);
    }

    private void forwardContestersPage(HttpServletRequest req, HttpServletResponse resp, List<Contester> contesters,
                                       String search, String statusFilter, int currentPage, int totalPages,
                                       Long totalResults, String pageError, String pageSuccess)
            throws ServletException, IOException {
        long safeTotalResults = totalResults != null ? totalResults : 0L;
        int safeCurrentPage = Math.max(1, currentPage);
        req.setAttribute("contesters", contesters != null ? contesters : Collections.emptyList());
        req.setAttribute("search", search);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("positions", Position.values());
        req.setAttribute("positionLabels", PositionSupport.labels());
        req.setAttribute("currentPage", safeCurrentPage);
        req.setAttribute("totalPages", Math.max(1, totalPages));
        req.setAttribute("totalResults", safeTotalResults);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("showingFrom", safeTotalResults == 0L ? 0L : ((long) (safeCurrentPage - 1) * PAGE_SIZE) + 1L);
        req.setAttribute("showingTo", Math.min(safeTotalResults, (long) safeCurrentPage * PAGE_SIZE));
        req.setAttribute("pageError", pageError);
        req.setAttribute("pageSuccess", pageSuccess);
        req.getRequestDispatcher("/admin/contesters.jsp").forward(req, resp);
    }

    private void applyFilters(TypedQuery<?> query, String search, ContesterStatus status) {
        if (search != null) {
            query.setParameter("s", "%" + search.toLowerCase() + "%");
        }
        if (status != null) {
            query.setParameter("status", status);
        }
    }

    private boolean isPositionFull(EntityManager em, Contester contester, Position position) {
        if (position == null) {
            return false;
        }

        Long currentId = contester != null ? contester.getId() : null;
        TypedQuery<Long> query;
        if (currentId == null) {
            query = em.createQuery(
                    "SELECT COUNT(c) FROM Contester c WHERE c.position = :position AND c.status = :approved",
                    Long.class);
        } else {
            query = em.createQuery(
                    "SELECT COUNT(c) FROM Contester c WHERE c.position = :position AND c.status = :approved AND c.id <> :currentId",
                    Long.class);
            query.setParameter("currentId", currentId);
        }

        Long approvedCount = query
                .setParameter("position", position)
                .setParameter("approved", ContesterStatus.APPROVED)
                .getSingleResult();
        return approvedCount != null && approvedCount >= 3;
    }

    private ContesterStatus parseStatus(String value) {
        if (value == null) {
            return null;
        }
        try {
            return ContesterStatus.valueOf(value);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }

    private int parsePage(String pageValue) {
        if (pageValue == null || pageValue.isBlank()) {
            return 1;
        }

        try {
            return Math.max(1, Integer.parseInt(pageValue));
        } catch (NumberFormatException ex) {
            return 1;
        }
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }

        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String resolveSuccessMessage(String successCode) {
        if ("position-updated".equals(successCode)) {
            return "The contester position was updated successfully.";
        }
        if ("contesters-cleared".equals(successCode)) {
            return "The election was reset. All contesters and recorded votes were removed, and former contesters can register again.";
        }
        if ("contesters-already-clear".equals(successCode)) {
            return "The contester register was already clear, so no contesters or recorded votes needed removal.";
        }
        return null;
    }

    private String buildRedirectUrl(HttpServletRequest req, String successCode) {
        return buildRedirectUrl(req, successCode, true);
    }

    private String buildRedirectUrl(HttpServletRequest req, String successCode, boolean preserveFilters) {
        StringBuilder url = new StringBuilder(req.getContextPath())
                .append("/admin/contesters?success=")
                .append(encode(successCode));

        if (preserveFilters) {
            appendQueryValue(url, "search", trimToNull(req.getParameter("search")));
            appendQueryValue(url, "status", trimToNull(req.getParameter("status")));
            appendQueryValue(url, "page", trimToNull(req.getParameter("page")));
        }
        return url.toString();
    }

    private void appendQueryValue(StringBuilder url, String key, String value) {
        if (value == null) {
            return;
        }
        url.append('&').append(key).append('=').append(encode(value));
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
