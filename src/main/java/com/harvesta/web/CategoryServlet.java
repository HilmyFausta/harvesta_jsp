package com.harvesta.web;

import com.harvesta.Db;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/categories", "/categories/*"})
public class CategoryServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String info = req.getPathInfo();
        if (info == null || info.equals("/") || info.isEmpty()) {
            handleIndex(req, resp);
        } else if (info.equals("/create")) {
            requireAdmin(req, resp);
            render(req, resp, "categories/form");
        } else if (info.endsWith("/edit")) {
            requireAdmin(req, resp);
            handleEdit(req, resp);
        } else {
            redirect(req, resp, "/categories");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        requireAdmin(req, resp);
        String info = req.getPathInfo();
        String method = req.getParameter("_method");

        if (info == null || info.equals("/") || info.isEmpty()) {
            handleStore(req, resp);
        } else if (info.endsWith("/delete") || "DELETE".equalsIgnoreCase(method)) {
            handleDelete(req, resp);
        } else {
            handleUpdate(req, resp);
        }
    }

    private void handleIndex(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Map<String, Object>> categories = Db.list(
                "select c.*, (select count(*) from tree_types where category_id = c.id) as type_count " +
                        "from categories c order by c.name");
        req.setAttribute("categories", categories);
        render(req, resp, "categories/index");
    }

    private void handleStore(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = param(req, "name");
        String desc = param(req, "description");

        if (name == null || name.isBlank()) {
            flashError(req, "The name field is required.");
            render(req, resp, "categories/form");
            return;
        }

        if (Db.count("select count(*) from categories where lower(name) = lower(?)", name) > 0) {
            flashError(req, "Category name already exists.");
            render(req, resp, "categories/form");
            return;
        }

        Db.insert("insert into categories (name, description) values (?, ?)", name, desc);
        flash(req, "The category was created successfully.");
        redirect(req, resp, "/categories");
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long id = parseId(req.getPathInfo().replace("/edit", ""));
        Map<String, Object> category = Db.one("select * from categories where id = ?", id);
        if (category == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        req.setAttribute("category", category);
        render(req, resp, "categories/form");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = parseId(req.getPathInfo());
        String name = param(req, "name");
        String desc = param(req, "description");

        if (name == null || name.isBlank()) {
            flashError(req, "The name field is required.");
            redirect(req, resp, "/categories/" + id + "/edit");
            return;
        }

        if (Db.count("select count(*) from categories where lower(name) = lower(?) and id != ?", name, id) > 0) {
            flashError(req, "Category name already exists.");
            redirect(req, resp, "/categories/" + id + "/edit");
            return;
        }

        Db.update("update categories set name = ?, description = ?, updated_at = now() where id = ?", name, desc, id);
        flash(req, "The category was updated successfully.");
        redirect(req, resp, "/categories");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = parseId(req.getPathInfo().replace("/delete", ""));
        if (Db.count("select count(*) from tree_types where category_id = ?", id) > 0) {
            flashError(req, "This category cannot be deleted because it is still used by tree types.");
            redirect(req, resp, "/categories");
            return;
        }

        Db.update("delete from categories where id = ?", id);
        flash(req, "The category was deleted successfully.");
        redirect(req, resp, "/categories");
    }

    private void requireAdmin(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            throw new ServletException("Forbidden");
        }
    }

    private long parseId(String path) {
        if (path == null) return 0;
        String[] parts = path.split("/");
        for (String p : parts) {
            if (!p.isBlank()) {
                try {
                    return Long.parseLong(p);
                } catch (NumberFormatException ignored) {}
            }
        }
        return 0;
    }
}
