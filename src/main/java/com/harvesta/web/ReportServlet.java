package com.harvesta.web;

import com.harvesta.Db;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/reports", "/reports/export"})
public class ReportServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/reports/export".equals(path)) {
            handleExport(req, resp);
        } else {
            handleIndex(req, resp);
        }
    }

    private void handleIndex(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String reportType = param(req, "report", "harvest");
        LocalDate fromDate = paramDate(req, "from");
        LocalDate toDate = paramDate(req, "to");
        if (fromDate == null) fromDate = LocalDate.now().minusMonths(6).withDayOfMonth(1);
        if (toDate == null) toDate = LocalDate.now();

        req.setAttribute("reportType", reportType);
        req.setAttribute("from", fromDate);
        req.setAttribute("to", toDate);

        if ("financial".equalsIgnoreCase(reportType)) {
            // Financial report by month
            List<Map<String, Object>> rows = Db.list(
                    "select to_char(d, 'YYYY-MM') as month, " +
                            "coalesce((select sum(total_amount) from sales where to_char(sold_on, 'YYYY-MM') = to_char(d, 'YYYY-MM')), 0) as sales, " +
                            "coalesce((select sum(amount) from expenses where to_char(spent_on, 'YYYY-MM') = to_char(d, 'YYYY-MM')), 0) as expenses " +
                            "from generate_series(?::date, ?::date, '1 month'::interval) d " +
                            "order by month desc", fromDate, toDate);

            BigDecimal totalSales = BigDecimal.ZERO;
            BigDecimal totalExpenses = BigDecimal.ZERO;
            for (Map<String, Object> r : rows) {
                BigDecimal s = new BigDecimal(r.get("sales").toString());
                BigDecimal e = new BigDecimal(r.get("expenses").toString());
                r.put("net", s.subtract(e));
                totalSales = totalSales.add(s);
                totalExpenses = totalExpenses.add(e);
            }
            req.setAttribute("financialRows", rows);
            req.setAttribute("totalSales", totalSales);
            req.setAttribute("totalExpenses", totalExpenses);
            req.setAttribute("totalNet", totalSales.subtract(totalExpenses));

        } else if ("care".equalsIgnoreCase(reportType)) {
            // Care log summary by activity type
            List<Map<String, Object>> rows = Db.list(
                    "select activity_type, count(*) as count, min(performed_on) as first_date, max(performed_on) as last_date " +
                            "from care_logs where performed_on between ? and ? group by activity_type order by count desc",
                    fromDate, toDate);
            req.setAttribute("careRows", rows);

        } else {
            // Harvest summary by tree type
            List<Map<String, Object>> rows = Db.list(
                    "select tt.name as type_name, c.name as category_name, h.unit, " +
                            "count(h.id) as harvest_count, sum(h.quantity) as total_quantity " +
                            "from harvests h " +
                            "join trees t on h.tree_id = t.id " +
                            "join tree_types tt on t.tree_type_id = tt.id " +
                            "join categories c on tt.category_id = c.id " +
                            "where h.harvested_on between ? and ? " +
                            "group by tt.name, c.name, h.unit order by total_quantity desc",
                    fromDate, toDate);
            req.setAttribute("harvestRows", rows);
        }

        render(req, resp, "reports/index");
    }

    private void handleExport(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String reportType = param(req, "report", "harvest");
        LocalDate fromDate = paramDate(req, "from");
        LocalDate toDate = paramDate(req, "to");
        if (fromDate == null) fromDate = LocalDate.now().minusMonths(6).withDayOfMonth(1);
        if (toDate == null) toDate = LocalDate.now();

        String filename = reportType + "-report-" + fromDate + "-to-" + toDate + ".csv";
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        try (PrintWriter writer = resp.getWriter()) {
            if ("financial".equalsIgnoreCase(reportType)) {
                writer.println("Month,Sales (IDR),Expenses (IDR),Net Profit (IDR)");
                List<Map<String, Object>> rows = Db.list(
                        "select to_char(d, 'YYYY-MM') as month, " +
                                "coalesce((select sum(total_amount) from sales where to_char(sold_on, 'YYYY-MM') = to_char(d, 'YYYY-MM')), 0) as sales, " +
                                "coalesce((select sum(amount) from expenses where to_char(spent_on, 'YYYY-MM') = to_char(d, 'YYYY-MM')), 0) as expenses " +
                                "from generate_series(?::date, ?::date, '1 month'::interval) d " +
                                "order by month desc", fromDate, toDate);
                for (Map<String, Object> r : rows) {
                    BigDecimal s = new BigDecimal(r.get("sales").toString());
                    BigDecimal e = new BigDecimal(r.get("expenses").toString());
                    writer.printf("%s,%.2f,%.2f,%.2f%n", r.get("month"), s, e, s.subtract(e));
                }
            } else if ("care".equalsIgnoreCase(reportType)) {
                writer.println("Activity Type,Count,First Date,Last Date");
                List<Map<String, Object>> rows = Db.list(
                        "select activity_type, count(*) as count, min(performed_on) as first_date, max(performed_on) as last_date " +
                                "from care_logs where performed_on between ? and ? group by activity_type order by count desc",
                        fromDate, toDate);
                for (Map<String, Object> r : rows) {
                    writer.printf("%s,%s,%s,%s%n", r.get("activity_type"), r.get("count"), r.get("first_date"), r.get("last_date"));
                }
            } else {
                writer.println("Tree Type,Category,Unit,Harvest Count,Total Quantity");
                List<Map<String, Object>> rows = Db.list(
                        "select tt.name as type_name, c.name as category_name, h.unit, " +
                                "count(h.id) as harvest_count, sum(h.quantity) as total_quantity " +
                                "from harvests h " +
                                "join trees t on h.tree_id = t.id " +
                                "join tree_types tt on t.tree_type_id = tt.id " +
                                "join categories c on tt.category_id = c.id " +
                                "where h.harvested_on between ? and ? " +
                                "group by tt.name, c.name, h.unit order by total_quantity desc",
                        fromDate, toDate);
                for (Map<String, Object> r : rows) {
                    writer.printf("\"%s\",\"%s\",%s,%s,%.2f%n",
                            r.get("type_name"), r.get("category_name"), r.get("unit"), r.get("harvest_count"),
                            new BigDecimal(r.get("total_quantity").toString()));
                }
            }
            writer.flush();
        }
    }
}
