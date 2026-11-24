package com.harvesta;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Map;

/**
 * Service enforcing sales business logic (PRD 5.9).
 */
public final class SaleService {

    private SaleService() {}

    /**
     * Calculates total amount: quantity * unit_price
     */
    public static BigDecimal calculateTotal(BigDecimal quantity, BigDecimal unitPrice) {
        if (quantity == null || unitPrice == null) {
            return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        }
        return quantity.multiply(unitPrice).setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Gets unsold quantity remaining for a harvest, optionally excluding a specific sale (during edit).
     */
    public static BigDecimal remainingQuantity(long harvestId, Long excludeSaleId) {
        Map<String, Object> h = Db.one("select quantity, unit from harvests where id = ?", harvestId);
        if (h == null) return BigDecimal.ZERO;

        BigDecimal total = new BigDecimal(h.get("quantity").toString());

        String sql = "select coalesce(sum(quantity), 0) from sales where harvest_id = ?";
        Object[] params = excludeSaleId == null ? new Object[]{harvestId} : new Object[]{harvestId, excludeSaleId};
        if (excludeSaleId != null) {
            sql += " and id != ?";
        }

        Object soldObj = Db.value(sql, params);
        BigDecimal sold = soldObj == null ? BigDecimal.ZERO : new BigDecimal(soldObj.toString());

        BigDecimal rem = total.subtract(sold);
        return rem.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : rem;
    }
}
