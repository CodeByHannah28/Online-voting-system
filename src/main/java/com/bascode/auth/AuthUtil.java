package com.bascode.auth;

import org.mindrot.jbcrypt.BCrypt;

public class AuthUtil {
    public static String hashPassword(String plain) {
        return BCrypt.hashpw(plain, BCrypt.gensalt());
    }

    public static boolean checkPassword(String plain, String hash) {
        return BCrypt.checkpw(plain, hash);
    }
}
