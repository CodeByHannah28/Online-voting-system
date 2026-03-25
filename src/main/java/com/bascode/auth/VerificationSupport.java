package com.bascode.auth;

import com.bascode.model.entity.User;
import jakarta.mail.MessagingException;
import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Properties;

final class VerificationSupport {
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final HttpClient HTTP_CLIENT = HttpClient.newHttpClient();
    private static final String DEFAULT_MAILTRAP_API_URL = "https://send.api.mailtrap.io/api/send";
    private static final String DEFAULT_MAILTRAP_FROM_NAME = "Go Voter";
    private static final String DEFAULT_MAILTRAP_CATEGORY = "Verification";

    private VerificationSupport() {
    }

    static String generateVerificationCode() {
        return String.format("%06d", RANDOM.nextInt(900000) + 100000);
    }

    static void rememberUnverifiedEmail(HttpServletRequest req, String email) {
        if (email == null || email.isBlank()) {
            return;
        }

        req.setAttribute("unverifiedEmail", email);
        req.getSession(true).setAttribute("verificationEmail", email);
    }

    static void clearRememberedEmail(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.removeAttribute("verificationEmail");
        }
    }

    static void sendVerificationEmail(ServletContext servletContext, User user, String verificationCode)
            throws MessagingException {
        sendCodeEmail(
                servletContext,
                user,
                verificationCode,
                "Go Voter - Verify your email",
                "Hello " + safeName(user != null ? user.getFirstName() : null) + ",\n\n"
                        + "Welcome to Go Voter. Use the verification code below to activate your account:\n\n"
                        + verificationCode + "\n\n"
                        + "Enter this code on the verification page to confirm your email address.\n\n"
                        + "- Go Voter Team");
    }

    static void sendPasswordResetEmail(ServletContext servletContext, User user, String resetCode)
            throws MessagingException {
        sendCodeEmail(
                servletContext,
                user,
                resetCode,
                "Go Voter - Password Reset Code",
                "Hello " + safeName(user != null ? user.getFirstName() : null) + ",\n\n"
                        + "You requested a password reset. Use the verification code below to reset your password "
                        + "(valid for 1 hour):\n\n"
                        + resetCode + "\n\n"
                        + "Enter this code on the password reset page to set a new password. If you did not request "
                        + "this, you can safely ignore this email.\n\n"
                        + "- Go Voter Team");
    }

    static String deliveryErrorMessage(String fallbackMessage, Throwable failure) {
        String detail = describeDeliveryFailure(failure);
        if (detail == null || detail.isBlank()) {
            return fallbackMessage;
        }
        return fallbackMessage + " " + detail;
    }

    private static void sendCodeEmail(ServletContext servletContext, User user, String code,
                                      String subject, String text) throws MessagingException {
        if (user == null || code == null || code.isBlank()) {
            throw new MessagingException("Missing verification details.");
        }

        Properties mailProps = loadMailProperties(servletContext);
        sendViaMailtrapApi(mailProps, user.getEmail(), subject, text,
                configuredValue(mailProps, "mailtrap.category", DEFAULT_MAILTRAP_CATEGORY));
    }

    private static Properties loadMailProperties(ServletContext servletContext) {
        Properties mailProps = new Properties();
        try (InputStream in = openMailPropertiesStream()) {
            if (in != null) {
                mailProps.load(in);
            } else {
                servletContext.log("email.properties could not be found on the classpath.");
            }
        } catch (Exception ex) {
            servletContext.log("Failed to load email.properties.", ex);
        }

        applyEnvOverride(mailProps, "MAIL_SMTP_HOST", "mail.smtp.host");
        applyEnvOverride(mailProps, "MAIL_SMTP_PORT", "mail.smtp.port");
        applyEnvOverride(mailProps, "MAIL_SMTP_AUTH", "mail.smtp.auth");
        applyEnvOverride(mailProps, "MAIL_SMTP_STARTTLS", "mail.smtp.starttls.enable");
        applyEnvOverride(mailProps, "MAIL_SMTP_STARTTLS_REQUIRED", "mail.smtp.starttls.required");
        applyEnvOverride(mailProps, "MAIL_SMTP_SSL_ENABLE", "mail.smtp.ssl.enable");
        applyEnvOverride(mailProps, "MAIL_SMTP_SSL_PROTOCOLS", "mail.smtp.ssl.protocols");
        applyEnvOverride(mailProps, "MAIL_SMTP_SSL_TRUST", "mail.smtp.ssl.trust");
        applyEnvOverride(mailProps, "MAIL_SMTP_USER", "mail.smtp.user");
        applyEnvOverride(mailProps, "MAIL_SMTP_PASSWORD", "mail.smtp.password");
        applyEnvOverride(mailProps, "MAIL_SMTP_CONNECTION_TIMEOUT", "mail.smtp.connectiontimeout");
        applyEnvOverride(mailProps, "MAIL_SMTP_TIMEOUT", "mail.smtp.timeout");
        applyEnvOverride(mailProps, "MAIL_SMTP_WRITE_TIMEOUT", "mail.smtp.writetimeout");
        applyEnvOverride(mailProps, "MAIL_DEBUG", "mail.debug");
        applyEnvOverride(mailProps, "MAIL_FROM", "mail.from");
        applyEnvOverride(mailProps, "MAILTRAP_API_URL", "mailtrap.api.url");
        applyEnvOverride(mailProps, "MAILTRAP_API_TOKEN", "mailtrap.api.token");
        applyEnvOverride(mailProps, "MAILTRAP_FROM_EMAIL", "mailtrap.from.email");
        applyEnvOverride(mailProps, "MAILTRAP_FROM_NAME", "mailtrap.from.name");
        applyEnvOverride(mailProps, "MAILTRAP_CATEGORY", "mailtrap.category");
        return mailProps;
    }

    private static InputStream openMailPropertiesStream() {
        InputStream in = Thread.currentThread()
                .getContextClassLoader()
                .getResourceAsStream("email.properties");
        if (in == null) {
            in = VerificationSupport.class.getResourceAsStream("/email.properties");
        }
        return in;
    }

    private static void applyEnvOverride(Properties mailProps, String envKey, String propertyName) {
        String envValue = System.getenv(envKey);
        if (envValue != null && !envValue.isBlank()) {
            mailProps.setProperty(propertyName, envValue);
        }
    }

    private static String describeDeliveryFailure(Throwable failure) {
        Throwable cursor = failure;
        while (cursor != null) {
            String message = trimToNull(cursor.getMessage());
            if (message != null) {
                String normalized = message.toLowerCase();
                if (normalized.contains("token is not configured")) {
                    return "The Mailtrap API token is missing.";
                }
                if (normalized.contains("sender email is not configured")) {
                    return "The Mailtrap sender address is missing.";
                }
                if (normalized.contains("status 401") || normalized.contains("status 403")
                        || normalized.contains("token") || normalized.contains("bearer")) {
                    return "Mailtrap rejected the API token.";
                }
                if (normalized.contains("status 422") || normalized.contains("address")
                        || normalized.contains("sender")) {
                    return "Mailtrap rejected the sender email address.";
                }
                if (normalized.contains("status 4") || normalized.contains("status 5")
                        || normalized.contains("rejected")) {
                    return "Mailtrap rejected the email request.";
                }
                if (normalized.contains("could not reach") || normalized.contains("connect")
                        || normalized.contains("timeout")) {
                    return "The app could not reach Mailtrap.";
                }
                if (normalized.contains("url is invalid")) {
                    return "The Mailtrap API URL is invalid.";
                }
            }

            if (cursor instanceof MessagingException messagingException) {
                cursor = messagingException.getNextException();
            } else {
                cursor = cursor.getCause();
            }
        }
        return null;
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }

        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static void sendViaMailtrapApi(Properties props, String toEmail, String subject, String text,
                                           String category) throws MessagingException {
        String apiUrl = configuredValue(props, "mailtrap.api.url", DEFAULT_MAILTRAP_API_URL);
        String apiToken = configuredValue(props, "mailtrap.api.token", null);
        String fromEmail = configuredValue(props, "mailtrap.from.email", null);
        String fromName = configuredValue(props, "mailtrap.from.name", DEFAULT_MAILTRAP_FROM_NAME);
        String resolvedCategory = trimToNull(category);

        if (apiToken == null) {
            throw new MessagingException("Mailtrap API token is not configured on the server.");
        }
        if (fromEmail == null) {
            throw new MessagingException("Mailtrap sender email is not configured on the server.");
        }

        String payload = buildMailtrapPayload(fromEmail, fromName, toEmail, subject, text,
                resolvedCategory != null ? resolvedCategory : DEFAULT_MAILTRAP_CATEGORY);

        HttpRequest request = HttpRequest.newBuilder(URI.create(apiUrl))
                .header("Authorization", "Bearer " + apiToken)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
                .build();

        try {
            HttpResponse<String> response = HTTP_CLIENT.send(request,
                    HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            int status = response.statusCode();
            if (status < 200 || status >= 300) {
                String responseBody = trimToNull(response.body());
                String detail = responseBody != null
                        ? " Response: " + truncate(responseBody, 240)
                        : "";
                throw new MessagingException("Mailtrap API rejected the email request with status " + status + "." + detail);
            }
        } catch (IOException ex) {
            throw new MessagingException("The app could not reach the Mailtrap API.", ex);
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new MessagingException("Mail delivery was interrupted before Mailtrap responded.", ex);
        } catch (IllegalArgumentException ex) {
            throw new MessagingException("Mailtrap API URL is invalid.", ex);
        }
    }

    private static String buildMailtrapPayload(String fromEmail, String fromName, String toEmail,
                                               String subject, String text, String category) {
        return "{"
                + "\"from\":{\"email\":\"" + jsonEscape(fromEmail) + "\",\"name\":\"" + jsonEscape(fromName) + "\"},"
                + "\"to\":[{\"email\":\"" + jsonEscape(toEmail) + "\"}],"
                + "\"subject\":\"" + jsonEscape(subject) + "\","
                + "\"text\":\"" + jsonEscape(text) + "\","
                + "\"category\":\"" + jsonEscape(category) + "\""
                + "}";
    }

    private static String configuredValue(Properties props, String key, String defaultValue) {
        String value = trimToNull(props.getProperty(key));
        return value != null ? value : defaultValue;
    }

    private static String safeName(String value) {
        String trimmed = trimToNull(value);
        return trimmed != null ? trimmed : "there";
    }

    private static String jsonEscape(String value) {
        String input = value != null ? value : "";
        StringBuilder escaped = new StringBuilder(input.length() + 16);
        for (int i = 0; i < input.length(); i++) {
            char ch = input.charAt(i);
            switch (ch) {
                case '\\' -> escaped.append("\\\\");
                case '"' -> escaped.append("\\\"");
                case '\n' -> escaped.append("\\n");
                case '\r' -> escaped.append("\\r");
                case '\t' -> escaped.append("\\t");
                default -> {
                    if (ch < 0x20) {
                        escaped.append(String.format("\\u%04x", (int) ch));
                    } else {
                        escaped.append(ch);
                    }
                }
            }
        }
        return escaped.toString();
    }

    private static String truncate(String value, int maxLength) {
        if (value == null || value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, Math.max(0, maxLength - 3)) + "...";
    }
}
