package com.bascode.auth;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class AuthFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String uri = req.getRequestURI();
        // Public paths - no auth required
        if (isPublicPath(uri) || 
            req.getRequestURI().endsWith(".css") || req.getRequestURI().endsWith(".js") ||
            req.getRequestURI().endsWith(".jpeg") || req.getRequestURI().endsWith(".jpg") ||
            req.getRequestURI().endsWith(".png") || req.getRequestURI().contains("/public/")) {
            chain.doFilter(request, response);
            return;
        }

        // Check session
        if (session != null && session.getAttribute("userId") != null) {
            chain.doFilter(request, response);
        } else {
            // Redirect to login with original URI
            String query = req.getQueryString() != null ? "?" + req.getQueryString() : "";
            resp.sendRedirect(req.getContextPath() + "/login.jsp?redirect=" + java.net.URLEncoder.encode(req.getRequestURI() + query, "UTF-8"));
        }
    }

    private boolean isPublicPath(String uri) {
        String[] publicPaths = {
            "/",
            "/index.jsp",
            "/auth.jsp",
            "/about.jsp",
            "/contact.jsp",
            "/login",
            "/register",
            "/verify",
            "/logout",
            "/login.jsp",
            "/register.jsp",
            "/verify.jsp",
            "/verify-code.jsp",
            "/auth.jsp"
        };
        for (String path : publicPaths) {
            if (uri.endsWith(path)) {
                return true;
            }
        }
        return false;
    }
}