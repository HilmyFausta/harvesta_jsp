package com.harvesta;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Proxy;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Supplier;

/**
 * Database helper using HikariCP and PostgreSQL.
 */
public final class Db {

    private static HikariDataSource ds;
    private static final ThreadLocal<Connection> TX_CONN = new ThreadLocal<>();

    private Db() {}

    public static synchronized void init() {
        if (ds != null && !ds.isClosed()) {
            return;
        }

        HikariConfig cfg = new HikariConfig();
        cfg.setDriverClassName("org.postgresql.Driver");

        String dbUrl = Env.get("DB_URL");
        if (dbUrl.isBlank()) {
            String host = Env.get("DB_HOST", "127.0.0.1");
            int port = Env.getInt("DB_PORT", 5432);
            String db = Env.get("DB_DATABASE", "harvesta");
            String ssl = Env.get("DB_SSLMODE", "prefer");
            dbUrl = "jdbc:postgresql://" + host + ":" + port + "/" + db + "?sslmode=" + ssl;
        }
        cfg.setJdbcUrl(dbUrl);
        cfg.setUsername(Env.get("DB_USERNAME", "harvesta"));
        cfg.setPassword(Env.get("DB_PASSWORD", "harvesta"));

        cfg.setMaximumPoolSize(10);
        cfg.setMinimumIdle(2);
        cfg.setIdleTimeout(30000);
        cfg.setConnectionTimeout(10000);

        ds = new HikariDataSource(cfg);

        // Run schema migrations
        runSchema();
    }

    public static synchronized void close() {
        if (ds != null && !ds.isClosed()) {
            ds.close();
        }
    }

    public static Connection getConnection() throws SQLException {
        if (ds == null) {
            init();
        }
        Connection tx = TX_CONN.get();
        if (tx != null) {
            return (Connection) Proxy.newProxyInstance(
                    Connection.class.getClassLoader(),
                    new Class<?>[]{Connection.class},
                    (proxy, method, args) -> {
                        if ("close".equals(method.getName()) && method.getParameterCount() == 0) {
                            return null;
                        }
                        try {
                            return method.invoke(tx, args);
                        } catch (InvocationTargetException e) {
                            throw e.getCause();
                        }
                    });
        }
        return ds.getConnection();
    }

    private static void runSchema() {
        try (InputStream in = Db.class.getResourceAsStream("/schema.sql")) {
            if (in == null) {
                throw new IllegalStateException("schema.sql was not found on the classpath.");
            }
            StringBuilder sb = new StringBuilder();
            try (BufferedReader r = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8))) {
                String line;
                while ((line = r.readLine()) != null) {
                    sb.append(line).append("\n");
                }
            }
            try (Connection conn = ds.getConnection(); Statement stmt = conn.createStatement()) {
                stmt.execute(sb.toString());
            }
        } catch (java.io.IOException | SQLException e) {
            throw new IllegalStateException("Failed to run schema.sql.", e);
        }
    }

    public static List<Map<String, Object>> list(String sql, Object... params) {
        try (Connection conn = getConnection();
             PreparedStatement ps = prepare(conn, sql, params);
             ResultSet rs = ps.executeQuery()) {
            return toList(rs);
        } catch (SQLException e) {
            throw new RuntimeException("Db.list failed: " + sql, e);
        }
    }

    public static List<Map<String, Object>> query(String sql, Object... params) {
        return list(sql, params);
    }

    public static Map<String, Object> one(String sql, Object... params) {
        List<Map<String, Object>> l = list(sql, params);
        return l.isEmpty() ? null : l.get(0);
    }

    public static Object value(String sql, Object... params) {
        try (Connection conn = getConnection();
             PreparedStatement ps = prepare(conn, sql, params);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getObject(1);
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Db.value failed: " + sql, e);
        }
    }

    public static long count(String sql, Object... params) {
        Object v = value(sql, params);
        if (v == null) return 0L;
        if (v instanceof Number n) return n.longValue();
        return Long.parseLong(v.toString());
    }

    public static int update(String sql, Object... params) {
        try (Connection conn = getConnection();
             PreparedStatement ps = prepare(conn, sql, params)) {
            return ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Db.update failed: " + sql, e);
        }
    }

    public static long insert(String sql, Object... params) {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bind(ps, params);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
            return 0L;
        } catch (SQLException e) {
            throw new RuntimeException("Db.insert failed: " + sql, e);
        }
    }

    public static void tx(Runnable action) {
        tx(() -> {
            action.run();
            return null;
        });
    }

    public static <T> T tx(Supplier<T> action) {
        if (TX_CONN.get() != null) {
            return action.get();
        }
        try (Connection conn = ds.getConnection()) {
            conn.setAutoCommit(false);
            TX_CONN.set(conn);
            try {
                T res = action.get();
                conn.commit();
                return res;
            } catch (Throwable t) {
                conn.rollback();
                if (t instanceof RuntimeException re) throw re;
                throw new RuntimeException(t);
            } finally {
                TX_CONN.remove();
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Transaction error", e);
        }
    }

    private static PreparedStatement prepare(Connection conn, String sql, Object... params) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(sql);
        bind(ps, params);
        return ps;
    }

    private static void bind(PreparedStatement ps, Object... params) throws SQLException {
        for (int i = 0; i < params.length; i++) {
            ps.setObject(i + 1, params[i]);
        }
    }

    private static List<Map<String, Object>> toList(ResultSet rs) throws SQLException {
        ResultSetMetaData md = rs.getMetaData();
        int cols = md.getColumnCount();
        List<Map<String, Object>> list = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> row = new LinkedHashMap<>();
            for (int i = 1; i <= cols; i++) {
                String label = md.getColumnLabel(i).toLowerCase();
                row.put(label, rs.getObject(i));
            }
            list.add(row);
        }
        return list;
    }
}
