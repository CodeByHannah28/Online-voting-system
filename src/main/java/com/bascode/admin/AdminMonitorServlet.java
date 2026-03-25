package com.bascode.admin;

import com.bascode.model.entity.AdminAuditLog;
import com.bascode.model.entity.ContactMessage;
import com.bascode.model.entity.ElectionSetting;
import com.bascode.model.enums.ContesterStatus;
import com.bascode.util.AdminAuditSupport;
import com.bascode.util.ElectionSettingsSupport;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.MemoryUsage;
import java.lang.management.OperatingSystemMXBean;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.time.Duration;
import java.time.Instant;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AdminMonitorServlet extends HttpServlet {

    private static final Instant started = Instant.now();

    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        MemoryMXBean mem = ManagementFactory.getMemoryMXBean();
        MemoryUsage heap = mem.getHeapMemoryUsage();

        OperatingSystemMXBean os = ManagementFactory.getOperatingSystemMXBean();

        Map<String, Object> stats = new HashMap<>();
        stats.put("heapInit", heap.getInit());
        stats.put("heapUsed", heap.getUsed());
        stats.put("heapCommitted", heap.getCommitted());
        stats.put("heapMax", heap.getMax());
        stats.put("heapUsagePercent", (double) heap.getUsed() / heap.getMax() * 100);
        
        stats.put("osName", os.getName());
        stats.put("osArch", os.getArch());
        stats.put("osVersion", os.getVersion());
        stats.put("availableProcessors", os.getAvailableProcessors());
        stats.put("systemLoadAverage", os.getSystemLoadAverage());
        
        stats.put("uptimeSeconds", Duration.between(started, Instant.now()).getSeconds());
        stats.put("threadCount", ManagementFactory.getThreadMXBean().getThreadCount());
        stats.put("peakThreadCount", ManagementFactory.getThreadMXBean().getPeakThreadCount());

        req.setAttribute("stats", stats);
        req.setAttribute("auditLogs", Collections.emptyList());
        req.setAttribute("contactMessages", Collections.emptyList());
        req.setAttribute("auditLogCount", 0L);
        req.setAttribute("contactMessageCount", 0L);
        req.setAttribute("pendingApprovals", 0L);
        req.setAttribute("votingDeadlineInputValue", "");
        req.setAttribute("votingDeadlineDisplay", ElectionSettingsSupport.formatDisplay(null));
        req.setAttribute("votingClosed", false);
        req.setAttribute("pageSuccess", resolveSuccessMessage(req.getParameter("success")));

        EntityManagerFactory factory = emf();
        if (factory != null) {
            EntityManager em = factory.createEntityManager();
            try {
                ElectionSetting setting = ElectionSettingsSupport.load(em);
                List<AdminAuditLog> auditLogs = em.createQuery(
                                "SELECT a FROM AdminAuditLog a ORDER BY a.createdAt DESC",
                                AdminAuditLog.class)
                        .setMaxResults(10)
                        .getResultList();
                List<ContactMessage> contactMessages = em.createQuery(
                                "SELECT c FROM ContactMessage c ORDER BY c.createdAt DESC",
                                ContactMessage.class)
                        .setMaxResults(8)
                        .getResultList();

                Long auditLogCount = em.createQuery("SELECT COUNT(a) FROM AdminAuditLog a", Long.class)
                        .getSingleResult();
                Long contactMessageCount = em.createQuery("SELECT COUNT(c) FROM ContactMessage c", Long.class)
                        .getSingleResult();
                Long pendingApprovals = em.createQuery(
                                "SELECT COUNT(c) FROM Contester c WHERE c.status = :status",
                                Long.class)
                        .setParameter("status", ContesterStatus.PENDING)
                        .getSingleResult();

                req.setAttribute("auditLogs", auditLogs);
                req.setAttribute("contactMessages", contactMessages);
                req.setAttribute("auditLogCount", auditLogCount != null ? auditLogCount : 0L);
                req.setAttribute("contactMessageCount", contactMessageCount != null ? contactMessageCount : 0L);
                req.setAttribute("pendingApprovals", pendingApprovals != null ? pendingApprovals : 0L);
                req.setAttribute("votingDeadlineInputValue",
                        ElectionSettingsSupport.formatInput(setting != null ? setting.getVotingDeadline() : null));
                req.setAttribute("votingDeadlineDisplay",
                        ElectionSettingsSupport.formatDisplay(setting != null ? setting.getVotingDeadline() : null));
                req.setAttribute("votingClosed", ElectionSettingsSupport.isVotingClosed(setting));
                req.setAttribute("votingDeadlineUpdatedBy", setting != null ? setting.getUpdatedBy() : null);
                req.setAttribute("votingDeadlineUpdatedAt",
                        setting != null && setting.getUpdatedAt() != null
                                ? ElectionSettingsSupport.formatDisplay(setting.getUpdatedAt())
                                : "No deadline updates have been recorded yet.");
            } catch (RuntimeException ex) {
                getServletContext().log("[AdminMonitorServlet] Unable to load operational data.", ex);
                if (req.getAttribute("pageError") == null) {
                    req.setAttribute("pageError",
                            "Runtime metrics are available, but we couldn't load the latest election controls and activity history.");
                }
            } finally {
                em.close();
            }
        } else if (req.getAttribute("pageError") == null) {
            req.setAttribute("pageError",
                    "Database-backed monitoring features are temporarily unavailable. Runtime health metrics are still shown below.");
        }

        req.getRequestDispatcher("/admin/monitor.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = trimToNull(req.getParameter("action"));
        if (action == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        EntityManagerFactory factory = emf();
        if (factory == null) {
            req.setAttribute("pageError", "Election controls are unavailable right now. Please try again shortly.");
            doGet(req, resp);
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            em.getTransaction().begin();
            ElectionSetting setting = ElectionSettingsSupport.loadOrCreate(em);

            if ("save-deadline".equals(action)) {
                String rawDeadline = trimToNull(req.getParameter("votingDeadline"));
                if (rawDeadline == null) {
                    em.getTransaction().rollback();
                    req.setAttribute("pageError", "Choose a deadline before saving the voting schedule.");
                    doGet(req, resp);
                    return;
                }

                LocalDateTime deadline;
                try {
                    deadline = LocalDateTime.parse(rawDeadline);
                } catch (DateTimeParseException ex) {
                    em.getTransaction().rollback();
                    req.setAttribute("pageError", "That deadline could not be understood. Please choose the date and time again.");
                    doGet(req, resp);
                    return;
                }

                setting.setVotingDeadline(deadline);
                setting.setUpdatedBy(AdminAuditSupport.actorLabel(req.getSession(false)));
                em.merge(setting);
                AdminAuditSupport.record(em, req.getSession(false),
                        "UPDATED_VOTING_DEADLINE", "ElectionSetting", setting.getId(),
                        "Voting deadline set to " + ElectionSettingsSupport.formatDisplay(deadline) + ".");
                em.getTransaction().commit();
                resp.sendRedirect(req.getContextPath() + "/admin/monitor?success=deadline-saved");
                return;
            }

            if ("clear-deadline".equals(action)) {
                setting.setVotingDeadline(null);
                setting.setUpdatedBy(AdminAuditSupport.actorLabel(req.getSession(false)));
                em.merge(setting);
                AdminAuditSupport.record(em, req.getSession(false),
                        "CLEARED_VOTING_DEADLINE", "ElectionSetting", setting.getId(),
                        "Voting deadline cleared. Voting remains open until a new deadline is configured.");
                em.getTransaction().commit();
                resp.sendRedirect(req.getContextPath() + "/admin/monitor?success=deadline-cleared");
                return;
            }

            em.getTransaction().rollback();
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (RuntimeException ex) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            getServletContext().log("[AdminMonitorServlet] Unable to update election controls.", ex);
            req.setAttribute("pageError", "We couldn't update the voting deadline right now. Please try again.");
            doGet(req, resp);
        } finally {
            em.close();
        }
    }

    private String resolveSuccessMessage(String successCode) {
        if ("deadline-saved".equals(successCode)) {
            return "The voting deadline was saved successfully.";
        }
        if ("deadline-cleared".equals(successCode)) {
            return "The voting deadline was cleared. Voting is open until a new deadline is set.";
        }
        return null;
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }

        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
