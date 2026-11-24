package com.harvesta.web;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public final class Format {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd MMM yyyy", Locale.ENGLISH);

    private Format() {}

    public static String date(Object obj) {
        if (obj == null) return "—";
        if (obj instanceof LocalDate ld) return ld.format(DATE_FMT);
        if (obj instanceof LocalDateTime ldt) return ldt.toLocalDate().format(DATE_FMT);
        if (obj instanceof Date d) return d.toLocalDate().format(DATE_FMT);
        if (obj instanceof Timestamp ts) return ts.toLocalDateTime().toLocalDate().format(DATE_FMT);
        try {
            return LocalDate.parse(obj.toString()).format(DATE_FMT);
        } catch (Exception e) {
            return obj.toString();
        }
    }

    public static String number(Object obj, int decimals) {
        if (obj == null) return "—";
        try {
            double val = Double.parseDouble(obj.toString());
            DecimalFormatSymbols symbols = new DecimalFormatSymbols(Locale.US);
            symbols.setGroupingSeparator(',');
            symbols.setDecimalSeparator('.');
            String pattern = "#,##0" + (decimals > 0 ? "." + "0".repeat(decimals) : "");
            return new DecimalFormat(pattern, symbols).format(val);
        } catch (Exception e) {
            return obj.toString();
        }
    }

    public static String number(Object obj) {
        return number(obj, 2);
    }

    public static String money(Object obj) {
        if (obj == null) return "—";
        try {
            double val = Double.parseDouble(obj.toString());
            DecimalFormatSymbols symbols = new DecimalFormatSymbols(Locale.US);
            symbols.setGroupingSeparator(',');
            return "IDR " + new DecimalFormat("#,##0", symbols).format(val);
        } catch (Exception e) {
            return "IDR " + obj;
        }
    }
}
