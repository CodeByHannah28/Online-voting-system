package com.bascode.controller;

import com.bascode.model.enums.Position;
import com.bascode.service.ContesterService;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/register-contester")
public class ContesterRegistrationServlet extends HttpServlet {
    private EntityManagerFactory emf = Persistence.createEntityManagerFactory("online-voting-system");

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) {
            response.sendRedirect("index.jsp?error=LoginRequired");
            return;
        }

        String positionStr = request.getParameter("position");
        if (positionStr == null || positionStr.isEmpty()) {
            response.sendRedirect("index.jsp?error=PositionRequired");
            return;
        }

        Position position = Position.valueOf(positionStr.toUpperCase());

        EntityManager em = emf.createEntityManager();
        ContesterService service = new ContesterService();
        boolean success = service.registerContester(em, userId, position);

        em.close();

        if (success) {
            response.sendRedirect("index.jsp?success=ContesterRegistered");
        } else {
            response.sendRedirect("index.jsp?error=RegistrationFailed");
        }
    }
}
