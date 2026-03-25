package com.bascode.util;

import com.bascode.model.enums.Role;

import java.time.Year;

public final class AgeEligibility {

    public static final int MINIMUM_AGE = 18;

    private AgeEligibility() {
    }

    public static boolean isAtLeast18(int birthYear) {
        return currentYear() - birthYear >= MINIMUM_AGE;
    }

    public static boolean requiresAdultStatus(Role role) {
        return Role.VOTER.equals(role) || Role.CONTESTER.equals(role);
    }

    public static int minimumBirthYear() {
        return currentYear() - MINIMUM_AGE;
    }

    public static String registrationRefusalMessage(Role role) {
        return roleLabel(role) + " must be at least 18 years old to register (born in "
                + minimumBirthYear() + " or earlier).";
    }

    public static String loginRefusalMessage(Role role) {
        return roleLabel(role) + " must be at least 18 years old. Access denied.";
    }

    public static String votingRefusalMessage() {
        return "Voters must be at least 18 years old to vote.";
    }

    public static String contesterRefusalMessage() {
        return "Contesters must be at least 18 years old to register.";
    }

    private static int currentYear() {
        return Year.now().getValue();
    }

    private static String roleLabel(Role role) {
        if (Role.CONTESTER.equals(role)) {
            return "Contesters";
        }
        if (Role.VOTER.equals(role)) {
            return "Voters";
        }
        return "Users";
    }
}
