package com.harvesta.web;

import com.harvesta.Db;
import com.harvesta.Options;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

@WebServlet(urlPatterns = {"/users", "/users/*"})
public class UserServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.equals("") || pathInfo.equals("/")) {
            list(req, resp);
            return;
        }

        if (pathInfo.equals("/create")) {
            createForm(req, resp);
            return;
        }

        if (pathInfo.matches("/\\d+/edit")) {
            long id = Long.parseLong(pathInfo.split("/")[1]);
            editForm(req, resp, id);
            return;
        }

        resp.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.equals("") || pathInfo.equals("/") || pathInfo.equals("/create")) {
            save(req, resp, null);
            return;
        }

        if (pathInfo.matches("/\\d+/delete")) {
            long id = Long.parseLong(pathInfo.split("/")[1]);
            delete(req, resp, id);
            return;
        }

        if (pathInfo.matches("/\\d+/edit") || pathInfo.matches("/\\d+")) {
            long id = Long.parseLong(pathInfo.split("/")[1]);
            save(req, resp, id);
            return;
        }

        resp.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    private void list(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String search = req.getParameter("search");
        if (search == null) search = req.getParameter("q");
        if (search != null) search = search.trim();
        else search = "";

        String role = req.getParameter("role");
        if (role != null) role = role.trim();
        else role = "";

        String sort = req.getParameter("sort");
        if (sort == null || (!sort.equals("name") && !sort.equals("email") && !sort.equals("created_at"))) {
            sort = "name";
        }

        String direction = req.getParameter("direction");
        if (direction == null || (!direction.equalsIgnoreCase("asc") && !direction.equalsIgnoreCase("desc"))) {
            direction = "asc";
        }

        int page = 1;
        try {
            String pStr = req.getParameter("page");
            if (pStr != null) page = Math.max(1, Integer.parseInt(pStr));
        } catch (NumberFormatException ignored) {}

        int pageSize = 15;
        int offset = (page - 1) * pageSize;

        List<Object> countParams = new ArrayList<>();
        StringBuilder where = new StringBuilder(" where 1=1 ");

        if (!search.isEmpty()) {
            where.append(" and (name ilike ? or email ilike ?) ");
            countParams.add("%" + search + "%");
            countParams.add("%" + search + "%");
        }

        if (!role.isEmpty()) {
            where.append(" and role = ? ");
            countParams.add(role);
        }

        Map<String, Object> countRow = Db.one("select count(*) as c from users " + where, countParams.toArray());
        long totalCount = countRow == null ? 0 : ((Number) countRow.get("c")).longValue();
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);

        List<Object> queryParams = new ArrayList<>(countParams);
        String sql = "select id, name, email, role, created_at from users "
                + where
                + " order by " + sort + " " + direction
                + " limit " + pageSize + " offset " + offset;

        List<Map<String, Object>> users = Db.query(sql, queryParams.toArray());

        Map<String, Object> adminCountRow = Db.one("select count(*) as c from users where role = 'admin'");
        long adminCount = adminCountRow == null ? 0 : ((Number) adminCountRow.get("c")).longValue();

        req.setAttribute("users", users);
        req.setAttribute("roles", Options.USER_ROLES);
        req.setAttribute("adminCount", adminCount);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("search", search);
        req.setAttribute("selectedRole", role);
        req.setAttribute("sort", sort);
        req.setAttribute("direction", direction);

        StringBuilder queryString = new StringBuilder();
        if (!search.isEmpty()) {
            queryString.append("&search=").append(URLEncoder.encode(search, StandardCharsets.UTF_8));
        }
        if (!role.isEmpty()) {
            queryString.append("&role=").append(URLEncoder.encode(role, StandardCharsets.UTF_8));
        }
        queryString.append("&sort=").append(sort).append("&direction=").append(direction);
        req.setAttribute("queryString", queryString.toString());

        render(req, resp, "users/index");
    }

    private void createForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Map<String, Object> user = new HashMap<>();
        user.put("role", "staff");
        req.setAttribute("user", user);
        req.setAttribute("roles", Options.USER_ROLES);
        req.setAttribute("isEdit", false);
        req.setAttribute("roleDisabled", false);
        render(req, resp, "users/form");
    }

    private void editForm(HttpServletRequest req, HttpServletResponse resp, long id) throws ServletException, IOException {
        Map<String, Object> user = Db.one("select id, name, email, role from users where id = ?", id);
        if (user == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Map<String, Object> adminCountRow = Db.one("select count(*) as c from users where role = 'admin'");
        long adminCount = adminCountRow == null ? 0 : ((Number) adminCountRow.get("c")).longValue();
        boolean roleDisabled = "admin".equalsIgnoreCase((String) user.get("role")) && adminCount <= 1;

        req.setAttribute("user", user);
        req.setAttribute("roles", Options.USER_ROLES);
        req.setAttribute("isEdit", true);
        req.setAttribute("roleDisabled", roleDisabled);
        render(req, resp, "users/form");
    }

    private void save(HttpServletRequest req, HttpServletResponse resp, Long id) throws ServletException, IOException {
        boolean isEdit = id != null;
        String name = param(req, "name");
        String email = param(req, "email");
        String role = param(req, "role");
        String password = param(req, "password");

        Map<String, String> errors = new LinkedHashMap<>();

        if (name.isEmpty()) {
            errors.put("name", "The name field is required.");
        }

        if (email.isEmpty()) {
            errors.put("email", "The email field is required.");
        } else if (!email.contains("@") || !email.contains(".")) {
            errors.put("email", "The email field must be a valid email address.");
        } else {
            Map<String, Object> existing = isEdit
                    ? Db.one("select id from users where lower(email) = lower(?) and id != ?", email, id)
                    : Db.one("select id from users where lower(email) = lower(?)", email);
            if (existing != null) {
                errors.put("email", "The email has already been taken.");
            }
        }

        Map<String, Object> currentUser = isEdit ? Db.one("select id, role from users where id = ?", id) : null;
        long adminCount = 0;
        Map<String, Object> acRow = Db.one("select count(*) as c from users where role = 'admin'");
        if (acRow != null) {
            adminCount = ((Number) acRow.get("c")).longValue();
        }

        boolean roleDisabled = isEdit && currentUser != null
                && "admin".equalsIgnoreCase((String) currentUser.get("role"))
                && adminCount <= 1;

        if (roleDisabled) {
            role = "admin";
        } else {
            if (role.isEmpty() || !Options.USER_ROLES.containsKey(role)) {
                errors.put("role", "The selected role is invalid.");
            }
        }

        if (!isEdit) {
            if (password.isEmpty()) {
                errors.put("password", "The password field is required.");
            } else if (password.length() < 8) {
                errors.put("password", "The password field must be at least 8 characters.");
            }
        } else {
            if (!password.isEmpty() && password.length() < 8) {
                errors.put("password", "The password field must be at least 8 characters.");
            }
        }

        if (!errors.isEmpty()) {
            Map<String, Object> user = new HashMap<>();
            if (id != null) user.put("id", id);
            user.put("name", name);
            user.put("email", email);
            user.put("role", role);

            req.setAttribute("user", user);
            req.setAttribute("roles", Options.USER_ROLES);
            req.setAttribute("isEdit", isEdit);
            req.setAttribute("roleDisabled", roleDisabled);
            req.setAttribute("errors", errors);
            render(req, resp, "users/form");
            return;
        }

        if (!isEdit) {
            String hashed = BCrypt.hashpw(password, BCrypt.gensalt());
            Db.update("insert into users (name, email, role, password, created_at, updated_at) values (?, lower(?), ?, ?, now(), now())",
                    name, email, role, hashed);
            flashSuccess(req, "User created successfully.");
            redirect(req, resp, "/users");
        } else {
            if (!password.isEmpty()) {
                String hashed = BCrypt.hashpw(password, BCrypt.gensalt());
                Db.update("update users set name = ?, email = lower(?), role = ?, password = ?, updated_at = now() where id = ?",
                        name, email, role, hashed, id);
            } else {
                Db.update("update users set name = ?, email = lower(?), role = ?, updated_at = now() where id = ?",
                        name, email, role, id);
            }

            Long loggedInId = (Long) req.getSession().getAttribute("userId");
            if (loggedInId != null && loggedInId.equals(id) && !"admin".equalsIgnoreCase(role)) {
                flashSuccess(req, "User updated successfully.");
                redirect(req, resp, "/dashboard");
                return;
            }

            flashSuccess(req, "User updated successfully.");
            redirect(req, resp, "/users");
        }
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp, long id) throws IOException {
        Map<String, Object> target = Db.one("select id, role from users where id = ?", id);
        if (target == null) {
            redirect(req, resp, "/users");
            return;
        }

        Map<String, Object> acRow = Db.one("select count(*) as c from users where role = 'admin'");
        long adminCount = acRow == null ? 0 : ((Number) acRow.get("c")).longValue();

        if ("admin".equalsIgnoreCase((String) target.get("role")) && adminCount <= 1) {
            flashError(req, "The last admin cannot be deleted.");
            redirect(req, resp, "/users");
            return;
        }

        Db.update("delete from users where id = ?", id);

        Long loggedInId = (Long) req.getSession().getAttribute("userId");
        if (loggedInId != null && loggedInId.equals(id)) {
            req.getSession().invalidate();
            redirect(req, resp, "/login");
            return;
        }

        flashSuccess(req, "User deleted successfully.");
        redirect(req, resp, "/users");
    }
}
