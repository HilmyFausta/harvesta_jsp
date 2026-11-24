package com.harvesta.web;

import com.harvesta.App;
import com.harvesta.Db;
import com.harvesta.Options;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/harvests", "/harvests/*"})
public class HarvestServlet extends BaseServlet {

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
            redirect(req, resp, "/harvests");
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
        String grade = param(req, "grade", "");
        LocalDate fromDate = paramDate(req, "from");
        LocalDate toDate = paramDate(req, "to");
        int page = Math.max(1, paramInt(req, "page", 1));

        StringBuilder where = new StringBuilder(" where t.deleted_at is null");
        List<Object> params = new ArrayList<>();

        if (treeId != null && treeId > 0) {
            where.append(" and h.tree_id = ?");
            params.add(treeId);
        }
        if (blockId != null && blockId > 0) {
            where.append(" and t.block_id = ?");
            params.add(blockId);
        }
        if (!grade.isBlank()) {
            where.append(" and h.grade = ?");
            params.add(grade);
        }
        if (fromDate != null) {
            where.append(" and h.harvested_on >= ?");
            params.add(fromDate);
        }
        if (toDate != null) {
            where.append(" and h.harvested_on <= ?");
            params.add(toDate);
        }

        long totalCount = Db.count(
                "select count(*) from harvests h join trees t on h.tree_id = t.id" + where,
                params.toArray());

        int pageSize = App.PAGE_SIZE;
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        int offset = (page - 1) * pageSize;

        // Sum quantities
        Object sumKg = Db.value("select coalesce(sum(h.quantity), 0) from harvests h join trees t on h.tree_id = t.id" + where + " and h.unit = 'kg'", params.toArray());
        Object sumPcs = Db.value("select coalesce(sum(h.quantity), 0) from harvests h join trees t on h.tree_id = t.id" + where + " and h.unit = 'pcs'", params.toArray());

        String select = "select h.*, t.code as tree_code, tt.name as type_name, b.name as block_name, u.name as author_name, " +
                "(select coalesce(sum(quantity), 0) from sales where harvest_id = h.id) as sold_qty " +
                "from harvests h " +
                "join trees t on h.tree_id = t.id " +
                "join tree_types tt on t.tree_type_id = tt.id " +
                "join blocks b on t.block_id = b.id " +
                "left join users u on h.user_id = u.id " +
                where + " order by h.harvested_on desc, h.id desc limit ? offset ?";
        params.add(pageSize);
        params.add(offset);

        List<Map<String, Object>> harvests = Db.list(select, params.toArray());

        req.setAttribute("harvests", harvests);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalKg", sumKg);
        req.setAttribute("totalPcs", sumPcs);
        req.setAttribute("blocks", Db.list("select id, name from blocks order by name"));
        req.setAttribute("trees", Db.list("select id, code from trees where deleted_at is null order by code"));
        req.setAttribute("harvestGrades", Options.HARVEST_GRADES);
        req.setAttribute("selectedTreeId", treeId);
        req.setAttribute("selectedBlockId", blockId);
        req.setAttribute("selectedGrade", grade);
        req.setAttribute("from", fromDate);
        req.setAttribute("to", toDate);

        StringBuilder qs = new StringBuilder();
        if (treeId != null) qs.append("&tree_id=").append(treeId);
        if (blockId != null) qs.append("&block_id=").append(blockId);
        if (!grade.isBlank()) qs.append("&grade=").append(grade);
        if (fromDate != null) qs.append("&from=").append(fromDate);
        if (toDate != null) qs.append("&to=").append(toDate);
        req.setAttribute("queryString", qs.toString());

        render(req, resp, "harvests/index");
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long treeId = paramLong(req, "tree_id");
        req.setAttribute("selectedTreeId", treeId);
        req.setAttribute("trees", Db.list("select id, code from trees where deleted_at is null and status != 'dead' order by code"));
        req.setAttribute("harvestUnits", Options.HARVEST_UNITS);
        req.setAttribute("harvestGrades", Options.HARVEST_GRADES);
        render(req, resp, "harvests/form");
    }

    private void handleStore(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long treeId = paramLong(req, "tree_id");
        LocalDate harvestedOn = paramDate(req, "harvested_on");
        BigDecimal quantity = paramDecimal(req, "quantity");
        String unit = param(req, "unit");
        String grade = param(req, "grade");
        String notes = param(req, "notes");

        if (treeId == null || harvestedOn == null || quantity == null || unit == null || grade == null) {
            flashError(req, "Please fill in all required fields.");
            handleCreate(req, resp);
            return;
        }

        if (quantity.compareTo(BigDecimal.ZERO) <= 0) {
            flashError(req, "Quantity must be greater than zero.");
            handleCreate(req, resp);
            return;
        }

        if (harvestedOn.isAfter(LocalDate.now())) {
            flashError(req, "Harvest date cannot be in the future.");
            handleCreate(req, resp);
            return;
        }

        Map<String, Object> tree = Db.one("select status from trees where id = ? and deleted_at is null", treeId);
        if (tree == null || "dead".equals(tree.get("status"))) {
            flashError(req, "Dead trees cannot accept harvests.");
            handleCreate(req, resp);
            return;
        }

        Db.insert("insert into harvests (tree_id, user_id, harvested_on, quantity, unit, grade, notes) " +
                "values (?, ?, ?, ?, ?, ?, ?)", treeId, userId(req), harvestedOn, quantity, unit, grade, notes);

        flash(req, "The harvest was created successfully.");
        redirect(req, resp, "/harvests");
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long id = parseId(req.getPathInfo().replace("/edit", ""));
        Map<String, Object> harvest = Db.one("select * from harvests where id = ?", id);
        if (harvest == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        if (!isAdmin(req)) {
            Object authorId = harvest.get("user_id");
            if (authorId == null || ((Number) authorId).longValue() != userId(req)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        }

        req.setAttribute("harvest", harvest);
        req.setAttribute("trees", Db.list("select id, code from trees where deleted_at is null order by code"));
        req.setAttribute("harvestUnits", Options.HARVEST_UNITS);
        req.setAttribute("harvestGrades", Options.HARVEST_GRADES);
        render(req, resp, "harvests/form");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = parseId(req.getPathInfo());
        Map<String, Object> harvest = Db.one("select * from harvests where id = ?", id);
        if (harvest == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        if (!isAdmin(req)) {
            Object authorId = harvest.get("user_id");
            if (authorId == null || ((Number) authorId).longValue() != userId(req)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        }

        Long treeId = paramLong(req, "tree_id");
        LocalDate harvestedOn = paramDate(req, "harvested_on");
        BigDecimal quantity = paramDecimal(req, "quantity");
        String unit = param(req, "unit");
        String grade = param(req, "grade");
        String notes = param(req, "notes");

        if (treeId == null || harvestedOn == null || quantity == null || unit == null || grade == null) {
            flashError(req, "Please fill in all required fields.");
            redirect(req, resp, "/harvests/" + id + "/edit");
            return;
        }

        // Check if new quantity is less than already sold quantity
        Object soldObj = Db.value("select coalesce(sum(quantity), 0) from sales where harvest_id = ?", id);
        BigDecimal sold = soldObj == null ? BigDecimal.ZERO : new BigDecimal(soldObj.toString());
        if (quantity.compareTo(sold) < 0) {
            flashError(req, "Quantity cannot be less than already sold quantity (" + sold + " " + unit + ").");
            redirect(req, resp, "/harvests/" + id + "/edit");
            return;
        }

        Db.update("update harvests set tree_id = ?, harvested_on = ?, quantity = ?, unit = ?, grade = ?, notes = ?, updated_at = now() where id = ?",
                treeId, harvestedOn, quantity, unit, grade, notes, id);

        flash(req, "The harvest was updated successfully.");
        redirect(req, resp, "/harvests");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (!isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        long id = parseId(req.getPathInfo().replace("/delete", ""));
        long salesCount = Db.count("select count(*) from sales where harvest_id = ?", id);
        if (salesCount > 0) {
            flashError(req, "This harvest cannot be deleted because it already has sales records.");
            redirect(req, resp, "/harvests");
            return;
        }

        Db.update("delete from harvests where id = ?", id);
        flash(req, "The harvest was deleted successfully.");
        redirect(req, resp, "/harvests");
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
