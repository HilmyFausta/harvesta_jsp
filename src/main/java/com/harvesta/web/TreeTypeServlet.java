package com.harvesta.web;

import com.harvesta.Db;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/tree-types", "/tree-types/*"})
public class TreeTypeServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String info = req.getPathInfo();
        if (info == null || info.equals("/") || info.isEmpty()) {
            handleIndex(req, resp);
        } else if (info.equals("/create")) {
            requireAdmin(req, resp);
            handleCreate(req, resp);
        } else if (info.endsWith("/edit")) {
            requireAdmin(req, resp);
            handleEdit(req, resp);
        } else {
            redirect(req, resp, "/tree-types");
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
        Long categoryId = paramLong(req, "category_id");
        String search = param(req, "search", "");

        StringBuilder where = new StringBuilder(" where 1=1");
        List<Object> params = new ArrayList<>();
        if (categoryId != null && categoryId > 0) {
            where.append(" and tt.category_id = ?");
            params.add(categoryId);
        }
        if (!search.isBlank()) {
            where.append(" and (tt.name ilike ? or tt.scientific_name ilike ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }

        List<Map<String, Object>> treeTypes = Db.list(
                "select tt.*, c.name as category_name, " +
                        "(select count(*) from trees where tree_type_id = tt.id and deleted_at is null) as tree_count " +
                        "from tree_types tt join categories c on tt.category_id = c.id" +
                        where + " order by tt.name", params.toArray());

        req.setAttribute("treeTypes", treeTypes);
        req.setAttribute("categories", Db.list("select id, name from categories order by name"));
        req.setAttribute("selectedCategoryId", categoryId);
        req.setAttribute("search", search);
        render(req, resp, "tree-types/index");
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("categories", Db.list("select id, name from categories order by name"));
        render(req, resp, "tree-types/form");
    }

    private void handleStore(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long categoryId = paramLong(req, "category_id");
        String name = param(req, "name");
        String scientific = param(req, "scientific_name");
        String desc = param(req, "description");

        if (categoryId == null || name == null || name.isBlank()) {
            flashError(req, "Please fill in all required fields.");
            handleCreate(req, resp);
            return;
        }

        if (Db.count("select count(*) from tree_types where category_id = ? and lower(name) = lower(?)", categoryId, name) > 0) {
            flashError(req, "Tree type name already exists in this category.");
            handleCreate(req, resp);
            return;
        }

        Db.insert("insert into tree_types (category_id, name, scientific_name, description) values (?, ?, ?, ?)",
                categoryId, name, scientific, desc);
        flash(req, "The tree type was created successfully.");
        redirect(req, resp, "/tree-types");
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long id = parseId(req.getPathInfo().replace("/edit", ""));
        Map<String, Object> treeType = Db.one("select * from tree_types where id = ?", id);
        if (treeType == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        req.setAttribute("treeType", treeType);
        req.setAttribute("categories", Db.list("select id, name from categories order by name"));
        render(req, resp, "tree-types/form");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = parseId(req.getPathInfo());
        Long categoryId = paramLong(req, "category_id");
        String name = param(req, "name");
        String scientific = param(req, "scientific_name");
        String desc = param(req, "description");

        if (categoryId == null || name == null || name.isBlank()) {
            flashError(req, "Please fill in all required fields.");
            redirect(req, resp, "/tree-types/" + id + "/edit");
            return;
        }

        if (Db.count("select count(*) from tree_types where category_id = ? and lower(name) = lower(?) and id != ?", categoryId, name, id) > 0) {
            flashError(req, "Tree type name already exists in this category.");
            redirect(req, resp, "/tree-types/" + id + "/edit");
            return;
        }

        Db.update("update tree_types set category_id = ?, name = ?, scientific_name = ?, description = ?, updated_at = now() where id = ?",
                categoryId, name, scientific, desc, id);
        flash(req, "The tree type was updated successfully.");
        redirect(req, resp, "/tree-types");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = parseId(req.getPathInfo().replace("/delete", ""));
        if (Db.count("select count(*) from trees where tree_type_id = ? and deleted_at is null", id) > 0) {
            flashError(req, "This tree type cannot be deleted because it is still used by trees.");
            redirect(req, resp, "/tree-types");
            return;
        }

        Db.update("delete from tree_types where id = ?", id);
        flash(req, "The tree type was deleted successfully.");
        redirect(req, resp, "/tree-types");
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
