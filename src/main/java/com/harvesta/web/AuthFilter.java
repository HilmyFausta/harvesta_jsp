package com.harvesta.web;

import com.harvesta.App;
import com.harvesta.Db;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;
import java.util.Set;

@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final Set<String> PUBLIC_PATHS = Set.of(
            "/login", "/register", "/logout"
    );

    private static final Set<String> ADMIN_ONLY_PREFIXES = Set.of(
            "/expenses", "/sales", "/reports", "/users"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // Static files pass through
        if (path.startsWith("/build/") || path.startsWith("/favicons/") || path.equals("/favicon.ico")
                || path.equals("/favicon.svg") || path.equals("/apple-touch-icon.png") || path.equals("/robots.txt")) {
            chain.doFilter(request, response);
            return;
        }

        // Home redirect
        if (path.equals("") || path.equals("/")) {
            HttpSession session = req.getSession(false);
            if (session != null && session.getAttribute("userId") != null) {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            } else {
                resp.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }

        HttpSession session = req.getSession(false);
        Long userId = session == null ? null : (Long) session.getAttribute("userId");

        // Public routes
        if (PUBLIC_PATHS.contains(path)) {
            if (userId != null && !path.equals("/logout")) {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
                return;
            }
            chain.doFilter(request, response);
            return;
        }

        // Protected routes
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // User data
        Map<String, Object> user = Db.one("select id, name, email, role from users where id = ?", userId);
        if (user == null) {
            session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String role = (String) user.get("role");
        boolean isAdmin = "admin".equalsIgnoreCase(role);
        boolean canWrite = !"viewer".equalsIgnoreCase(role);

        // Admin-only routes
        for (String prefix : ADMIN_ONLY_PREFIXES) {
            if (path.equals(prefix) || path.startsWith(prefix + "/")) {
                if (!isAdmin) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Forbidden");
                    return;
                }
            }
        }

        // Set attributes for JSP
        req.setAttribute("user", user);
        req.setAttribute("userId", userId);
        req.setAttribute("userRole", role);
        req.setAttribute("isAdmin", isAdmin);
        req.setAttribute("canWrite", canWrite);
        req.setAttribute("appName", App.NAME);
        req.setAttribute("currentPath", path);

        // Flash message support
        if (session != null) {
            String flashSuccess = (String) session.getAttribute("flashSuccess");
            if (flashSuccess != null) {
                req.setAttribute("flashSuccess", flashSuccess);
                session.removeAttribute("flashSuccess");
            }
            String flashError = (String) session.getAttribute("flashError");
            if (flashError != null) {
                req.setAttribute("flashError", flashError);
                session.removeAttribute("flashError");
            }
        }

        chain.doFilter(request, response);
    }
}
