package com.bascode.admin;

import com.bascode.model.entity.Contester;
import com.bascode.model.enums.ContesterStatus;
import com.bascode.model.enums.Position;
import com.bascode.util.AdminAuditSupport;
import com.bascode.util.ContesterSupport;
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
import java.util.Collections;
import java.util.List;

public class PendingApprovalsServlet extends HttpServlet {
    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        EntityManagerFactory factory = emf();
        if (factory == null) {
            forwardPendingApprovalsPage(req, resp, Collections.emptyList(),
                    "We couldn't load pending approvals right now. Please try again shortly.");
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            TypedQuery<Contester> q = em.createQuery(
                    "SELECT c FROM Contester c WHERE c.status = :s ORDER BY c.id DESC",
                    Contester.class
            );
            q.setParameter("s", ContesterStatus.PENDING);
            List<Contester> pending = q.getResultList();
            forwardPendingApprovalsPage(req, resp, pending, null, resolveSuccessMessage(req.getParameter("success")));
        } catch (RuntimeException ex) {
            getServletContext().log("[PendingApprovalsServlet] Unable to load pending approvals.", ex);
            forwardPendingApprovalsPage(req, resp, Collections.emptyList(),
                    "We couldn't load pending approvals right now. Please refresh or try again shortly.");
        } finally {
            em.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = trimToNull(req.getParameter("action"));
        String idStr = trimToNull(req.getParameter("id"));
        if (idStr == null || action == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        EntityManagerFactory factory = emf();
        if (factory == null) {
            forwardPendingApprovalsPage(req, resp, Collections.emptyList(),
                    "We couldn't update approvals right now. Please try again shortly.");
            return;
        }

        Long id;
        try {
            id = Long.valueOf(idStr);
        } catch (NumberFormatException ex) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        EntityManager em = factory.createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Contester c = em.find(Contester.class, id);
            if (c == null) {
                tx.rollback();
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            Position selectedPosition = null;
            String positionValue = trimToNull(req.getParameter("position"));
            if (positionValue != null && ("save-position".equals(action) || "approve".equals(action))) {
                try {
                    selectedPosition = Position.valueOf(positionValue);
                } catch (IllegalArgumentException ex) {
                    tx.rollback();
                    forwardPendingApprovalsPage(req, resp, loadPendingContesters(em),
                            "That position is not recognized.");
                    return;
                }
            }

            if (selectedPosition != null) {
                if (isPositionFull(em, c, selectedPosition)) {
                    tx.rollback();
                    forwardPendingApprovalsPage(req, resp, loadPendingContesters(em),
                            "That office already has three approved contesters. Choose a different position.");
                    return;
                }
                c.setPosition(selectedPosition);
                if (c.getStatus() == null) {
                    c.setStatus(ContesterStatus.PENDING);
                }
            }

            if ("save-position".equals(action)) {
                if (!ContesterSupport.hasSelectedPosition(c)) {
                    tx.rollback();
                    forwardPendingApprovalsPage(req, resp, loadPendingContesters(em),
                            "Choose a position before saving this contester record.");
                    return;
                }
                em.merge(c);
                AdminAuditSupport.record(em, req.getSession(false),
                        "ASSIGNED_CONTESTER_POSITION", "Contester", c.getId(),
                        "Assigned " + PositionSupport.format(c.getPosition()) + " to pending contester #" + c.getId() + ".");
            } else if ("approve".equals(action)) {
                if (!ContesterSupport.hasSelectedPosition(c)) {
                    tx.rollback();
                    forwardPendingApprovalsPage(req, resp, loadPendingContesters(em),
                            "This contester still needs to choose a position before the application can be approved.");
                    return;
                }
                if (isPositionFull(em, c, c.getPosition())) {
                    tx.rollback();
                    forwardPendingApprovalsPage(req, resp, loadPendingContesters(em),
                            "Cannot approve this application because the selected office is already full.");
                    return;
                }
                c.setStatus(ContesterStatus.APPROVED);
                em.merge(c);
                AdminAuditSupport.record(em, req.getSession(false),
                        "APPROVED_CONTESTER", "Contester", c.getId(),
                        "Approved contester #" + c.getId() + " for " + PositionSupport.format(c.getPosition()) + ".");
            } else if ("deny".equals(action)) {
                c.setStatus(ContesterStatus.DENIED);
                em.merge(c);
                AdminAuditSupport.record(em, req.getSession(false),
                        "DENIED_CONTESTER", "Contester", c.getId(),
                        "Denied contester #" + c.getId() + ".");
            } else {
                tx.rollback();
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            tx.commit();
        } catch (RuntimeException ex) {
            if (tx.isActive()) tx.rollback();
            getServletContext().log("[PendingApprovalsServlet] Unable to update contester approval.", ex);
            forwardPendingApprovalsPage(req, resp, loadPendingContesters(em),
                    "We couldn't save that approval change right now. Please try again.");
            return;
        } finally {
            em.close();
        }
        resp.sendRedirect(req.getContextPath() + "/admin/pending-approvals?success=" + action);
    }

    private void forwardPendingApprovalsPage(HttpServletRequest req, HttpServletResponse resp, List<Contester> pending,
                                             String pageError) throws ServletException, IOException {
        forwardPendingApprovalsPage(req, resp, pending, pageError, null);
    }

    private void forwardPendingApprovalsPage(HttpServletRequest req, HttpServletResponse resp, List<Contester> pending,
                                             String pageError, String pageSuccess) throws ServletException, IOException {
        List<Contester> safePending = pending != null ? pending : Collections.emptyList();
        req.setAttribute("pendingContesters", safePending);
        req.setAttribute("pendingApprovals", safePending.size());
        req.setAttribute("positions", Position.values());
        req.setAttribute("positionLabels", PositionSupport.labels());
        req.setAttribute("pageError", pageError);
        req.setAttribute("pageSuccess", pageSuccess);
        req.getRequestDispatcher("/admin/pending-approvals.jsp").forward(req, resp);
    }

    private List<Contester> loadPendingContesters(EntityManager em) {
        if (em == null || !em.isOpen()) {
            return Collections.emptyList();
        }

        return em.createQuery("SELECT c FROM Contester c WHERE c.status = :s ORDER BY c.id DESC", Contester.class)
                .setParameter("s", ContesterStatus.PENDING)
                .getResultList();
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

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }

        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String resolveSuccessMessage(String successCode) {
        if ("save-position".equals(successCode)) {
            return "The pending contester position was saved successfully.";
        }
        if ("approve".equals(successCode)) {
            return "The contester application was approved successfully.";
        }
        if ("deny".equals(successCode)) {
            return "The contester application was denied.";
        }
        return null;
    }
}
