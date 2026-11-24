package com.harvesta.web;

import com.harvesta.App;
import com.harvesta.Db;
import com.harvesta.Options;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/trees", "/trees/*"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class TreeServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String info = req.getPathInfo();
        if (info == null || info.equals("/") || info.isEmpty()) {
            handleIndex(req, resp);
        } else if (info.equals("/create")) {
            handleCreate(req, resp);
        } else if (info.endsWith("/photo")) {
            handlePhoto(req, resp);
        } else if (info.endsWith("/edit")) {
            handleEdit(req, resp);
        } else {
            handleShow(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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
        String search = param(req, "search", "");
        Long blockId = paramLong(req, "block_id");
        Long treeTypeId = paramLong(req, "tree_type_id");
        String status = param(req, "status", "");
        String sort = param(req, "sort", "code");
        int page = Math.max(1, paramInt(req, "page", 1));

        StringBuilder where = new StringBuilder(" where t.deleted_at is null");
        List<Object> params = new ArrayList<>();

        if (!search.isBlank()) {
            where.append(" and (t.code ilike ? or t.notes ilike ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        if (blockId != null && blockId > 0) {
            where.append(" and t.block_id = ?");
            params.add(blockId);
        }
        if (treeTypeId != null && treeTypeId > 0) {
            where.append(" and t.tree_type_id = ?");
            params.add(treeTypeId);
        }
        if (!status.isBlank()) {
            where.append(" and t.status = ?");
            params.add(status);
        }

        long totalCount = Db.count("select count(*) from trees t" + where, params.toArray());
        int pageSize = App.PAGE_SIZE;
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        int offset = (page - 1) * pageSize;

        String orderBy = switch (sort) {
            case "-code" -> "t.code desc";
            case "planted_on" -> "t.planted_on asc";
            case "-planted_on" -> "t.planted_on desc";
            default -> "t.code asc";
        };

        String select = "select t.id, t.code, t.planted_on, t.status, t.height_cm, t.photo is not null as has_photo, " +
                "tt.name as type_name, b.name as block_name " +
                "from trees t " +
                "join tree_types tt on t.tree_type_id = tt.id " +
                "join blocks b on t.block_id = b.id " +
                where + " order by " + orderBy + " limit ? offset ?";
        params.add(pageSize);
        params.add(offset);

        List<Map<String, Object>> trees = Db.list(select, params.toArray());

        req.setAttribute("trees", trees);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("blocks", Db.list("select id, name from blocks order by name"));
        req.setAttribute("treeTypes", Db.list("select id, name from tree_types order by name"));
        req.setAttribute("treeStatuses", Options.TREE_STATUSES);
        req.setAttribute("search", search);
        req.setAttribute("selectedBlockId", blockId);
        req.setAttribute("selectedTypeId", treeTypeId);
        req.setAttribute("selectedStatus", status);
        req.setAttribute("sort", sort);

        StringBuilder qs = new StringBuilder();
        if (!search.isBlank()) qs.append("&search=").append(search);
        if (blockId != null) qs.append("&block_id=").append(blockId);
        if (treeTypeId != null) qs.append("&tree_type_id=").append(treeTypeId);
        if (!status.isBlank()) qs.append("&status=").append(status);
        if (!sort.isBlank()) qs.append("&sort=").append(sort);
        req.setAttribute("queryString", qs.toString());

        render(req, resp, "trees/index");
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("blocks", Db.list("select id, name from blocks order by name"));
        req.setAttribute("treeTypes", Db.list("select id, name from tree_types order by name"));
        req.setAttribute("treeStatuses", Options.TREE_STATUSES);
        render(req, resp, "trees/form");
    }

    private void handleStore(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long treeTypeId = paramLong(req, "tree_type_id");
        Long blockId = paramLong(req, "block_id");
        LocalDate plantedOn = paramDate(req, "planted_on");
        String status = param(req, "status", "seedling");
        String code = param(req, "code");
        BigDecimal height = paramDecimal(req, "height_cm");
        String notes = param(req, "notes");

        if (treeTypeId == null || blockId == null || plantedOn == null || status.isBlank()) {
            flashError(req, "Please fill in all required fields.");
            handleCreate(req, resp);
            return;
        }

        if (plantedOn.isAfter(LocalDate.now())) {
            flashError(req, "Planted date cannot be in the future.");
            handleCreate(req, resp);
            return;
        }

        // Auto-generate code if empty
        if (code == null || code.isBlank()) {
            long maxId = Db.count("select coalesce(max(id), 0) from trees");
            code = String.format("T-%04d", maxId + 1);
        } else if (Db.count("select count(*) from trees where code = ?", code) > 0) {
            flashError(req, "Tree code " + code + " already exists.");
            handleCreate(req, resp);
            return;
        }

        byte[] photoBytes = null;
        String photoType = null;
        try {
            Part filePart = req.getPart("photo");
            if (filePart != null && filePart.getSize() > 0) {
                photoBytes = filePart.getInputStream().readAllBytes();
                photoType = filePart.getContentType();
            }
        } catch (Exception ignored) {}

        long userId = userId(req);
        if (photoBytes != null) {
            Db.insert("insert into trees (code, tree_type_id, block_id, created_by, planted_on, status, height_cm, notes, photo, photo_type) " +
                    "values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    code, treeTypeId, blockId, userId, plantedOn, status, height, notes, photoBytes, photoType);
        } else {
            Db.insert("insert into trees (code, tree_type_id, block_id, created_by, planted_on, status, height_cm, notes) " +
                    "values (?, ?, ?, ?, ?, ?, ?, ?)",
                    code, treeTypeId, blockId, userId, plantedOn, status, height, notes);
        }

        flash(req, "The tree was created successfully.");
        redirect(req, resp, "/trees");
    }

    private void handleShow(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long id = parseId(req.getPathInfo());
        Map<String, Object> tree = Db.one(
                "select t.*, tt.name as type_name, c.name as category_name, b.name as block_name, u.name as author_name, " +
                        "t.photo is not null as has_photo " +
                        "from trees t " +
                        "join tree_types tt on t.tree_type_id = tt.id " +
                        "join categories c on tt.category_id = c.id " +
                        "join blocks b on t.block_id = b.id " +
                        "left join users u on t.created_by = u.id " +
                        "where t.id = ? and t.deleted_at is null", id);

        if (tree == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Tree not found");
            return;
        }

        List<Map<String, Object>> careLogs = Db.list(
                "select cl.*, u.name as author_name from care_logs cl " +
                        "left join users u on cl.user_id = u.id " +
                        "where cl.tree_id = ? order by cl.performed_on desc", id);

        List<Map<String, Object>> harvests = Db.list(
                "select h.*, u.name as author_name from harvests h " +
                        "left join users u on h.user_id = u.id " +
                        "where h.tree_id = ? order by h.harvested_on desc", id);

        Object totalKg = Db.value("select coalesce(sum(quantity), 0) from harvests where tree_id = ? and unit = 'kg'", id);
        Object totalPcs = Db.value("select coalesce(sum(quantity), 0) from harvests where tree_id = ? and unit = 'pcs'", id);

        req.setAttribute("tree", tree);
        req.setAttribute("careLogs", careLogs);
        req.setAttribute("harvests", harvests);
        req.setAttribute("totalKg", totalKg);
        req.setAttribute("totalPcs", totalPcs);

        render(req, resp, "trees/show");
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String info = req.getPathInfo();
        long id = parseId(info.replace("/edit", ""));

        Map<String, Object> tree = Db.one("select * from trees where id = ? and deleted_at is null", id);
        if (tree == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        req.setAttribute("tree", tree);
        req.setAttribute("blocks", Db.list("select id, name from blocks order by name"));
        req.setAttribute("treeTypes", Db.list("select id, name from tree_types order by name"));
        req.setAttribute("treeStatuses", Options.TREE_STATUSES);
        render(req, resp, "trees/form");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long id = parseId(req.getPathInfo());
        Long treeTypeId = paramLong(req, "tree_type_id");
        Long blockId = paramLong(req, "block_id");
        LocalDate plantedOn = paramDate(req, "planted_on");
        String status = param(req, "status");
        String code = param(req, "code");
        BigDecimal height = paramDecimal(req, "height_cm");
        String notes = param(req, "notes");

        if (treeTypeId == null || blockId == null || plantedOn == null || status == null || code == null) {
            flashError(req, "Please fill in all required fields.");
            redirect(req, resp, "/trees/" + id + "/edit");
            return;
        }

        byte[] photoBytes = null;
        String photoType = null;
        try {
            Part filePart = req.getPart("photo");
            if (filePart != null && filePart.getSize() > 0) {
                photoBytes = filePart.getInputStream().readAllBytes();
                photoType = filePart.getContentType();
            }
        } catch (Exception ignored) {}

        if (photoBytes != null) {
            Db.update("update trees set code = ?, tree_type_id = ?, block_id = ?, planted_on = ?, status = ?, height_cm = ?, notes = ?, photo = ?, photo_type = ?, updated_at = now() where id = ?",
                    code, treeTypeId, blockId, plantedOn, status, height, notes, photoBytes, photoType, id);
        } else {
            Db.update("update trees set code = ?, tree_type_id = ?, block_id = ?, planted_on = ?, status = ?, height_cm = ?, notes = ?, updated_at = now() where id = ?",
                    code, treeTypeId, blockId, plantedOn, status, height, notes, id);
        }

        flash(req, "The tree was updated successfully.");
        redirect(req, resp, "/trees/" + id);
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (!isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String info = req.getPathInfo();
        long id = parseId(info.replace("/delete", ""));
        Db.update("update trees set deleted_at = now() where id = ?", id);
        flash(req, "The tree was deleted successfully.");
        redirect(req, resp, "/trees");
    }

    private void handlePhoto(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String info = req.getPathInfo();
        long id = parseId(info.replace("/photo", ""));

        try (Connection conn = Db.getConnection();
             PreparedStatement ps = conn.prepareStatement("select photo, photo_type from trees where id = ?")) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    byte[] bytes = rs.getBytes("photo");
                    String type = rs.getString("photo_type");
                    if (bytes != null && bytes.length > 0) {
                        resp.setContentType(type != null ? type : "image/jpeg");
                        resp.setContentLength(bytes.length);
                        try (OutputStream out = resp.getOutputStream()) {
                            out.write(bytes);
                            out.flush();
                        }
                        return;
                    }
                }
            }
        } catch (Exception ignored) {}
        resp.sendError(HttpServletResponse.SC_NOT_FOUND);
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
