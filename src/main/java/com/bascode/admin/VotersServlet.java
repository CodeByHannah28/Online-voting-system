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

    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");  
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        EntityManagerFactory factory = emf();
        if (factory == null) {
            req.setAttribute("voters", Collections.emptyList());
            req.getRequestDispatcher("/admin/voters.jsp").forward(req, resp);
            return;
        }

        EntityManager em = factory.createEntityManager();
        try {
            String search = req.getParameter("search");
            TypedQuery<User> q;
            if (search != null && !search.trim().isEmpty()) {
                q = em.createQuery("SELECT u FROM User u WHERE u.role = :role AND (LOWER(u.firstName) LIKE :s OR LOWER(u.lastName) LIKE :s OR LOWER(u.email) LIKE :s)", User.class);
                q.setParameter("s", "%" + search.toLowerCase() + "%");
            } else {
                q = em.createQuery("SELECT u FROM User u WHERE u.role = :role", User.class);
            }
            q.setParameter("role", Role.VOTER);
            List<User> voters = q.getResultList();
            req.setAttribute("voters", voters);
            req.setAttribute("search", search);
            req.getRequestDispatcher("/admin/voters.jsp").forward(req, resp);   
        } finally {
            em.close();
        }
    }
}