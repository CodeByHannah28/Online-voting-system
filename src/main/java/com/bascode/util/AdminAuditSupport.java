package com.bascode.util;

import com.bascode.model.entity.AdminAuditLog;
import jakarta.persistence.EntityManager;
import jakarta.servlet.http.HttpSession;

public final class AdminAuditSupport {

    private static final int MAX_DETAILS_LENGTH = 500;

    private AdminAuditSupport() {
    }

    public static void record(EntityManager em, HttpSession session, String action,
                              String targetType, Long targetId, String details) {
        if (em == null || action == null || action.isBlank() || targetType == null || targetType.isBlank()) {
            return;
        }

        AdminAuditLog log = new AdminAuditLog();
        log.setAdminName(readSessionValue(session, "userName", "Administrator"));
        log.setAdminEmail(readSessionValue(session, "userEmail", "unknown@local"));
        log.setAction(action);
        log.setTargetType(targetType);
        log.setTargetId(targetId);
        log.setDetails(trimDetails(details));
        em.persist(log);
    }

    public static String actorLabel(HttpSession session) {
        String name = readSessionValue(session, "userName", "Administrator");
        String email = readSessionValue(session, "userEmail", "unknown@local");
        return name + " (" + email + ")";
    }

    private static String readSessionValue(HttpSession session, String attribute, String fallback) {
        if (session == null) {
            return fallback;
        }

        Object value = session.getAttribute(attribute);
        if (value == null) {
            return fallback;
        }

        String text = value.toString().trim();
        return text.isEmpty() ? fallback : text;
    }

    private static String trimDetails(String details) {
        if (details == null || details.isBlank()) {
            return "No additional details were recorded.";
        }

        String normalized = details.trim();
        return normalized.length() <= MAX_DETAILS_LENGTH
                ? normalized
                : normalized.substring(0, MAX_DETAILS_LENGTH - 3) + "...";
    }
}
