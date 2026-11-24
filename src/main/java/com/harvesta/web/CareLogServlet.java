package com.harvesta.web;

import com.harvesta.App;
import com.harvesta.Db;
import com.harvesta.Options;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/care-logs", "/care-logs/*"})
public class CareLogServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String info = req.getPathInfo();
        if (info == null || info.equals("/") || info.isEmpty()) {
            handleIndex(req, resp);
        } else if (info.equals("/create")) {
            handleCreate(req, resp);
        } else if (info.endsWith("/edit")) {
            handleEdit(req, resp);
        } else {
            redirect(req, resp, "/care-logs");
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
        Long treeId = paramLong(req, "tree_id");
        Long blockId = paramLong(req, "block_id");
        String activity = param(req, "activity_type", "");
        LocalDate fromDate = paramDate(req, "from");
        LocalDate toDate = paramDate(req, "to");
        int page = Math.max(1, paramInt(req, "page", 1));

        StringBuilder where = new StringBuilder(" where t.deleted_at is null");
        List<Object> params = new ArrayList<>();

        if (treeId != null && treeId > 0) {
            where.append(" and cl.tree_id = ?");
            params.add(treeId);
        }
        if (blockId != null && blockId > 0) {
            where.append(" and t.block_id = ?");
            params.add(blockId);
        }
        if (!activity.isBlank()) {
            where.append(" and cl.activity_type = ?");
            params.add(activity);
        }
        if (fromDate != null) {
            where.append(" and cl.performed_on >= ?");
            params.add(fromDate);
        }
        if (toDate != null) {
            where.append(" and cl.performed_on <= ?");
            params.add(toDate);
        }

        long totalCount = Db.count(
                "select count(*) from care_logs cl join trees t on cl.tree_id = t.id" + where,
                params.toArray());

        int pageSize = App.PAGE_SIZE;
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        int offset = (page - 1) * pageSize;

        String select = "select cl.*, t.code as tree_code, b.name as block_name, u.name as author_name " +
                "from care_logs cl " +
                "join trees t on cl.tree_id = t.id " +
                "join blocks b on t.block_id = b.id " +
                "left join users u on cl.user_id = u.id " +
                where + " order by cl.performed_on desc, cl.id desc limit ? offset ?";
        params.add(pageSize);
        params.add(offset);

        List<Map<String, Object>> careLogs = Db.list(select, params.toArray());

        req.setAttribute("careLogs", careLogs);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("blocks", Db.list("select id, name from blocks order by name"));
        req.setAttribute("trees", Db.list("select id, code from trees where deleted_at is null order by code"));
        req.setAttribute("activityTypes", Options.ACTIVITY_TYPES);
        req.setAttribute("selectedTreeId", treeId);
        req.setAttribute("selectedBlockId", blockId);
        req.setAttribute("selectedActivity", activity);
        req.setAttribute("from", fromDate);
        req.setAttribute("to", toDate);

        StringBuilder qs = new StringBuilder();
        if (treeId != null) qs.append("&tree_id=").append(treeId);
        if (blockId != null) qs.append("&block_id=").append(blockId);
        if (!activity.isBlank()) qs.append("&activity_type=").append(activity);
        if (fromDate != null) qs.append("&from=").append(fromDate);
        if (toDate != null) qs.append("&to=").append(toDate);
        req.setAttribute("queryString", qs.toString());

        render(req, resp, "care-logs/index");
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long treeId = paramLong(req, "tree_id");
        req.setAttribute("selectedTreeId", treeId);
        // Only trees that are not dead
        req.setAttribute("trees", Db.list("select id, code from trees where deleted_at is null and status != 'dead' order by code"));
        req.setAttribute("activityTypes", Options.ACTIVITY_TYPES);
        render(req, resp, "care-logs/form");
    }

    private void handleStore(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long treeId = paramLong(req, "tree_id");
        String activity = param(req, "activity_type");
        LocalDate performedOn = paramDate(req, "performed_on");
        LocalDate nextDueOn = paramDate(req, "next_due_on");
        String notes = param(req, "notes");

        if (treeId == null || activity == null || performedOn == null) {
            flashError(req, "Please fill in all required fields.");
            handleCreate(req, resp);
            return;
        }

        if (performedOn.isAfter(LocalDate.now())) {
            flashError(req, "Performed date cannot be in the future.");
            handleCreate(req, resp);
            return;
        }

        if (nextDueOn != null && nextDueOn.isBefore(performedOn)) {
            flashError(req, "Next due date must be on or after the performed date.");
            handleCreate(req, resp);
            return;
        }

        Map<String, Object> tree = Db.one("select status from trees where id = ? and deleted_at is null", treeId);
        if (tree == null || "dead".equals(tree.get("status"))) {
            flashError(req, "Dead trees cannot accept care logs.");
            handleCreate(req, resp);
            return;
        }

        Db.insert("insert into care_logs (tree_id, user_id, activity_type, performed_on, next_due_on, notes) " +
                "values (?, ?, ?, ?, ?, ?)", treeId, userId(req), activity, performedOn, nextDueOn, notes);

        flash(req, "The care log was created successfully.");
        redirect(req, resp, "/care-logs");
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long id = parseId(req.getPathInfo().replace("/edit", ""));
        Map<String, Object> careLog = Db.one("select * from care_logs where id = ?", id);
        if (careLog == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Staff can only edit their own
        if (!isAdmin(req)) {
            Object authorId = careLog.get("user_id");
            if (authorId == null || ((Number) authorId).longValue() != userId(req)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        }

        req.setAttribute("careLog", careLog);
        req.setAttribute("trees", Db.list("select id, code from trees where deleted_at is null order by code"));
        req.setAttribute("activityTypes", Options.ACTIVITY_TYPES);
        render(req, resp, "care-logs/form");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = parseId(req.getPathInfo());
        Map<String, Object> careLog = Db.one("select * from care_logs where id = ?", id);
        if (careLog == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        if (!isAdmin(req)) {
            Object authorId = careLog.get("user_id");
            if (authorId == null || ((Number) authorId).longValue() != userId(req)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        }

        Long treeId = paramLong(req, "tree_id");
        String activity = param(req, "activity_type");
        LocalDate performedOn = paramDate(req, "performed_on");
        LocalDate nextDueOn = paramDate(req, "next_due_on");
        String notes = param(req, "notes");

        if (treeId == null || activity == null || performedOn == null) {
            flashError(req, "Please fill in all required fields.");
            redirect(req, resp, "/care-logs/" + id + "/edit");
            return;
        }

        Db.update("update care_logs set tree_id = ?, activity_type = ?, performed_on = ?, next_due_on = ?, notes = ?, updated_at = now() where id = ?",
                treeId, activity, performedOn, nextDueOn, notes, id);

        flash(req, "The care log was updated successfully.");
        redirect(req, resp, "/care-logs");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (!isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        long id = parseId(req.getPathInfo().replace("/delete", ""));
        Db.update("delete from care_logs where id = ?", id);
        flash(req, "The care log was deleted successfully.");
        redirect(req, resp, "/care-logs");
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
