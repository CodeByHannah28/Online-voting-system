package com.bascode.admin;

import com.bascode.model.entity.Contester;
import com.bascode.model.enums.ContesterStatus;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class PendingApprovalsServlet extends HttpServlet {
    private EntityManagerFactory emf() {
        return (EntityManagerFactory) getServletContext().getAttribute("emf");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        EntityManager em = emf().createEntityManager();
        try {
            TypedQuery<Contester> q = em.createQuery("SELECT c FROM Contester c WHERE c.status = :s", Contester.class);
            q.setParameter("s", ContesterStatus.PENDING);
            List<Contester> pending = q.getResultList();
            req.setAttribute("pendingContesters", pending);
            req.getRequestDispatcher("/admin/pending-approvals.jsp").forward(req, resp);
        } finally {
            em.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String idStr = req.getParameter("id");
        if (idStr == null || action == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Long id = Long.valueOf(idStr);
        EntityManager em = emf().createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Contester c = em.find(Contester.class, id);
            if (c == null) {
                tx.rollback();
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            if ("approve".equals(action)) {
                c.setStatus(ContesterStatus.APPROVED);
            } else if ("deny".equals(action)) {
                c.setStatus(ContesterStatus.DENIED);
            } else {
                tx.rollback();
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            em.merge(c);
            tx.commit();
        } catch (RuntimeException ex) {
            if (tx.isActive()) tx.rollback();
            throw ex;
        } finally {
            em.close();
        }
        resp.sendRedirect(req.getContextPath() + "/pending-approvals");
    }
}
