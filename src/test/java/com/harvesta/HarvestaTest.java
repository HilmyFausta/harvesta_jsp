package com.harvesta;

import com.harvesta.web.Format;
import org.junit.jupiter.api.Test;
import org.mindrot.jbcrypt.BCrypt;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

public class HarvestaTest {

    @Test
    void testFormatMoney() {
        assertEquals("IDR 1,250,000", Format.money(new BigDecimal("1250000")));
        assertEquals("IDR 0", Format.money(BigDecimal.ZERO));
        assertEquals("—", Format.money(null));
    }

    @Test
    void testFormatNumber() {
        assertEquals("1,250,000.50", Format.number(new BigDecimal("1250000.50")));
        assertEquals("100.00", Format.number(100));
        assertEquals("—", Format.number(null));
    }

    @Test
    void testFormatDate() {
        LocalDate d = LocalDate.of(2026, 10, 21);
        assertEquals("21 Oct 2026", Format.date(d));

        LocalDateTime dt = LocalDateTime.of(2026, 10, 21, 14, 30);
        assertEquals("21 Oct 2026", Format.date(dt));

        assertEquals("—", Format.date((Object) null));
    }

    @Test
    void testBCrypt() {
        String pass = "password";
        String hashed = BCrypt.hashpw(pass, BCrypt.gensalt());
        assertTrue(BCrypt.checkpw(pass, hashed));
        assertFalse(BCrypt.checkpw("wrongpassword", hashed));
    }

    @Test
    void testOptionsLabels() {
        assertEquals("Productive", Options.label(Options.TREE_STATUSES, "productive"));
        assertEquals("Kilogram (kg)", Options.label(Options.HARVEST_UNITS, "kg"));
        assertEquals("Admin", Options.label(Options.USER_ROLES, "admin"));
        assertEquals("Field Staff", Options.label(Options.USER_ROLES, "staff"));
        assertEquals("Viewer", Options.label(Options.USER_ROLES, "viewer"));
    }
}
