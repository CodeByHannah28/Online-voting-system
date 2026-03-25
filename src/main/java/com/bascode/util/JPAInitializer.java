package com.bascode.util;

import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;


@WebListener
public class JPAInitializer implements ServletContextListener {
    private static EntityManagerFactory emf;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            // Try to initialize the persistence unit. If this fails (missing DB, wrong
            // credentials, etc.) we catch the exception and allow the webapp to start
            // so other non-database parts can be used for development/debugging.
            emf = Persistence.createEntityManagerFactory("VotingPU", RuntimeConfigSupport.jpaOverrides());
            sce.getServletContext().setAttribute("emf", emf);
        } catch (Exception e) {
            // Log the problem on the servlet context and continue without EMF.
            // This prevents Tomcat from failing to deploy the whole webapp when the
            // database is not reachable.
            if (sce != null && sce.getServletContext() != null) {
                sce.getServletContext().log(
                        "[JPAInitializer] Persistence unit initialization failed; continuing without EMF.\n" +
                                "Cause: " + e.getMessage(),
                        e);
                sce.getServletContext().setAttribute("emf", null);
            }
            emf = null;
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (emf != null && emf.isOpen()) {
            emf.close(); 
        }
    }
}
