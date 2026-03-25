package com.bascode.profile;

import com.bascode.model.entity.User;
import com.bascode.model.enums.Role;
import com.bascode.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;


public class ProfileServlet extends HttpServlet {
    private static final String PROFILE_VIEW = "/profile.jsp";
    private static final String ADMIN_PROFILE_VIEW = "/admin/profile.jsp";

    /** GET: Load current user and forward to profile.jsp */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Long userId = getUserId(session);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        User user = null;
        try {
            user = em.find(User.class, userId);
            if (user == null) {
                clearSession(session);
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
                return;
            }
            refreshSession(session, user);
        } catch (RuntimeException ex) {
            getServletContext().log("Failed to load profile for user id " + userId, ex);
            user = getSessionUser(session);
            if (user == null) {
                clearSession(session);
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
                return;
            }
            req.setAttribute("loadError",
                    "We couldn't refresh your latest profile details right now. You're seeing your current session info.");
        } finally {
            em.close();
        }
        forwardProfile(req, resp, user);
    }

    /** POST: dispatch to sub-actions via hidden "action" field */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Long userId = getUserId(session);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "update":   handleUpdate(req, resp, userId);   break;
            case "password": handlePassword(req, resp, userId); break;
            case "delete":   handleDelete(req, resp, userId, session); break;
            default:
                resp.sendRedirect(req.getContextPath() + "/profile");
        }
    }

    // ── Update first name, last name, state, country ─────────────────────────
    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, Long userId)
            throws ServletException, IOException {

        String firstName = req.getParameter("firstName");
        String lastName  = req.getParameter("lastName");
        String state     = req.getParameter("state");
        String country   = req.getParameter("country");

        if (firstName == null || firstName.trim().isEmpty() ||
            lastName  == null || lastName.trim().isEmpty()) {
            req.setAttribute("updateError", "First name and last name are required.");
            forwardWithSessionUser(req, resp);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        User user = null;
        try {
            em.getTransaction().begin();
            user = em.find(User.class, userId);
            if (user == null) {
                if (em.getTransaction().isActive()) em.getTransaction().rollback();
                req.setAttribute("updateError", "Your account could not be found.");
                forwardWithSessionUser(req, resp);
                return;
            }
            user.setFirstName(firstName.trim());
            user.setLastName(lastName.trim());
            user.setState(state != null ? state.trim() : null);
            user.setCountry(country != null ? country.trim() : null);
            em.getTransaction().commit();

            refreshSession(req.getSession(), user);
            req.setAttribute("updateSuccess", "Profile updated successfully.");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            getServletContext().log("Failed to update profile for user id " + userId, e);
            req.setAttribute("updateError", "We couldn't save your profile changes right now. Please try again.");
            user = getSessionUser(req.getSession(false));
        } finally {
            em.close();
        }
        forwardProfile(req, resp, user != null ? user : getSessionUser(req.getSession(false)));
    }

    // ── Change password ──────────────────────────────────────────────────────
    private void handlePassword(HttpServletRequest req, HttpServletResponse resp, Long userId)
            throws ServletException, IOException {

        String current  = req.getParameter("currentPassword");
        String newPwd   = req.getParameter("newPassword");
        String confirm  = req.getParameter("confirmPassword");

        if (current == null || newPwd == null || confirm == null ||
            current.isEmpty() || newPwd.isEmpty() || confirm.isEmpty()) {
            req.setAttribute("passwordError", "All password fields are required.");
            forwardWithSessionUser(req, resp);
            return;
        }
        if (!newPwd.equals(confirm)) {
            req.setAttribute("passwordError", "New passwords do not match.");
            forwardWithSessionUser(req, resp);
            return;
        }
        if (newPwd.length() < 8) {
            req.setAttribute("passwordError", "New password must be at least 8 characters.");
            forwardWithSessionUser(req, resp);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        User user = null;
        try {
            user = em.find(User.class, userId);
            if (user == null) {
                req.setAttribute("passwordError", "Your account could not be found.");
                forwardWithSessionUser(req, resp);
                return;
            }
            if (!BCrypt.checkpw(current, user.getPasswordHash())) {
                req.setAttribute("passwordError", "Current password is incorrect.");
                forwardProfile(req, resp, user);
                return;
            }

            em.getTransaction().begin();
            user.setPasswordHash(BCrypt.hashpw(newPwd, BCrypt.gensalt()));
            em.getTransaction().commit();
            refreshSession(req.getSession(), user);
            req.setAttribute("passwordSuccess", "Password changed successfully.");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            getServletContext().log("Failed to change password for user id " + userId, e);
            req.setAttribute("passwordError", "We couldn't change your password right now. Please try again.");
            user = getSessionUser(req.getSession(false));
        } finally {
            em.close();
        }
        forwardProfile(req, resp, user != null ? user : getSessionUser(req.getSession(false)));
    }

    // ── Delete account ───────────────────────────────────────────────────────
    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, Long userId, HttpSession session)
            throws ServletException, IOException {

        String confirmPwd = req.getParameter("deletePassword");
        if (confirmPwd == null || confirmPwd.isBlank()) {
            req.setAttribute("deleteError", "Enter your password to delete this account.");
            forwardWithSessionUser(req, resp);
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            User user = em.find(User.class, userId);
            if (user == null || !BCrypt.checkpw(confirmPwd, user.getPasswordHash())) {
                req.setAttribute("deleteError", "Password is incorrect. Account not deleted.");
                forwardProfile(req, resp, user != null ? user : getSessionUser(session));
                return;
            }

            em.getTransaction().begin();
            // Remove votes cast by this user first (FK constraint)
            em.createQuery("DELETE FROM Vote v WHERE v.voter.id = :uid").setParameter("uid", userId).executeUpdate();
            // Remove contester entry if exists
            em.createQuery("DELETE FROM Contester c WHERE c.user.id = :uid").setParameter("uid", userId).executeUpdate();
            em.remove(user);
            em.getTransaction().commit();

            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/index.jsp?deleted=true");
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            getServletContext().log("Failed to delete account for user id " + userId, e);
            req.setAttribute("deleteError", "We couldn't delete your account right now. Please try again.");
            forwardWithSessionUser(req, resp);
        } finally {
            em.close();
        }
    }

    private void forwardWithSessionUser(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User sessionUser = getSessionUser(req.getSession(false));
        if (sessionUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        forwardProfile(req, resp, sessionUser);
    }

    private void forwardProfile(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        req.setAttribute("user", user);
        req.getRequestDispatcher(resolveView(user)).forward(req, resp);
    }

    private static String resolveView(User user) {
        return user != null && Role.ADMIN.equals(user.getRole()) ? ADMIN_PROFILE_VIEW : PROFILE_VIEW;
    }

    private static Long getUserId(HttpSession session) {
        Object value = session != null ? session.getAttribute("userId") : null;
        return value instanceof Long ? (Long) value : null;
    }

    private static User getSessionUser(HttpSession session) {
        Object value = session != null ? session.getAttribute("user") : null;
        return value instanceof User ? (User) value : null;
    }

    private static void refreshSession(HttpSession session, User user) {
        if (session == null || user == null) {
            return;
        }
        session.setAttribute("user", user);
        session.setAttribute("userName", buildDisplayName(user));
        session.setAttribute("userEmail", user.getEmail());
        session.setAttribute("userRole", user.getRole() != null ? user.getRole().name() : null);
    }

    private static void clearSession(HttpSession session) {
        if (session == null) {
            return;
        }
        session.invalidate();
    }

    private static String buildDisplayName(User user) {
        String firstName = user.getFirstName() != null ? user.getFirstName().trim() : "";
        String lastName = user.getLastName() != null ? user.getLastName().trim() : "";
        String fullName = (firstName + " " + lastName).trim();
        return fullName.isEmpty() ? "User" : fullName;
    }
}
