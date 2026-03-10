package com.bascode.service;

import java.time.Year;

import org.mindrot.jbcrypt.BCrypt;

import com.bascode.dao.UserDao;
import com.bascode.model.entity.User;

public class UserService {

    private final UserDao userDao;

    public UserService(UserDao userDao) {
        this.userDao = userDao;
    }

    public User getUserById(Long userId) {
        return userDao.findById(userId).orElse(null);
    }

    public String updateProfile(Long userId, String firstName, String lastName, String email, String birthYear,
            String state, String country) {

        User user = getUserById(userId);
        if (user == null) {
            return "User not found.";
        }

        firstName = trim(firstName);
        lastName = trim(lastName);
        email = trim(email);
        state = trim(state);
        country = trim(country);

        if (isBlank(firstName) || isBlank(lastName) || isBlank(email)) {
            return "First name, last name, and email are required.";
        }

        User existingEmailUser = userDao.findByEmail(email).orElse(null);
        if (existingEmailUser != null && !existingEmailUser.getId().equals(userId)) {
            return "Email is already used by another account.";
        }

        int parsedBirthYear = parseBirthYear(birthYear);
        if (parsedBirthYear == Integer.MIN_VALUE) {
            return "Birth year must be a valid year.";
        }

        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setBirthYear(parsedBirthYear);
        user.setState(state);
        user.setCountry(country);

        userDao.update(user);
        return null;
    }

    public String changePassword(Long userId, String currentPassword, String newPassword, String confirmPassword) {
        User user = getUserById(userId);
        if (user == null) {
            return "User not found.";
        }

        if (isBlank(currentPassword) || isBlank(newPassword) || isBlank(confirmPassword)) {
            return "All password fields are required.";
        }

        if (!newPassword.equals(confirmPassword)) {
            return "New password and confirm password do not match.";
        }

        if (newPassword.length() < 8) {
            return "New password must be at least 8 characters.";
        }

        if (isBlank(user.getPasswordHash()) || !BCrypt.checkpw(currentPassword, user.getPasswordHash())) {
            return "Current password is incorrect.";
        }

        user.setPasswordHash(BCrypt.hashpw(newPassword, BCrypt.gensalt()));
        userDao.update(user);
        return null;
    }

    private int parseBirthYear(String birthYear) {
        if (isBlank(birthYear)) {
            return 0;
        }

        try {
            int year = Integer.parseInt(birthYear.trim());
            int currentYear = Year.now().getValue();
            if (year < 1900 || year > currentYear) {
                return Integer.MIN_VALUE;
            }
            return year;
        } catch (NumberFormatException ex) {
            return Integer.MIN_VALUE;
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
