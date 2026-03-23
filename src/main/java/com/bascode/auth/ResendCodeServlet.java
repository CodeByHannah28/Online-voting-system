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

@WebServlet(name = "ResendCodeServlet", urlPatterns = {"/resend-code"})
public class ResendCodeServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            email = (String) req.getSession().getAttribute("verificationEmail");
        }
        if (email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Could not detect your email. Please try logging in again.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            User user = em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
                    .setParameter("email", email)
                    .getSingleResult();

            if (user.isEmailVerified()) {
                req.setAttribute("message", "This email is already verified. Please log in.");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
                return;
            }

            // Generate new code
            String verificationCode = String.format("%06d", new Random().nextInt(900000) + 100000);
            em.getTransaction().begin();
            user.setVerificationCode(verificationCode);
            em.merge(user);
            em.getTransaction().commit();

            // DEV helper
            try {
                String devShow = System.getenv("DEV_SHOW_CODES");
                if (devShow != null && devShow.equalsIgnoreCase("true")) {
                    getServletContext().log("[DEV] Resent Verification code for " + user.getEmail() + " is: " + verificationCode);
                }
            } catch (Exception ex) {}

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
                    message.setSubject("Go Voter - Verification Code Resent");
                    String body = "Hello " + user.getFirstName() + ",\n\n" +
                            "Here is your new Verification Code as requested:\n\n" +
                            verificationCode + "\n\n" +
                            "Enter this code on the verification page to confirm your account.\n\n" +
                            "\u2014 Go Voter Team";
                    message.setText(body);

                    Transport.send(message);
                    req.setAttribute("message", "A new verification code has been sent to your email.");
                    req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
                    return;
                } catch (MessagingException mex) {
                    req.setAttribute("error", "Email Failed: " + mex.getMessage() + ". Please check your App Password.");
                    req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
                    return;
                }
            }
            req.setAttribute("error", "Email could not be resent due to server configuration.");
            req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
        } catch (NoResultException e) {
            req.setAttribute("error", "User not found.");
            req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            req.setAttribute("error", "An error occurred. Please try again.");
            req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
    }
}
