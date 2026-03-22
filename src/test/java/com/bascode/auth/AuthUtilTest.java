package com.bascode.auth;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class AuthUtilTest {
    @Test
    public void testHashAndCheck() {
        String pwd = "TestPassword123!";
        String hash = AuthUtil.hashPassword(pwd);
        assertNotNull(hash);
        assertTrue(AuthUtil.checkPassword(pwd, hash));
        assertFalse(AuthUtil.checkPassword("wrong", hash));
    }
}
