package com.harvesta.web;

import com.harvesta.App;
import com.harvesta.Db;
import com.harvesta.SaleService;
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

@WebServlet(urlPatterns = {"/sales", "/sales/*"})
public class SaleServlet extends BaseServlet {

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
            redirect(req, resp, "/sales");
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
        String buyer = param(req, "buyer", "");
        Long treeTypeId = paramLong(req, "tree_type_id");
        LocalDate fromDate = paramDate(req, "from");
        LocalDate toDate = paramDate(req, "to");
        int page = Math.max(1, paramInt(req, "page", 1));

        StringBuilder where = new StringBuilder(" where 1=1");
        List<Object> params = new ArrayList<>();

        if (!buyer.isBlank()) {
            where.append(" and s.buyer_name ilike ?");
            params.add("%" + buyer + "%");
        }
        if (treeTypeId != null && treeTypeId > 0) {
            where.append(" and t.tree_type_id = ?");
            params.add(treeTypeId);
        }
        if (fromDate != null) {
            where.append(" and s.sold_on >= ?");
            params.add(fromDate);
        }
        if (toDate != null) {
            where.append(" and s.sold_on <= ?");
            params.add(toDate);
        }

        String baseFrom = " from sales s " +
                "join harvests h on s.harvest_id = h.id " +
                "join trees t on h.tree_id = t.id " +
                "join tree_types tt on t.tree_type_id = tt.id ";

        long totalCount = Db.count("select count(*)" + baseFrom + where, params.toArray());
        Object sumObj = Db.value("select coalesce(sum(s.total_amount), 0)" + baseFrom + where, params.toArray());
        BigDecimal totalRevenue = sumObj == null ? BigDecimal.ZERO : new BigDecimal(sumObj.toString());

        int pageSize = App.PAGE_SIZE;
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        int offset = (page - 1) * pageSize;

        String select = "select s.*, h.unit, t.code as tree_code, tt.name as type_name, u.name as author_name" +
                baseFrom + "left join users u on s.user_id = u.id " +
                where + " order by s.sold_on desc, s.id desc limit ? offset ?";
        params.add(pageSize);
        params.add(offset);

        List<Map<String, Object>> sales = Db.list(select, params.toArray());

        req.setAttribute("sales", sales);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("treeTypes", Db.list("select id, name from tree_types order by name"));
        req.setAttribute("buyer", buyer);
        req.setAttribute("selectedTypeId", treeTypeId);
        req.setAttribute("from", fromDate);
        req.setAttribute("to", toDate);

        StringBuilder qs = new StringBuilder();
        if (!buyer.isBlank()) qs.append("&buyer=").append(buyer);
        if (treeTypeId != null) qs.append("&tree_type_id=").append(treeTypeId);
        if (fromDate != null) qs.append("&from=").append(fromDate);
        if (toDate != null) qs.append("&to=").append(toDate);
        req.setAttribute("queryString", qs.toString());

        render(req, resp, "sales/index");
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long harvestId = paramLong(req, "harvest_id");
        req.setAttribute("selectedHarvestId", harvestId);
        // List harvests that have remaining unsold quantity
        List<Map<String, Object>> harvests = Db.list(
                "select h.id, h.harvested_on, h.quantity, h.unit, t.code as tree_code, tt.name as type_name, " +
                        "(h.quantity - coalesce((select sum(quantity) from sales where harvest_id = h.id), 0)) as remaining_qty " +
                        "from harvests h " +
                        "join trees t on h.tree_id = t.id " +
                        "join tree_types tt on t.tree_type_id = tt.id " +
                        "order by h.harvested_on desc");
        req.setAttribute("harvests", harvests);
        render(req, resp, "sales/form");
    }

    private void handleStore(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long harvestId = paramLong(req, "harvest_id");
        String buyer = param(req, "buyer_name");
        LocalDate soldOn = paramDate(req, "sold_on");
        BigDecimal quantity = paramDecimal(req, "quantity");
        BigDecimal unitPrice = paramDecimal(req, "unit_price");
        String notes = param(req, "notes");

        if (harvestId == null || buyer == null || buyer.isBlank() || soldOn == null || quantity == null || unitPrice == null) {
            flashError(req, "Please fill in all required fields.");
            handleCreate(req, resp);
            return;
        }

        if (quantity.compareTo(BigDecimal.ZERO) <= 0 || unitPrice.compareTo(BigDecimal.ZERO) <= 0) {
            flashError(req, "Quantity and unit price must be greater than zero.");
            handleCreate(req, resp);
            return;
        }

        BigDecimal remaining = SaleService.remainingQuantity(harvestId, null);
        if (quantity.compareTo(remaining) > 0) {
            flashError(req, "The quantity exceeds the remaining unsold amount of this harvest (" + remaining + ").");
            handleCreate(req, resp);
            return;
        }

        BigDecimal total = SaleService.calculateTotal(quantity, unitPrice);

        Db.insert("insert into sales (harvest_id, user_id, buyer_name, sold_on, quantity, unit_price, total_amount, notes) " +
                "values (?, ?, ?, ?, ?, ?, ?, ?)",
                harvestId, userId(req), buyer, soldOn, quantity, unitPrice, total, notes);

        flash(req, "The sale was created successfully.");
        redirect(req, resp, "/sales");
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long id = parseId(req.getPathInfo().replace("/edit", ""));
        Map<String, Object> sale = Db.one("select * from sales where id = ?", id);
        if (sale == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        List<Map<String, Object>> harvests = Db.list(
                "select h.id, h.harvested_on, h.quantity, h.unit, t.code as tree_code, tt.name as type_name " +
                        "from harvests h " +
                        "join trees t on h.tree_id = t.id " +
                        "join tree_types tt on t.tree_type_id = tt.id " +
                        "order by h.harvested_on desc");

        req.setAttribute("sale", sale);
        req.setAttribute("harvests", harvests);
        render(req, resp, "sales/form");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = parseId(req.getPathInfo());
        Long harvestId = paramLong(req, "harvest_id");
        String buyer = param(req, "buyer_name");
        LocalDate soldOn = paramDate(req, "sold_on");
        BigDecimal quantity = paramDecimal(req, "quantity");
        BigDecimal unitPrice = paramDecimal(req, "unit_price");
        String notes = param(req, "notes");

        if (harvestId == null || buyer == null || buyer.isBlank() || soldOn == null || quantity == null || unitPrice == null) {
            flashError(req, "Please fill in all required fields.");
            redirect(req, resp, "/sales/" + id + "/edit");
            return;
        }

        BigDecimal remaining = SaleService.remainingQuantity(harvestId, id);
        if (quantity.compareTo(remaining) > 0) {
            flashError(req, "The quantity exceeds the remaining unsold amount of this harvest (" + remaining + ").");
            redirect(req, resp, "/sales/" + id + "/edit");
            return;
        }

        BigDecimal total = SaleService.calculateTotal(quantity, unitPrice);

        Db.update("update sales set harvest_id = ?, buyer_name = ?, sold_on = ?, quantity = ?, unit_price = ?, total_amount = ?, notes = ?, updated_at = now() where id = ?",
                harvestId, buyer, soldOn, quantity, unitPrice, total, notes, id);

        flash(req, "The sale was updated successfully.");
        redirect(req, resp, "/sales");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = parseId(req.getPathInfo().replace("/delete", ""));
        Db.update("delete from sales where id = ?", id);
        flash(req, "The sale was deleted successfully.");
        redirect(req, resp, "/sales");
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
