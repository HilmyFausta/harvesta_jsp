package com.harvesta.web;

import com.harvesta.Db;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/dashboard")
public class DashboardServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        LocalDate today = LocalDate.now();
        LocalDate startOfMonth = today.withDayOfMonth(1);
        boolean admin = isAdmin(req);

        // 1. Total trees & statuses
        long totalTrees = Db.count("select count(*) from trees where deleted_at is null");
        List<Map<String, Object>> statusCounts = Db.list(
                "select status, count(*) as c from trees where deleted_at is null group by status");
        Map<String, Long> treesByStatus = new LinkedHashMap<>();
        for (Map<String, Object> r : statusCounts) {
            treesByStatus.put((String) r.get("status"), ((Number) r.get("c")).longValue());
        }

        // 2. Total blocks
        long totalBlocks = Db.count("select count(*) from blocks");

        // 3. Harvests this month
        Object kgObj = Db.value("select sum(quantity) from harvests where harvested_on >= ? and unit = 'kg'", startOfMonth);
        Object pcsObj = Db.value("select sum(quantity) from harvests where harvested_on >= ? and unit = 'pcs'", startOfMonth);
        BigDecimal kgThisMonth = kgObj == null ? BigDecimal.ZERO : new BigDecimal(kgObj.toString());
        BigDecimal pcsThisMonth = pcsObj == null ? BigDecimal.ZERO : new BigDecimal(pcsObj.toString());

        // 4. Financials this month (Admin only)
        BigDecimal expensesThisMonth = BigDecimal.ZERO;
        BigDecimal salesThisMonth = BigDecimal.ZERO;
        BigDecimal netProfitThisMonth = BigDecimal.ZERO;

        if (admin) {
            Object expObj = Db.value("select sum(amount) from expenses where spent_on >= ?", startOfMonth);
            Object salObj = Db.value("select sum(total_amount) from sales where sold_on >= ?", startOfMonth);
            expensesThisMonth = expObj == null ? BigDecimal.ZERO : new BigDecimal(expObj.toString());
            salesThisMonth = salObj == null ? BigDecimal.ZERO : new BigDecimal(salObj.toString());
            netProfitThisMonth = salesThisMonth.subtract(expensesThisMonth);
        }

        // 5. Upcoming care logs
        List<Map<String, Object>> upcomingCare = Db.list(
                "select c.id, c.activity_type, c.performed_on, c.next_due_on, t.id as tree_id, t.code as tree_code " +
                        "from care_logs c join trees t on c.tree_id = t.id " +
                        "where c.next_due_on is not null and c.next_due_on <= ? and t.deleted_at is null " +
                        "order by c.next_due_on asc limit 5", today.plusDays(7));

        // 6. Recent harvests
        List<Map<String, Object>> recentHarvests = Db.list(
                "select h.id, h.harvested_on, h.quantity, h.unit, h.grade, t.id as tree_id, t.code as tree_code " +
                        "from harvests h join trees t on h.tree_id = t.id " +
                        "where t.deleted_at is null order by h.harvested_on desc, h.id desc limit 5");

        // 7. 12-month charts
        List<String> months = new ArrayList<>();
        List<Double> harvestMonthly = new ArrayList<>();
        List<Double> salesMonthly = new ArrayList<>();
        List<Double> expensesMonthly = new ArrayList<>();

        DateTimeFormatter monthFmt = DateTimeFormatter.ofPattern("MMM yyyy");
        for (int i = 11; i >= 0; i--) {
            LocalDate m = today.minusMonths(i);
            LocalDate mStart = m.withDayOfMonth(1);
            LocalDate mEnd = m.withDayOfMonth(m.lengthOfMonth());
            months.add(m.format(monthFmt));

            Object hKg = Db.value("select sum(quantity) from harvests where harvested_on between ? and ?", mStart, mEnd);
            harvestMonthly.add(hKg == null ? 0.0 : ((Number) hKg).doubleValue());

            if (admin) {
                Object sVal = Db.value("select sum(total_amount) from sales where sold_on between ? and ?", mStart, mEnd);
                Object eVal = Db.value("select sum(amount) from expenses where spent_on between ? and ?", mStart, mEnd);
                salesMonthly.add(sVal == null ? 0.0 : ((Number) sVal).doubleValue());
                expensesMonthly.add(eVal == null ? 0.0 : ((Number) eVal).doubleValue());
            }
        }

        req.setAttribute("totalTrees", totalTrees);
        req.setAttribute("treesByStatus", treesByStatus);
        req.setAttribute("totalBlocks", totalBlocks);
        req.setAttribute("kgThisMonth", kgThisMonth);
        req.setAttribute("pcsThisMonth", pcsThisMonth);
        req.setAttribute("expensesThisMonth", expensesThisMonth);
        req.setAttribute("salesThisMonth", salesThisMonth);
        req.setAttribute("netProfitThisMonth", netProfitThisMonth);
        req.setAttribute("upcomingCare", upcomingCare);
        req.setAttribute("recentHarvests", recentHarvests);
        req.setAttribute("chartMonths", months);
        req.setAttribute("chartHarvests", harvestMonthly);
        req.setAttribute("chartSales", salesMonthly);
        req.setAttribute("chartExpenses", expensesMonthly);

        render(req, resp, "dashboard");
    }
}
