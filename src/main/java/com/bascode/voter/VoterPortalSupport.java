package com.bascode.voter;

import com.bascode.model.entity.Contester;
import com.bascode.model.enums.Position;
import jakarta.persistence.EntityManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

final class VoterPortalSupport {

    private VoterPortalSupport() {
    }

    static List<Contester> loadApprovedCandidates(EntityManager em) {
        return em.createQuery(
                "SELECT c FROM Contester c " +
                "WHERE c.status = com.bascode.model.enums.ContesterStatus.APPROVED " +
                "AND c.position IS NOT NULL " +
                "ORDER BY c.position, c.user.lastName, c.user.firstName",
                Contester.class
        ).getResultList();
    }

    static Map<String, List<Contester>> groupCandidatesByPosition(List<Contester> candidates) {
        LinkedHashMap<String, List<Contester>> grouped = new LinkedHashMap<>();
        for (Position position : Position.values()) {
            grouped.put(formatPosition(position), new ArrayList<>());
        }

        for (Contester candidate : candidates) {
            grouped.computeIfAbsent(formatPosition(candidate.getPosition()), key -> new ArrayList<>()).add(candidate);
        }

        grouped.entrySet().removeIf(entry -> entry.getValue().isEmpty());
        return grouped;
    }

    static Map<Position, List<Contester>> groupCandidatesByPositionValue(List<Contester> candidates) {
        LinkedHashMap<Position, List<Contester>> grouped = new LinkedHashMap<>();
        for (Position position : Position.values()) {
            grouped.put(position, new ArrayList<>());
        }

        for (Contester candidate : candidates) {
            if (candidate == null || candidate.getPosition() == null) {
                continue;
            }
            grouped.computeIfAbsent(candidate.getPosition(), key -> new ArrayList<>()).add(candidate);
        }

        grouped.entrySet().removeIf(entry -> entry.getValue().isEmpty());
        return grouped;
    }

    static Map<String, String> positionLabels() {
        LinkedHashMap<String, String> labels = new LinkedHashMap<>();
        for (Position position : Position.values()) {
            labels.put(position.name(), formatPosition(position));
        }
        return Collections.unmodifiableMap(labels);
    }

    static long countVotesForVoter(EntityManager em, Long userId) {
        if (userId == null) {
            return 0L;
        }

        return em.createQuery(
                "SELECT COUNT(v) FROM Vote v WHERE v.voter.id = :uid",
                Long.class
        ).setParameter("uid", userId).getSingleResult();
    }

    static Map<Long, Long> loadVoteCounts(EntityManager em) {
        Map<Long, Long> voteCounts = new LinkedHashMap<>();
        List<Object[]> rows = em.createQuery(
                "SELECT v.contester.id, COUNT(v) FROM Vote v GROUP BY v.contester.id",
                Object[].class
        ).getResultList();

        for (Object[] row : rows) {
            voteCounts.put((Long) row[0], (Long) row[1]);
        }
        return voteCounts;
    }

    static String formatPosition(Position position) {
        if (position == null) {
            return "Unassigned";
        }

        String[] words = position.name().toLowerCase(Locale.ENGLISH).split("_");
        StringBuilder label = new StringBuilder();
        for (String word : words) {
            if (word.isEmpty()) {
                continue;
            }
            if (label.length() > 0) {
                label.append(' ');
            }
            label.append(Character.toUpperCase(word.charAt(0)));
            if (word.length() > 1) {
                label.append(word.substring(1));
            }
        }
        return label.toString();
    }
}
