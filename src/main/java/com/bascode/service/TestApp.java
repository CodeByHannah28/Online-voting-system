package com.bascode.service;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import com.bascode.model.enums.Position;

public class TestApp {
    public static void main(String[] args) {
        EntityManagerFactory emf = Persistence.createEntityManagerFactory("VotingPU");
        EntityManager em = emf.createEntityManager();
        
        ContesterService service = new ContesterService();
        
        // Use a User ID that already exists in your 'users' table
        boolean success = service.registerContester(em, 1L, Position.PRESIDENT);
        
        if(success) {
            System.out.println("Registration successful! Check MySQL now.");
        } else {
            System.out.println("Registration failed. Check if User ID 1 exists.");
        }
        
        em.close();
        emf.close();
    }
}
