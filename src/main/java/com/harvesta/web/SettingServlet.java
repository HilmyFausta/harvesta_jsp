package com.harvesta.web;

import com.harvesta.Db;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet(urlPatterns = {"/settings", "/settings/*"})
public class SettingServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.equals("") || pathInfo.equals("/")) {
            redirect(req, resp, "/settings/profile");
            return;
        }

        if (pathInfo.equals("/profile")) {
            Long userId = (Long) req.getSession().getAttribute("userId");
            Map<String, Object> user = Db.one("select id, name, email from users where id = ?", userId);
            req.setAttribute("user", user);
            req.setAttribute("settingsTab", "profile");
            render(req, resp, "settings/profile");
            return;
        }

        if (pathInfo.equals("/appearance")) {
            req.setAttribute("settingsTab", "appearance");
            render(req, resp, "settings/appearance");
            return;
        }

        if (pathInfo.equals("/security")) {
            req.setAttribute("settingsTab", "security");
            render(req, resp, "settings/security");
            return;
        }

        resp.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null) pathInfo = "";

        Long userId = (Long) req.getSession().getAttribute("userId");
        if (userId == null) {
            redirect(req, resp, "/login");
            return;
        }

        if (pathInfo.equals("/profile")) {
            updateProfile(req, resp, userId);
            return;
        }

        if (pathInfo.equals("/appearance")) {
            flashSuccess(req, "Appearance settings updated.");
            redirect(req, resp, "/settings/appearance");
            return;
        }

        if (pathInfo.equals("/security")) {
            updateSecurity(req, resp, userId);
            return;
        }

        resp.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    private void updateProfile(HttpServletRequest req, HttpServletResponse resp, Long userId)
            throws ServletException, IOException {
        String name = param(req, "name");
        String email = param(req, "email");

        Map<String, String> errors = new LinkedHashMap<>();
        if (name.isEmpty()) {
            errors.put("name", "The name field is required.");
        }
        if (email.isEmpty()) {
            errors.put("email", "The email field is required.");
        } else if (!email.contains("@") || !email.contains(".")) {
            errors.put("email", "The email field must be a valid email address.");
        } else {
            Map<String, Object> existing = Db.one("select id from users where lower(email) = lower(?) and id != ?", email, userId);
            if (existing != null) {
                errors.put("email", "The email has already been taken.");
            }
        }

        if (!errors.isEmpty()) {
            Map<String, Object> user = new HashMap<>();
            user.put("name", name);
            user.put("email", email);
            req.setAttribute("user", user);
            req.setAttribute("errors", errors);
            req.setAttribute("settingsTab", "profile");
            render(req, resp, "settings/profile");
            return;
        }

        Db.update("update users set name = ?, email = lower(?), updated_at = now() where id = ?", name, email, userId);
        flashSuccess(req, "Profile updated.");
        redirect(req, resp, "/settings/profile");
    }

    private void updateSecurity(HttpServletRequest req, HttpServletResponse resp, Long userId)
            throws ServletException, IOException {
        String currentPassword = param(req, "current_password");
        String password = param(req, "password");
        String passwordConfirmation = param(req, "password_confirmation");

        Map<String, Object> user = Db.one("select password from users where id = ?", userId);
        Map<String, String> errors = new LinkedHashMap<>();

        if (currentPassword.isEmpty()) {
            errors.put("current_password", "The current password field is required.");
        } else if (user != null && !BCrypt.checkpw(currentPassword, (String) user.get("password"))) {
            errors.put("current_password", "The password you entered does not match your current password.");
        }

        if (password.isEmpty()) {
            errors.put("password", "The new password field is required.");
        } else if (password.length() < 8) {
            errors.put("password", "The password must be at least 8 characters.");
        } else if (!password.equals(passwordConfirmation)) {
            errors.put("password_confirmation", "The password confirmation does not match.");
        }

        if (!errors.isEmpty()) {
            req.setAttribute("errors", errors);
            req.setAttribute("settingsTab", "security");
            render(req, resp, "settings/security");
            return;
        }

        String hashed = BCrypt.hashpw(password, BCrypt.gensalt());
        Db.update("update users set password = ?, updated_at = now() where id = ?", hashed, userId);
        flashSuccess(req, "Password updated.");
        redirect(req, resp, "/settings/security");
    }
}
