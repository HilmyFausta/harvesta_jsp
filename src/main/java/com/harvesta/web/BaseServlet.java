package com.harvesta.web;

import com.harvesta.App;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;

public abstract class BaseServlet extends HttpServlet {

    protected void render(HttpServletRequest req, HttpServletResponse resp, String jsp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/" + jsp + ".jsp").forward(req, resp);
    }

    protected void redirect(HttpServletRequest req, HttpServletResponse resp, String path)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + path);
    }

    protected void flash(HttpServletRequest req, String message) {
        HttpSession s = req.getSession(true);
        s.setAttribute("flashSuccess", message);
    }

    protected void flashSuccess(HttpServletRequest req, String message) {
        flash(req, message);
    }

    protected void flashError(HttpServletRequest req, String message) {
        HttpSession s = req.getSession(true);
        s.setAttribute("flashError", message);
    }

    protected long userId(HttpServletRequest req) {
        Object uid = req.getAttribute("userId");
        if (uid instanceof Number n) return n.longValue();
        return 0L;
    }

    protected boolean isAdmin(HttpServletRequest req) {
        return Boolean.TRUE.equals(req.getAttribute("isAdmin"));
    }

    protected boolean canWrite(HttpServletRequest req) {
        return Boolean.TRUE.equals(req.getAttribute("canWrite"));
    }

    protected String param(HttpServletRequest req, String name) {
        String val = req.getParameter(name);
        return val == null ? null : val.trim();
    }

    protected String param(HttpServletRequest req, String name, String def) {
        String val = req.getParameter(name);
        return (val == null || val.isBlank()) ? def : val.trim();
    }

    protected int paramInt(HttpServletRequest req, String name, int def) {
        String v = param(req, name);
        if (v == null || v.isBlank()) return def;
        try {
            return Integer.parseInt(v);
        } catch (NumberFormatException e) {
            return def;
        }
    }

    protected Long paramLong(HttpServletRequest req, String name) {
        String v = param(req, name);
        if (v == null || v.isBlank()) return null;
        try {
            return Long.parseLong(v);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    protected BigDecimal paramDecimal(HttpServletRequest req, String name) {
        String v = param(req, name);
        if (v == null || v.isBlank()) return null;
        try {
            return new BigDecimal(v.replace(",", ""));
        } catch (Exception e) {
            return null;
        }
    }

    protected LocalDate paramDate(HttpServletRequest req, String name) {
        String v = param(req, name);
        if (v == null || v.isBlank()) return null;
        try {
            return LocalDate.parse(v);
        } catch (Exception e) {
            return null;
        }
    }
}
