package com.harvesta;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Shared option labels used by the JSP forms and lists.
 */
public final class Options {

    public static final Map<String, String> TREE_STATUSES = new LinkedHashMap<>();
    public static final Map<String, String> ACTIVITY_TYPES = new LinkedHashMap<>();
    public static final Map<String, String> HARVEST_UNITS = new LinkedHashMap<>();
    public static final Map<String, String> HARVEST_GRADES = new LinkedHashMap<>();
    public static final Map<String, String> EXPENSE_CATEGORIES = new LinkedHashMap<>();
    public static final Map<String, String> USER_ROLES = new LinkedHashMap<>();

    static {
        // Tree Status
        TREE_STATUSES.put("seedling", "Seedling");
        TREE_STATUSES.put("growing", "Growing");
        TREE_STATUSES.put("productive", "Productive");
        TREE_STATUSES.put("needs_attention", "Needs Attention");
        TREE_STATUSES.put("dead", "Dead");

        // Activity Type
        ACTIVITY_TYPES.put("watering", "Watering");
        ACTIVITY_TYPES.put("fertilizing", "Fertilizing");
        ACTIVITY_TYPES.put("pruning", "Pruning");
        ACTIVITY_TYPES.put("pest_control", "Pest Control");
        ACTIVITY_TYPES.put("disease_treatment", "Disease Treatment");
        ACTIVITY_TYPES.put("weeding", "Weeding");
        ACTIVITY_TYPES.put("inspection", "Inspection");
        ACTIVITY_TYPES.put("other", "Other");

        // Harvest Unit
        HARVEST_UNITS.put("kg", "Kilogram (kg)");
        HARVEST_UNITS.put("pcs", "Pieces (pcs)");

        // Harvest Grade
        HARVEST_GRADES.put("premium", "Premium (A)");
        HARVEST_GRADES.put("good", "Good (B)");
        HARVEST_GRADES.put("fair", "Fair (C)");
        HARVEST_GRADES.put("poor", "Poor (D)");

        // Expense Category
        EXPENSE_CATEGORIES.put("fertilizer", "Fertilizer");
        EXPENSE_CATEGORIES.put("pesticide", "Pesticide");
        EXPENSE_CATEGORIES.put("labor", "Labor");
        EXPENSE_CATEGORIES.put("equipment", "Equipment");
        EXPENSE_CATEGORIES.put("water", "Water & Irrigation");
        EXPENSE_CATEGORIES.put("transport", "Transport & Delivery");
        EXPENSE_CATEGORIES.put("other", "Other");

        // User Roles
        USER_ROLES.put("admin", "Admin");
        USER_ROLES.put("staff", "Field Staff");
        USER_ROLES.put("viewer", "Viewer");
    }

    private Options() {}

    public static String label(Map<String, String> map, String key) {
        if (key == null) return "";
        return map.getOrDefault(key.toLowerCase(), key);
    }
}
