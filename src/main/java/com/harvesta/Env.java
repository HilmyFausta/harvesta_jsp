package com.harvesta;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Reads configuration from environment variables, falling back to .env in the working directory or parent.
 */
public final class Env {

    private static final Map<String, String> DOTENV = new HashMap<>();

    static {
        loadDotenv(new File(".env"));
        if (DOTENV.isEmpty()) {
            loadDotenv(new File("../.env"));
        }
    }

    private Env() {}

    private static void loadDotenv(File file) {
        if (!file.exists() || !file.isFile()) {
            return;
        }
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) {
                    continue;
                }
                int idx = line.indexOf('=');
                if (idx > 0) {
                    String key = line.substring(0, idx).trim();
                    String val = line.substring(idx + 1).trim();
                    if ((val.startsWith("\"") && val.endsWith("\"")) || (val.startsWith("'") && val.endsWith("'"))) {
                        val = val.substring(1, val.length() - 1);
                    }
                    DOTENV.put(key, val);
                }
            }
        } catch (IOException ignored) {}
    }

    public static String get(String key, String def) {
        String val = System.getenv(key);
        if (val != null && !val.isBlank()) {
            return val;
        }
        val = System.getProperty(key);
        if (val != null && !val.isBlank()) {
            return val;
        }
        val = DOTENV.get(key);
        if (val != null && !val.isBlank()) {
            return val;
        }
        return def;
    }

    public static String get(String key) {
        return get(key, "");
    }

    public static int getInt(String key, int def) {
        String v = get(key, "");
        if (v.isBlank()) return def;
        try {
            return Integer.parseInt(v);
        } catch (NumberFormatException e) {
            return def;
        }
    }

    public static boolean getBool(String key, boolean def) {
        String v = get(key, "");
        if (v.isBlank()) return def;
        return Boolean.parseBoolean(v) || "1".equals(v);
    }
}
