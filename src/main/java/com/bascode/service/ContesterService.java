package com.bascode.service;

import com.bascode.model.entity.Contester;
import com.bascode.model.enums.ContesterStatus;
import com.bascode.model.enums.Position;
import com.bascode.model.entity.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;


public class ContesterService {

	/**
     * Task: Contester registration
     * Saves a new contester to the database with a default PENDING status.
     */
    public boolean registerContester(EntityManager em, Long userId, Position position) {
        try {
            // Find the User entity to link to the Contester
            com.bascode.model.entity.User user = em.find(com.bascode.model.entity.User.class, userId);
            
            if (user == null) {
                return false;
            }

            Contester newContester = new Contester();
            newContester.setUser(user); // Mapping the @OneToOne relationship I saw in your code
            newContester.setPosition(position);
            newContester.setStatus(ContesterStatus.PENDING); // Rule: Must start as PENDING

            em.getTransaction().begin();
            em.persist(newContester);
            em.getTransaction().commit();
            
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            return false;
        }
    }
	
	
    public String handleStatusUpdate(EntityManager em, Long contesterId, ContesterStatus newStatus) {
        Contester contester = em.find(Contester.class, contesterId);
        
        if (contester == null) {
            return "Error: Contester not found.";
        }

        // Business Rule: Check limit only when trying to APPROVE
        if (newStatus == ContesterStatus.APPROVED) {
            String jpql = "SELECT COUNT(c) FROM Contester c WHERE c.position = :pos AND c.status = :status";
            TypedQuery<Long> query = em.createQuery(jpql, Long.class);
            query.setParameter("pos", contester.getPosition());
            query.setParameter("status", ContesterStatus.APPROVED);
            
            Long approvedCount = query.getSingleResult();
            
            // Optimize: account if this contester was not approved before
            long potentialCount = approvedCount + (contester.getStatus() != ContesterStatus.APPROVED ? 1 : 0);
            if (potentialCount > 3) {
                return "Denied: The position " + contester.getPosition() + " would exceed max 3 approved contesters.";
            }
        }

        // Apply the status change
        try {
            em.getTransaction().begin();
            contester.setStatus(newStatus);
            em.merge(contester);
            em.getTransaction().commit();
            return "Success: Contester status updated to " + newStatus;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            return "Error: Database update failed.";
        }
    }
}
