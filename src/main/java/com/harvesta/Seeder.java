package com.harvesta;

import org.mindrot.jbcrypt.BCrypt;

import java.io.InputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

/**
 * Seeds an empty database on startup (PRD 6.4): accounts, master data,
 * and 12 months of deterministic demo data.
 */
public final class Seeder {

    private static final Object[][] CATEGORIES = {
            {"Fruit", "Trees grown mainly for their edible fruit.",
                    new String[][]{{"Durian", "Durio zibethinus"}, {"Mango", "Mangifera indica"},
                            {"Rambutan", "Nephelium lappaceum"}, {"Avocado", "Persea americana"}}},
            {"Timber", "Trees grown for wood and long-term investment.",
                    new String[][]{{"Teak", "Tectona grandis"}, {"Mahogany", "Swietenia macrophylla"},
                            {"Albizia", "Falcataria falcata"}}},
            {"Ornamental", "Trees planted for shade and landscaping.",
                    new String[][]{{"Frangipani", "Plumeria rubra"}, {"Flame Tree", "Delonix regia"}}},
            {"Spice", "Trees that produce spices.",
                    new String[][]{{"Clove", "Syzygium aromaticum"}, {"Nutmeg", "Myristica fragrans"}}},
    };

    private static final Object[][] BLOCKS = {
            {"North Block", "12500.00", "Next to the main gate.", "Mostly mature fruit trees."},
            {"East Block", "9800.00", "On the slope behind the storage shed.", "Mixed timber and spice trees."},
            {"River Block", "7200.50", "Along the irrigation canal.", "Young trees and new plantings."},
    };

    private static final Map<String, Object[]> HARVESTABLE = Map.of(
            "Durian", new Object[]{"pcs", 45000, 90000},
            "Mango", new Object[]{"kg", 15000, 25000},
            "Rambutan", new Object[]{"kg", 10000, 18000},
            "Avocado", new Object[]{"kg", 20000, 35000},
            "Clove", new Object[]{"kg", 90000, 130000},
            "Nutmeg", new Object[]{"kg", 70000, 110000});

    private static final Object[][] EXPENSES = {
            {"fertilizer", 300000, 2000000, "NPK and organic compost"},
            {"pesticide", 150000, 1000000, "Insecticide spray"},
            {"labor", 1000000, 3500000, "Weekly wages for field workers"},
            {"equipment", 200000, 5000000, "Pruning shears and ladders"},
            {"water", 100000, 600000, "Irrigation pump fuel and maintenance"},
            {"transport", 100000, 800000, "Delivery to the wholesale market"},
            {"other", 50000, 500000, "Miscellaneous supplies"},
    };

    private static final String[] BUYERS = {
            "Fresh Harvest Market", "Green Valley Grocers", "Sunrise Fruit Stall",
            "Nusantara Spice Traders", "City Juice Bar", "Local Cooperative",
    };

    private final Random random = new Random(20261028);
    private final LocalDate today = LocalDate.now();
    private List<Long> userIds;

    private Seeder() {}

    public static void run() {
        if (Db.count("select count(*) from users") == 0) {
            Db.tx(() -> {
                account("ADMIN", "Admin", "admin@example.com", "admin");
                account("STAFF", "Field Staff", "staff@example.com", "staff");
                account("VIEWER", "Guest Viewer", "viewer@example.com", "viewer");
            });
        }

        if (Db.count("select count(*) from categories") == 0) {
            Db.tx(Seeder::seedMaster);
        }

        if (Env.getBool("SEED_DEMO_DATA", true) && Db.count("select count(*) from trees") == 0) {
            Db.tx(() -> new Seeder().seedDemo());
        }
    }

    private static void account(String roleUpper, String defaultName, String defaultEmail, String role) {
        String email = Env.get("SEED_" + roleUpper + "_EMAIL", defaultEmail);
        String pass = Env.get("SEED_" + roleUpper + "_PASSWORD", "password");
        if (pass == null || pass.isBlank()) pass = "password";
        String hash = BCrypt.hashpw(pass, BCrypt.gensalt(10));
        Db.insert("insert into users (name, email, password, role) values (?, ?, ?, ?)",
                defaultName, email, hash, role);
    }

    private static void seedMaster() {
        for (Object[] cat : CATEGORIES) {
            String cName = (String) cat[0];
            String cDesc = (String) cat[1];
            long cId = Db.insert("insert into categories (name, description) values (?, ?)", cName, cDesc);
            String[][] types = (String[][]) cat[2];
            for (String[] t : types) {
                Db.insert("insert into tree_types (category_id, name, scientific_name) values (?, ?, ?)",
                        cId, t[0], t[1]);
            }
        }
        for (Object[] b : BLOCKS) {
            Db.insert("insert into blocks (name, area_sqm, location_note, description) values (?, ?::numeric, ?, ?)",
                    b[0], b[1], b[2], b[3]);
        }
    }

    private void seedDemo() {
        userIds = Db.list("select id from users").stream()
                .map(r -> ((Number) r.get("id")).longValue()).toList();
        List<Long> blockIds = Db.list("select id from blocks").stream()
                .map(r -> ((Number) r.get("id")).longValue()).toList();
        List<Map<String, Object>> types = Db.list("select id, name from tree_types");

        Map<String, byte[]> photoCache = loadPhotos();

        int treeIndex = 0;
        List<Long> fruitTreeIds = new ArrayList<>();
        List<String> fruitNames = new ArrayList<>();

        for (Map<String, Object> t : types) {
            long typeId = ((Number) t.get("id")).longValue();
            String name = (String) t.get("name");
            int perType = switch (name) {
                case "Durian", "Mango" -> 6;
                case "Rambutan", "Avocado", "Teak", "Mahogany" -> 4;
                default -> 3;
            };

            for (int i = 0; i < perType; i++) {
                treeIndex++;
                String code = String.format("T-%04d", treeIndex);
                long blockId = blockIds.get(random.nextInt(blockIds.size()));
                long user = anyUser();
                LocalDate planted = today.minusDays(90 + random.nextInt(1000));
                String status = pickStatus(planted);
                BigDecimal height = BigDecimal.valueOf(80 + random.nextInt(320));

                byte[] photo = photoCache.get(slug(name));
                long treeId;
                if (photo != null) {
                    treeId = Db.insert(
                            "insert into trees (code, tree_type_id, block_id, created_by, planted_on, status, height_cm, photo, photo_type) " +
                                    "values (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                            code, typeId, blockId, user, planted, status, height, photo, "image/jpeg");
                } else {
                    treeId = Db.insert(
                            "insert into trees (code, tree_type_id, block_id, created_by, planted_on, status, height_cm) " +
                                    "values (?, ?, ?, ?, ?, ?, ?)",
                            code, typeId, blockId, user, planted, status, height);
                }

                seedCareLogs(treeId, planted, "dead".equals(status));

                if (HARVESTABLE.containsKey(name) && "productive".equals(status)) {
                    fruitTreeIds.add(treeId);
                    fruitNames.add(name);
                }
            }
        }

        seedHarvestsAndSales(fruitTreeIds, fruitNames);
        seedExpenses(blockIds);
    }

    private void seedCareLogs(long treeId, LocalDate planted, boolean isDead) {
        String[] acts = Options.ACTIVITY_TYPES.keySet().toArray(String[]::new);
        int count = 2 + random.nextInt(4);
        for (int i = 0; i < count; i++) {
            LocalDate performed = planted.plusDays(random.nextInt(Math.max(1, (int) (today.toEpochDay() - planted.toEpochDay()))));
            if (performed.isAfter(today)) performed = today;
            LocalDate nextDue = (isDead || random.nextBoolean()) ? null : performed.plusDays(14 + random.nextInt(60));
            String act = acts[random.nextInt(acts.length)];
            Db.insert("insert into care_logs (tree_id, user_id, activity_type, performed_on, next_due_on, notes) " +
                    "values (?, ?, ?, ?, ?, ?)", treeId, anyUser(), act, performed, nextDue, "Routine " + act);
        }
    }

    private void seedHarvestsAndSales(List<Long> treeIds, List<String> names) {
        for (int i = 0; i < treeIds.size(); i++) {
            long treeId = treeIds.get(i);
            String name = names.get(i);
            Object[] rule = HARVESTABLE.get(name);
            String unit = (String) rule[0];
            int minP = (int) rule[1];
            int maxP = (int) rule[2];

            int harvestCount = 1 + random.nextInt(3);
            for (int h = 0; h < harvestCount; h++) {
                LocalDate harvested = today.minusDays(random.nextInt(300));
                double qty = "pcs".equals(unit) ? (10 + random.nextInt(40)) : (15 + random.nextInt(85));
                BigDecimal quantity = BigDecimal.valueOf(qty).setScale(2, RoundingMode.HALF_UP);
                String[] grades = {"premium", "good", "fair"};
                String grade = grades[random.nextInt(grades.length)];

                long harvestId = Db.insert(
                        "insert into harvests (tree_id, user_id, harvested_on, quantity, unit, grade, notes) " +
                                "values (?, ?, ?, ?, ?, ?, ?)",
                        treeId, anyUser(), harvested, quantity, unit, grade, "Harvest from " + name);

                if (random.nextInt(10) < 7) {
                    double soldQtyVal = qty * (0.4 + random.nextDouble() * 0.5);
                    if ("pcs".equals(unit)) soldQtyVal = Math.floor(soldQtyVal);
                    BigDecimal soldQty = BigDecimal.valueOf(Math.max(1.0, soldQtyVal)).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal price = BigDecimal.valueOf(minP + random.nextInt(maxP - minP));
                    BigDecimal total = soldQty.multiply(price).setScale(2, RoundingMode.HALF_UP);
                    LocalDate soldOn = harvested.plusDays(random.nextInt(5));
                    if (soldOn.isAfter(today)) soldOn = today;
                    String buyer = BUYERS[random.nextInt(BUYERS.length)];

                    Db.insert("insert into sales (harvest_id, user_id, buyer_name, sold_on, quantity, unit_price, total_amount) " +
                            "values (?, ?, ?, ?, ?, ?, ?)",
                            harvestId, anyUser(), buyer, soldOn, soldQty, price, total);
                }
            }
        }
    }

    private void seedExpenses(List<Long> blockIds) {
        for (int m = 0; m < 12; m++) {
            LocalDate monthDate = today.minusMonths(m);
            for (Object[] spec : EXPENSES) {
                if (random.nextBoolean()) {
                    String cat = (String) spec[0];
                    int min = (int) spec[1];
                    int max = (int) spec[2];
                    String desc = (String) spec[3];
                    BigDecimal amount = BigDecimal.valueOf(min + random.nextInt(max - min));
                    Long blockId = random.nextBoolean() ? blockIds.get(random.nextInt(blockIds.size())) : null;
                    LocalDate spent = monthDate.withDayOfMonth(1 + random.nextInt(25));
                    if (spent.isAfter(today)) spent = today;

                    Db.insert("insert into expenses (block_id, user_id, category, amount, spent_on, description) " +
                            "values (?, ?, ?, ?, ?, ?)", blockId, anyUser(), cat, amount, spent, desc);
                }
            }
        }
    }

    private String pickStatus(LocalDate planted) {
        long days = today.toEpochDay() - planted.toEpochDay();
        if (days < 180) return "seedling";
        if (days < 500) return "growing";
        int r = random.nextInt(10);
        if (r < 7) return "productive";
        if (r < 9) return "needs_attention";
        return "dead";
    }

    private long anyUser() {
        return userIds.get(random.nextInt(userIds.size()));
    }

    private Map<String, byte[]> loadPhotos() {
        Map<String, byte[]> photos = new HashMap<>();
        String[] files = {"albizia", "avocado", "clove", "durian", "flame-tree", "frangipani",
                "mahogany", "mango", "nutmeg", "rambutan", "teak"};
        for (String f : files) {
            try (InputStream in = getClass().getResourceAsStream("/seed-photos/" + f + ".jpg")) {
                if (in != null) {
                    photos.put(f, in.readAllBytes());
                }
            } catch (Exception ignored) {}
        }
        return photos;
    }

    private String slug(String name) {
        return name.toLowerCase().replace(' ', '-');
    }
}
