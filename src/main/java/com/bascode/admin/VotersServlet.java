package com.bascode.admin;

import com.bascode.model.entity.User;
import com.bascode.model.enums.Role;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.TypedQuery;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Collections;
import java.util.List;

public class VotersServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");  
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        EntityManagerFactory factory = emf();
        String search = trimToNull(req.getParameter("search"));
        int requestedPage = parsePage(req.getParameter("page"));
        if (factory == null) {
            forwardVotersPage(req, resp, Collections.emptyList(), search, requestedPage, 1, 0L,
                    "We couldn't load voter records right now. Please try again shortly.");
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            StringBuilder whereClause = new StringBuilder(" WHERE (u.role = :role OR u.role = :role2)");
            if (search != null) {
                whereClause.append(" AND (LOWER(u.firstName) LIKE :s OR LOWER(u.lastName) LIKE :s OR LOWER(u.email) LIKE :s)");
            }
            TypedQuery<Long> countQuery = em.createQuery("SELECT COUNT(u) FROM User u" + whereClause, Long.class);
            countQuery.setParameter("role", Role.VOTER);
            countQuery.setParameter("role2", Role.CONTESTER);
            if (search != null) {
                countQuery.setParameter("s", "%" + search.toLowerCase() + "%");
            }
            Long totalResults = countQuery.getSingleResult();

            int totalPages = totalResults == null || totalResults == 0L
                    ? 1
                    : (int) Math.ceil(totalResults / (double) PAGE_SIZE);
            int currentPage = Math.max(1, Math.min(requestedPage, totalPages));

            TypedQuery<User> q = em.createQuery(
                    "SELECT u FROM User u" + whereClause + " ORDER BY u.id DESC",
                    User.class);
            q.setParameter("role", Role.VOTER);
            q.setParameter("role2", Role.CONTESTER);
            if (search != null) {
                q.setParameter("s", "%" + search.toLowerCase() + "%");
            }
            q.setFirstResult((currentPage - 1) * PAGE_SIZE);
            q.setMaxResults(PAGE_SIZE);

            List<User> voters = q.getResultList();
            forwardVotersPage(req, resp, voters, search, currentPage, totalPages, totalResults, null);
        } catch (RuntimeException ex) {
            getServletContext().log("[VotersServlet] Unable to load voter records.", ex);
            forwardVotersPage(req, resp, Collections.emptyList(), search, requestedPage, 1, 0L,
                    "We couldn't load voter records right now. Please refresh or try again shortly.");
        } finally {
            em.close();
        }
    }

    private void forwardVotersPage(HttpServletRequest req, HttpServletResponse resp, List<User> voters,
                                   String search, int currentPage, int totalPages, Long totalResults,
                                   String pageError) throws ServletException, IOException {
        long safeTotalResults = totalResults != null ? totalResults : 0L;
        int safeCurrentPage = Math.max(1, currentPage);
        req.setAttribute("voters", voters != null ? voters : Collections.emptyList());
        req.setAttribute("search", search);
        req.setAttribute("currentPage", safeCurrentPage);
        req.setAttribute("totalPages", Math.max(1, totalPages));
        req.setAttribute("totalResults", safeTotalResults);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("showingFrom", safeTotalResults == 0L ? 0L : ((long) (safeCurrentPage - 1) * PAGE_SIZE) + 1L);
        req.setAttribute("showingTo", Math.min(safeTotalResults, (long) safeCurrentPage * PAGE_SIZE));
        req.setAttribute("pageError", pageError);
        req.getRequestDispatcher("/admin/voters.jsp").forward(req, resp);
    }

    private int parsePage(String pageValue) {
        if (pageValue == null || pageValue.isBlank()) {
            return 1;
        }

        try {
            return Math.max(1, Integer.parseInt(pageValue));
        } catch (NumberFormatException ex) {
            return 1;
        }
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }

        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
