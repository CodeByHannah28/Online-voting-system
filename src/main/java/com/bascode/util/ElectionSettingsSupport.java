package com.bascode.util;

import com.bascode.model.entity.ElectionSetting;
import jakarta.persistence.EntityManager;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public final class ElectionSettingsSupport {

    public static final long PRIMARY_KEY = 1L;

    private static final DateTimeFormatter DISPLAY_FORMATTER =
            DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a", Locale.ENGLISH);
    private static final DateTimeFormatter INPUT_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm", Locale.ENGLISH);

    private ElectionSettingsSupport() {
    }

    public static ElectionSetting load(EntityManager em) {
        if (em == null) {
            return null;
        }
        return em.find(ElectionSetting.class, PRIMARY_KEY);
    }

    public static ElectionSetting loadOrCreate(EntityManager em) {
        ElectionSetting setting = load(em);
        if (setting != null) {
            return setting;
        }

        setting = new ElectionSetting();
        setting.setId(PRIMARY_KEY);
        em.persist(setting);
        return setting;
    }

    public static boolean isVotingClosed(ElectionSetting setting) {
        if (setting == null || setting.getVotingDeadline() == null) {
            return false;
        }
        return LocalDateTime.now().isAfter(setting.getVotingDeadline());
    }

    public static String formatDisplay(LocalDateTime value) {
        if (value == null) {
            return "No voting deadline is scheduled.";
        }
        return value.format(DISPLAY_FORMATTER);
    }

    public static String formatInput(LocalDateTime value) {
        if (value == null) {
            return "";
        }
        return value.format(INPUT_FORMATTER);
    }
}
