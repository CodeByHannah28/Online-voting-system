package com.bascode.util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public final class RuntimeConfigSupport {

    private static final Properties DATABASE_PROPERTIES = loadProperties("database.properties");

    private RuntimeConfigSupport() {
    }

    public static Map<String, Object> jpaOverrides() {
        Map<String, Object> overrides = new HashMap<>();

        putIfPresent(overrides, "jakarta.persistence.jdbc.driver",
                resolveValue("voting.db.driver", "VOTING_DB_DRIVER", DATABASE_PROPERTIES, "db.driver"));
        putIfPresent(overrides, "jakarta.persistence.jdbc.url",
                resolveValue("voting.db.url", "VOTING_DB_URL", DATABASE_PROPERTIES, "db.url"));
        putIfPresent(overrides, "jakarta.persistence.jdbc.user",
                resolveValue("voting.db.user", "VOTING_DB_USER", DATABASE_PROPERTIES, "db.user"));
        putIfPresent(overrides, "jakarta.persistence.jdbc.password",
                resolveValue("voting.db.password", "VOTING_DB_PASSWORD", DATABASE_PROPERTIES, "db.password"));
        putIfPresent(overrides, "hibernate.hbm2ddl.auto",
                resolveValue("voting.db.ddlAuto", "VOTING_DB_DDL_AUTO", DATABASE_PROPERTIES, "db.ddlAuto"));
        putIfPresent(overrides, "hibernate.show_sql",
                resolveValue("voting.db.showSql", "VOTING_DB_SHOW_SQL", DATABASE_PROPERTIES, "db.showSql"));
        putIfPresent(overrides, "hibernate.format_sql",
                resolveValue("voting.db.formatSql", "VOTING_DB_FORMAT_SQL", DATABASE_PROPERTIES, "db.formatSql"));

        return Collections.unmodifiableMap(overrides);
    }

    private static void putIfPresent(Map<String, Object> overrides, String key, String value) {
        String trimmed = trimToNull(value);
        if (trimmed != null) {
            overrides.put(key, trimmed);
        }
    }

    private static String resolveValue(String systemPropertyKey, String envKey,
                                       Properties properties, String propertyKey) {
        String value = trimToNull(System.getProperty(systemPropertyKey));
        if (value != null) {
            return value;
        }

        value = trimToNull(System.getenv(envKey));
        if (value != null) {
            return value;
        }

        if (properties == null) {
            return null;
        }

        return trimToNull(properties.getProperty(propertyKey));
    }

    private static Properties loadProperties(String resourceName) {
        try (InputStream input = RuntimeConfigSupport.class.getClassLoader().getResourceAsStream(resourceName)) {
            if (input == null) {
                return new Properties();
            }

            Properties properties = new Properties();
            properties.load(input);
            return properties;
        } catch (IOException ex) {
            throw new IllegalStateException("Unable to load " + resourceName + ".", ex);
        }
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }

        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
