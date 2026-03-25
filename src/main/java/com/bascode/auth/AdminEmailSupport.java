package com.bascode.auth;

import com.bascode.model.entity.User;
import com.bascode.model.enums.Role;

import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.Locale;
import java.util.Properties;
import java.util.Set;

public final class AdminEmailSupport {
    private static final String RESOURCE_NAME = "admin.properties";
    private static final String ADMIN_EMAILS_KEY = "admin.emails";
    private static final Set<String> ADMIN_EMAILS = loadAdminEmails();

    private AdminEmailSupport() {
    }

    public static Role resolveRole(String email, Role requestedRole) {
        return isConfiguredAdminEmail(email) ? Role.ADMIN : requestedRole;
    }

    public static boolean shouldPromoteToAdmin(User user) {
        return user != null
                && isConfiguredAdminEmail(user.getEmail())
                && !Role.ADMIN.equals(user.getRole());
    }

    private static boolean isConfiguredAdminEmail(String email) {
        String normalizedEmail = normalizeEmail(email);
        return normalizedEmail != null && ADMIN_EMAILS.contains(normalizedEmail);
    }

    private static Set<String> loadAdminEmails() {
        Properties properties = new Properties();
        try (InputStream input = AdminEmailSupport.class.getClassLoader().getResourceAsStream(RESOURCE_NAME)) {
            if (input == null) {
                return Collections.emptySet();
            }

            properties.load(input);
            String configuredEmails = properties.getProperty(ADMIN_EMAILS_KEY, "");
            if (configuredEmails.isBlank()) {
                return Collections.emptySet();
            }

            Set<String> emails = new LinkedHashSet<>();
            Arrays.stream(configuredEmails.split(","))
                    .map(AdminEmailSupport::normalizeEmail)
                    .filter(value -> value != null && !value.isEmpty())
                    .forEach(emails::add);
            return Collections.unmodifiableSet(emails);
        } catch (IOException ex) {
            throw new IllegalStateException("Unable to load configured admin emails.", ex);
        }
    }

    private static String normalizeEmail(String email) {
        if (email == null) {
            return null;
        }

        String normalized = email.trim().toLowerCase(Locale.ROOT);
        return normalized.isEmpty() ? null : normalized;
    }
}
