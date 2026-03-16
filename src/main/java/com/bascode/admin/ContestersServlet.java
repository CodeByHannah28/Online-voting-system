package com.bascode.admin;

import com.bascode.model.entity.Contester;
import com.bascode.model.enums.ContesterStatus;

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

public class ContestersServlet extends HttpServlet {

    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");  
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        EntityManagerFactory factory = emf();
        if (factory == null) {
            req.setAttribute("contesters", Collections.emptyList());
            req.getRequestDispatcher("/admin/contesters.jsp").forward(req, resp);
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            String search = req.getParameter("search");
            String statusFilter = req.getParameter("status");
            
            StringBuilder jpql = new StringBuilder("SELECT c FROM Contester c WHERE 1=1");
            if (search != null && !search.trim().isEmpty()) {
                jpql.append(" AND (LOWER(c.user.firstName) LIKE :s OR LOWER(c.user.lastName) LIKE :s OR LOWER(c.user.email) LIKE :s)");
            }
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                jpql.append(" AND c.status = :status");
            }
            
            TypedQuery<Contester> q = em.createQuery(jpql.toString(), Contester.class);
            if (search != null && !search.trim().isEmpty()) {
                q.setParameter("s", "%" + search.toLowerCase() + "%");
            }
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                q.setParameter("status", com.bascode.model.enums.ContesterStatus.valueOf(statusFilter));
            }
            
            List<Contester> contesters = q.getResultList();
            req.setAttribute("contesters", contesters);
            req.setAttribute("search", search);
            req.setAttribute("statusFilter", statusFilter);
            req.getRequestDispatcher("/admin/contesters.jsp").forward(req, resp);
        } finally {
            em.close();
        }
    }
}