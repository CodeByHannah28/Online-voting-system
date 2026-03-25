package com.bascode.admin;

import com.bascode.model.entity.User;
import com.bascode.model.enums.Role;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

public class AdminAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // no-op
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        if (!(request instanceof HttpServletRequest) || !(response instanceof HttpServletResponse)) {
            chain.doFilter(request, response);
            return;
        }

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        if (session == null) {
            // Not logged in - redirect to auth page
            resp.sendRedirect(req.getContextPath() + "/auth.jsp");
            return;
        }

        Object o = session.getAttribute("user");
        if (!(o instanceof User)) {
            // Not logged in as a recognized user
            resp.sendRedirect(req.getContextPath() + "/auth.jsp");
            return;
        }

        User u = (User) o;
        if (u.getRole() != Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // user is admin - proceed
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // no-op
    }
}
