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

@WebServlet(urlPatterns = {"/expenses", "/expenses/*"})
public class ExpenseServlet extends BaseServlet {

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
            redirect(req, resp, "/expenses");
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
        String blockParam = param(req, "block_id", "");
        String category = param(req, "category", "");
        LocalDate fromDate = paramDate(req, "from");
        LocalDate toDate = paramDate(req, "to");
        int page = Math.max(1, paramInt(req, "page", 1));

        StringBuilder where = new StringBuilder(" where 1=1");
        List<Object> params = new ArrayList<>();

        if ("general".equalsIgnoreCase(blockParam)) {
            where.append(" and e.block_id is null");
        } else if (!blockParam.isBlank()) {
            try {
                long bId = Long.parseLong(blockParam);
                where.append(" and e.block_id = ?");
                params.add(bId);
            } catch (NumberFormatException ignored) {}
        }

        if (!category.isBlank()) {
            where.append(" and e.category = ?");
            params.add(category);
        }
        if (fromDate != null) {
            where.append(" and e.spent_on >= ?");
            params.add(fromDate);
        }
        if (toDate != null) {
            where.append(" and e.spent_on <= ?");
            params.add(toDate);
        }

        long totalCount = Db.count("select count(*) from expenses e" + where, params.toArray());
        Object sumObj = Db.value("select coalesce(sum(amount), 0) from expenses e" + where, params.toArray());
        BigDecimal totalAmount = sumObj == null ? BigDecimal.ZERO : new BigDecimal(sumObj.toString());

        int pageSize = App.PAGE_SIZE;
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        int offset = (page - 1) * pageSize;

        String select = "select e.*, b.name as block_name, u.name as author_name from expenses e " +
                "left join blocks b on e.block_id = b.id " +
                "left join users u on e.user_id = u.id " +
                where + " order by e.spent_on desc, e.id desc limit ? offset ?";
        params.add(pageSize);
        params.add(offset);

        List<Map<String, Object>> expenses = Db.list(select, params.toArray());

        req.setAttribute("expenses", expenses);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalAmount", totalAmount);
        req.setAttribute("blocks", Db.list("select id, name from blocks order by name"));
        req.setAttribute("categories", Options.EXPENSE_CATEGORIES);
        req.setAttribute("selectedBlock", blockParam);
        req.setAttribute("selectedCategory", category);
        req.setAttribute("from", fromDate);
        req.setAttribute("to", toDate);

        StringBuilder qs = new StringBuilder();
        if (!blockParam.isBlank()) qs.append("&block_id=").append(blockParam);
        if (!category.isBlank()) qs.append("&category=").append(category);
        if (fromDate != null) qs.append("&from=").append(fromDate);
        if (toDate != null) qs.append("&to=").append(toDate);
        req.setAttribute("queryString", qs.toString());

        render(req, resp, "expenses/index");
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("blocks", Db.list("select id, name from blocks order by name"));
        req.setAttribute("categories", Options.EXPENSE_CATEGORIES);
        render(req, resp, "expenses/form");
    }

    private void handleStore(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long blockId = paramLong(req, "block_id");
        String category = param(req, "category");
        BigDecimal amount = paramDecimal(req, "amount");
        LocalDate spentOn = paramDate(req, "spent_on");
        String desc = param(req, "description");

        if (category == null || amount == null || spentOn == null) {
            flashError(req, "Please fill in all required fields.");
            handleCreate(req, resp);
            return;
        }

        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            flashError(req, "Amount must be greater than zero.");
            handleCreate(req, resp);
            return;
        }

        Db.insert("insert into expenses (block_id, user_id, category, amount, spent_on, description) values (?, ?, ?, ?, ?, ?)",
                blockId, userId(req), category, amount, spentOn, desc);

        flash(req, "The expense was created successfully.");
        redirect(req, resp, "/expenses");
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        long id = parseId(req.getPathInfo().replace("/edit", ""));
        Map<String, Object> expense = Db.one("select * from expenses where id = ?", id);
        if (expense == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        req.setAttribute("expense", expense);
        req.setAttribute("blocks", Db.list("select id, name from blocks order by name"));
        req.setAttribute("categories", Options.EXPENSE_CATEGORIES);
        render(req, resp, "expenses/form");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = parseId(req.getPathInfo());
        Long blockId = paramLong(req, "block_id");
        String category = param(req, "category");
        BigDecimal amount = paramDecimal(req, "amount");
        LocalDate spentOn = paramDate(req, "spent_on");
        String desc = param(req, "description");

        if (category == null || amount == null || spentOn == null) {
            flashError(req, "Please fill in all required fields.");
            redirect(req, resp, "/expenses/" + id + "/edit");
            return;
        }

        Db.update("update expenses set block_id = ?, category = ?, amount = ?, spent_on = ?, description = ?, updated_at = now() where id = ?",
                blockId, category, amount, spentOn, desc, id);

        flash(req, "The expense was updated successfully.");
        redirect(req, resp, "/expenses");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long id = parseId(req.getPathInfo().replace("/delete", ""));
        Db.update("delete from expenses where id = ?", id);
        flash(req, "The expense was deleted successfully.");
        redirect(req, resp, "/expenses");
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
