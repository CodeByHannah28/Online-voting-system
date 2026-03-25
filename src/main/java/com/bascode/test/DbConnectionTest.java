package com.bascode.test;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

/**
 * A simple utility to verify that the JPA configuration and database connection are working.
 * This can be run as a Java Application in Eclipse.
 */
public class DbConnectionTest {

    public static void main(String[] args) {
        System.out.println("Starting Database Connection Test...");
        
        EntityManagerFactory emf = null;
        EntityManager em = null;
        
        try {
            // Create EntityManagerFactory using the name defined in persistence.xml
            emf = Persistence.createEntityManagerFactory("VotingPU");
            em = emf.createEntityManager();
            
            System.out.println("Successfully connected to the database!");
            
            // Try a simple query
            Object result = em.createNativeQuery("SELECT 1").getSingleResult();
            System.out.println("Execution test (SELECT 1): " + result);
            
            System.out.println("JPA configuration is VALID.");
            
        } catch (Exception e) {
            System.err.println("FAILED to connect to the database.");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
            if (emf != null && emf.isOpen()) {
                emf.close();
            }
        }
    }
}
