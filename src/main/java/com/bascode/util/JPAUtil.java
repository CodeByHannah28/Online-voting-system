package com.bascode.util;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import jakarta.servlet.ServletContext;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class JPAUtil {
    private static EntityManagerFactory emf;

    public static EntityManager getEntityManager() {
        if (emf == null) {
            synchronized (JPAUtil.class) {
                if (emf == null) {
                    emf = Persistence.createEntityManagerFactory("VotingPU", RuntimeConfigSupport.jpaOverrides());
                }
            }
        }
        return emf.createEntityManager();
    }

    public static void closeEntityManagerFactory() {
        if (emf != null && emf.isOpen()) {
            emf.close();
        }
    }
}

