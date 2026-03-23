package com.bascode.controller;

import com.bascode.model.enums.ContesterStatus;
import com.bascode.service.ContesterService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/admin/*")
public class AdminContesterServlet extends HttpServlet {
    private EntityManagerFactory emf = Persistence.createEntityManagerFactory("VotingPU");

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            response.sendRedirect("index.jsp?error=InvalidPath");
            return;
        }

        String[] parts = pathInfo.split("/");
        if (parts.length < 3) {
            response.sendRedirect("index.jsp?error=InvalidRequest");
            return;
        }

        String action = parts[1]; // approve-contester or deny-contester
        Long contesterId = null;
        try {
            contesterId = Long.parseLong(parts[2]);
        } catch (NumberFormatException nfe) {
            response.sendRedirect("index.jsp?error=InvalidId");
            return;
        }

        ContesterStatus newStatus = null;
        if ("approve-contester".equals(action)) {
            newStatus = ContesterStatus.APPROVED;
        } else if ("deny-contester".equals(action)) {
            newStatus = ContesterStatus.DENIED;
        } else {
            response.sendRedirect("index.jsp?error=InvalidAction");
            return;
        }

        EntityManager em = emf.createEntityManager();
        ContesterService service = new ContesterService();
        String result = service.handleStatusUpdate(em, contesterId, newStatus);
        em.close();

        String encoded = URLEncoder.encode(result, StandardCharsets.UTF_8.toString());
        response.sendRedirect("index.jsp?msg=" + encoded);
    }
}