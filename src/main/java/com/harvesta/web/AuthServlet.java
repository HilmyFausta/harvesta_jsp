package com.harvesta.web;

import com.harvesta.Db;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.util.Map;

@WebServlet(urlPatterns = {"/login", "/register", "/logout"})
public class AuthServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/login".equals(path)) {
            render(req, resp, "auth/login");
        } else if ("/register".equals(path)) {
            render(req, resp, "auth/register");
        } else {
            redirect(req, resp, "/login");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/login".equals(path)) {
            handleLogin(req, resp);
        } else if ("/register".equals(path)) {
            handleRegister(req, resp);
        } else if ("/logout".equals(path)) {
            handleLogout(req, resp);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = param(req, "email");
        String password = param(req, "password");

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "These credentials do not match our records.");
            req.setAttribute("email", email);
            render(req, resp, "auth/login");
            return;
        }

        Map<String, Object> user = Db.one("select id, password, role from users where lower(email) = lower(?)", email);
        if (user == null) {
            req.setAttribute("error", "These credentials do not match our records.");
            req.setAttribute("email", email);
            render(req, resp, "auth/login");
            return;
        }

        String storedHash = (String) user.get("password");
        boolean ok = false;
        try {
            // Support standard bcrypt ($2a$, $2y$, etc.)
            if (storedHash.startsWith("$2y$")) {
                storedHash = "$2a$" + storedHash.substring(4);
            }
            ok = BCrypt.checkpw(password, storedHash);
        } catch (Exception ignored) {}

        if (!ok) {
            req.setAttribute("error", "These credentials do not match our records.");
            req.setAttribute("email", email);
            render(req, resp, "auth/login");
            return;
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("userId", ((Number) user.get("id")).longValue());
        redirect(req, resp, "/dashboard");
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = param(req, "name");
        String email = param(req, "email");
        String password = param(req, "password");
        String confirm = param(req, "password_confirmation");

        if (name == null || name.isBlank() || email == null || email.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "All fields are required.");
            req.setAttribute("name", name);
            req.setAttribute("email", email);
            render(req, resp, "auth/register");
            return;
        }

        if (password.length() < 8) {
            req.setAttribute("error", "The password must be at least 8 characters.");
            req.setAttribute("name", name);
            req.setAttribute("email", email);
            render(req, resp, "auth/register");
            return;
        }

        if (!password.equals(confirm)) {
            req.setAttribute("error", "The password confirmation does not match.");
            req.setAttribute("name", name);
            req.setAttribute("email", email);
            render(req, resp, "auth/register");
            return;
        }

        if (Db.count("select count(*) from users where lower(email) = lower(?)", email) > 0) {
            req.setAttribute("error", "The email has already been taken.");
            req.setAttribute("name", name);
            req.setAttribute("email", email);
            render(req, resp, "auth/register");
            return;
        }

        String hash = BCrypt.hashpw(password, BCrypt.gensalt(10));
        long newId = Db.insert("insert into users (name, email, password, role) values (?, ?, ?, 'staff')",
                name, email, hash);

        HttpSession session = req.getSession(true);
        session.setAttribute("userId", newId);
        redirect(req, resp, "/dashboard");
    }

    private void handleLogout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        redirect(req, resp, "/login");
    }
}
