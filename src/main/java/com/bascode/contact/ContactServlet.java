package com.bascode.contact;

import com.bascode.model.entity.ContactMessage;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.regex.Pattern;

public class ContactServlet extends HttpServlet {

    private static final Pattern BASIC_EMAIL =
            Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");

    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/contact.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String department = trimToNull(req.getParameter("department"));
        String organization = trimToNull(req.getParameter("organization"));
        String name = trimToNull(req.getParameter("name"));
        String email = trimToNull(req.getParameter("email"));
        String message = trimToNull(req.getParameter("message"));

        req.setAttribute("department", department);
        req.setAttribute("organization", organization);
        req.setAttribute("name", name);
        req.setAttribute("email", email);
        req.setAttribute("messageValue", message);

        if (department == null || name == null || email == null || message == null) {
            req.setAttribute("error", "Please complete the department, name, email, and message fields.");
            req.getRequestDispatcher("/contact.jsp").forward(req, resp);
            return;
        }

        if (!BASIC_EMAIL.matcher(email).matches()) {
            req.setAttribute("error", "Please provide a valid email address so the team can reach you.");
            req.getRequestDispatcher("/contact.jsp").forward(req, resp);
            return;
        }

        if (message.length() < 12) {
            req.setAttribute("error", "Please share a little more detail so the team can respond properly.");
            req.getRequestDispatcher("/contact.jsp").forward(req, resp);
            return;
        }

        EntityManagerFactory factory = emf();
        if (factory == null) {
            req.setAttribute("error", "The contact desk is temporarily unavailable. Please try again shortly.");
            req.getRequestDispatcher("/contact.jsp").forward(req, resp);
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            em.getTransaction().begin();

            ContactMessage contactMessage = new ContactMessage();
            contactMessage.setDepartment(department);
            contactMessage.setOrganization(organization);
            contactMessage.setName(name);
            contactMessage.setEmail(email);
            contactMessage.setMessage(message);
            em.persist(contactMessage);

            em.getTransaction().commit();

            req.setAttribute("success",
                    "Thank you, " + name + ". Your message has been recorded as request #" + contactMessage.getId()
                            + " and the team can now follow up properly.");
            req.setAttribute("department", null);
            req.setAttribute("organization", null);
            req.setAttribute("name", null);
            req.setAttribute("email", null);
            req.setAttribute("messageValue", null);
        } catch (RuntimeException ex) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            getServletContext().log("[ContactServlet] Unable to save contact message.", ex);
            req.setAttribute("error", "We couldn't save your message right now. Please try again in a moment.");
        } finally {
            em.close();
        }

        req.getRequestDispatcher("/contact.jsp").forward(req, resp);
    }

    private static String trimToNull(String value) {
        if (value == null) {
            return null;
        }

        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
