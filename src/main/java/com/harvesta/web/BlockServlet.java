package com.harvesta.web;

import com.harvesta.Db;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/blocks", "/blocks/*"})
public class BlockServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String info = req.getPathInfo();
        if (info == null || info.equals("/") || info.isEmpty()) {
            handleIndex(req, resp);
        } else if (info.equals("/create")) {
            requireAdmin(req, resp);
            render(req, resp, "blocks/form");
        } else if (info.endsWith("/edit")) {
            requireAdmin(req, resp);
            handleEdit(req, resp);
        } else {
            handleShow(req, resp);
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
        List<Map<String, Object>> blocks = Db.list(
                "select b.*, " +
                        "(select count(*) from trees where block_id = b.id and deleted_at is null) as tree_count, " +
                        "(select coalesce(sum(quantity), 0) from harvests h join trees t on h.tree_id = t.id where t.block_id = b.id and t.deleted_at is null and h.unit = 'kg') as total_kg " +
                        "from blocks b order by b.name");
        req.setAttribute("blocks", blocks);
        render(req, resp, "blocks/index");
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        render(req, resp, "blocks/form");
    }

    private void handleStore(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = param(req, "name");
        BigDecimal area = paramDecimal(req, "area_sqm");
        String location = param(req, "location_note");
        String desc = param(req, "description");

        if (name == null || name.isBlank()) {
            flashError(req, "Block name is required.");
            render(req, resp, "blocks/form");
            return;
        }

        if (Db.count("select count(*) from blocks where lower(name) = lower(?)", name) > 0) {
            flashError(req, "Block name already exists.");
            render(req, resp, "blocks/form");
            return;
        }

        Db.insert("insert into blocks (name, area_sqm, location_note, description) values (?, ?, ?, ?)",
                name, area, location, desc);
        flash(req, "The block was created successfully.");
        redirect(req, resp, "/blocks");
    }

    private void handleShow(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long id = parseId(req.getPathInfo());
        Map<String, Object> block = Db.one("select * from blocks where id = ?", id);
        if (block == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        List<Map<String, Object>> trees = Db.list(
                "select t.*, tt.name as type_name from trees t " +
                        "join tree_types tt on t.tree_type_id = tt.id " +
                        "where t.block_id = ? and t.deleted_at is null order by t.code", id);

        Object totalKg = Db.value(
                "select coalesce(sum(quantity), 0) from harvests h join trees t on h.tree_id = t.id " +
                        "where t.block_id = ? and t.deleted_at is null and h.unit = 'kg'", id);
        Object totalPcs = Db.value(
                "select coalesce(sum(quantity), 0) from harvests h join trees t on h.tree_id = t.id " +
                        "where t.block_id = ? and t.deleted_at is null and h.unit = 'pcs'", id);

        req.setAttribute("block", block);
        req.setAttribute("trees", trees);
        req.setAttribute("totalKg", totalKg);
        req.setAttribute("totalPcs", totalPcs);
        render(req, resp, "blocks/show");
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long id = parseId(req.getPathInfo().replace("/edit", ""));
        Map<String, Object> block = Db.one("select * from blocks where id = ?", id);
        if (block == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        req.setAttribute("block", block);
        render(req, resp, "blocks/form");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = parseId(req.getPathInfo());
        String name = param(req, "name");
        BigDecimal area = paramDecimal(req, "area_sqm");
        String location = param(req, "location_note");
        String desc = param(req, "description");

        if (name == null || name.isBlank()) {
            flashError(req, "Block name is required.");
            redirect(req, resp, "/blocks/" + id + "/edit");
            return;
        }

        if (Db.count("select count(*) from blocks where lower(name) = lower(?) and id != ?", name, id) > 0) {
            flashError(req, "Block name already exists.");
            redirect(req, resp, "/blocks/" + id + "/edit");
            return;
        }

        Db.update("update blocks set name = ?, area_sqm = ?, location_note = ?, description = ?, updated_at = now() where id = ?",
                name, area, location, desc, id);
        flash(req, "The block was updated successfully.");
        redirect(req, resp, "/blocks");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = parseId(req.getPathInfo().replace("/delete", ""));
        if (Db.count("select count(*) from trees where block_id = ? and deleted_at is null", id) > 0 ||
                Db.count("select count(*) from expenses where block_id = ?", id) > 0) {
            flashError(req, "This block cannot be deleted because it is still used by trees or expenses.");
            redirect(req, resp, "/blocks");
            return;
        }

        Db.update("delete from blocks where id = ?", id);
        flash(req, "The block was deleted successfully.");
        redirect(req, resp, "/blocks");
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
