package com.bascode.auth;

import com.bascode.model.entity.User;
import com.bascode.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.Random;

@WebServlet(name = "ResendVerificationServlet", urlPatterns = {"/resend-verification"})
public class ResendVerificationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Please provide your email address.");
            req.getRequestDispatcher("/resend-verification.jsp").forward(req, resp);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            User user = em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
                    .setParameter("email", email)
                    .getSingleResult();

            em.getTransaction().begin();
            // generate a short 6-digit verification code
            String verificationCode = String.format("%06d", new Random().nextInt(900000) + 100000);
            user.setVerificationCode(verificationCode);
            em.merge(user);
            em.getTransaction().commit();

            // DEV helper: log code when DEV_SHOW_CODES is true
            try {
                String devShow = System.getenv("DEV_SHOW_CODES");
                if (devShow != null && devShow.equalsIgnoreCase("true")) {
                    getServletContext().log("[DEV] Resent verification code for " + user.getEmail() + " is: " + verificationCode);
                }
            } catch (Exception ex) {
                // ignore logging failures
            }

            // Send Email
            Properties mailProps = new Properties();
            try {
                InputStream in = Thread.currentThread().getContextClassLoader().getResourceAsStream("email.properties");
                if (in == null) {
                    in = getClass().getResourceAsStream("/email.properties");
                }
                if (in != null) {
                    mailProps.load(in);
                    in.close();
                } else {
                    getServletContext().log("CRITICAL ERROR: email.properties could not be found anywhere on Classpath!");
                }
            } catch (Exception e) {}

            // Environment overrides
            String envHost = System.getenv("MAIL_SMTP_HOST");
            if (envHost != null && !envHost.isBlank()) mailProps.setProperty("mail.smtp.host", envHost);
            String envPort = System.getenv("MAIL_SMTP_PORT");
            if (envPort != null && !envPort.isBlank()) mailProps.setProperty("mail.smtp.port", envPort);
            String envAuth = System.getenv("MAIL_SMTP_AUTH");
            if (envAuth != null && !envAuth.isBlank()) mailProps.setProperty("mail.smtp.auth", envAuth);
            String envStarttls = System.getenv("MAIL_SMTP_STARTTLS");
            if (envStarttls != null && !envStarttls.isBlank()) mailProps.setProperty("mail.smtp.starttls.enable", envStarttls);
            String envUser = System.getenv("MAIL_SMTP_USER");
            if (envUser != null && !envUser.isBlank()) mailProps.setProperty("mail.smtp.user", envUser);
            String envPass = System.getenv("MAIL_SMTP_PASSWORD");
            if (envPass != null && !envPass.isBlank()) mailProps.setProperty("mail.smtp.password", envPass);
            String envFrom = System.getenv("MAIL_FROM");
            if (envFrom != null && !envFrom.isBlank()) mailProps.setProperty("mail.from", envFrom);

            String smtpHost = mailProps.getProperty("mail.smtp.host");
            if (smtpHost != null && !smtpHost.trim().isEmpty()) {
                Properties props = new Properties();
                props.put("mail.smtp.host", mailProps.getProperty("mail.smtp.host"));
                props.put("mail.smtp.port", mailProps.getProperty("mail.smtp.port", "587"));
                props.put("mail.smtp.auth", mailProps.getProperty("mail.smtp.auth", "true"));
                props.put("mail.smtp.starttls.enable", mailProps.getProperty("mail.smtp.starttls.enable", "true"));

                final String userProp = mailProps.getProperty("mail.smtp.user");
                final String passProp = mailProps.getProperty("mail.smtp.password");

                Session session = null;
                if ("true".equalsIgnoreCase(props.getProperty("mail.smtp.auth")) && userProp != null && passProp != null) {
                    session = Session.getInstance(props, new Authenticator() {
                        @Override
                        protected PasswordAuthentication getPasswordAuthentication() {
                            return new PasswordAuthentication(userProp, passProp);
                        }
                    });
                } else {
                    session = Session.getInstance(props);
                }

                try {
                    String from = mailProps.getProperty("mail.from", userProp != null ? userProp : "no-reply@localhost");

                    Message message = new MimeMessage(session);
                    message.setFrom(new InternetAddress(from));
                    message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(user.getEmail()));
                    message.setSubject("Go Voter - Verify your email");
                    String body = "Hello " + user.getFirstName() + ",\n\n" +
                            "You requested a new verification code for your Go Voter account. Use the code below to verify your email address:\n\n" +
                            verificationCode + "\n\n" +
                            "Enter this code on the verification page to confirm your account. If you did not request this email, please ignore it.\n\n" +
                            "— Go Voter Team";
                    message.setText(body);

                    Transport.send(message);
                } catch (MessagingException mex) {
                    req.setAttribute("error", "Email Failed: " + mex.getMessage() + ". Please check your App Password.");
                    req.getRequestDispatcher("/resend-verification.jsp").forward(req, resp);
                    return;
                }
            } else {
                req.setAttribute("error", "CRITICAL ERROR: email settings not loaded! smtpHost is completely missing. Your Java app cannot send emails.");
                req.getRequestDispatcher("/resend-verification.jsp").forward(req, resp);
                return;
            }

            // Do not reveal whether email exists; show a generic confirmation
            req.setAttribute("message", "If an account with that email exists, a verification email has been sent.");
            req.getRequestDispatcher("/resend-verification.jsp").forward(req, resp);

        } catch (NoResultException nre) {
            // Don't reveal whether email exists
            req.setAttribute("message", "If an account with that email exists, a verification email has been sent.");
            req.getRequestDispatcher("/resend-verification.jsp").forward(req, resp);
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            getServletContext().log("Resend verification failed", e);
            req.setAttribute("error", "An error occurred. Please try again later.");
            req.getRequestDispatcher("/resend-verification.jsp").forward(req, resp);
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }
}
