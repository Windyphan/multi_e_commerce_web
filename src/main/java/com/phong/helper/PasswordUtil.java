package com.phong.helper;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

    // Higher workload factor increases security but takes longer to hash/check
    private static final int WORKLOAD = 12; // Recommended value (10-16)

    /**
     * Hashes a plain text password using BCrypt.
     * Generates a unique salt for each password.
     *
     * @param plainPassword The password to hash.
     * @return The BCrypt hash string (including salt) to store in the database.
     */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            // Decide how to handle empty passwords - throw exception or return null/empty?
            // Throwing exception is often better to prevent storing invalid state.
            throw new IllegalArgumentException("Password cannot be null or empty.");
        }
        // gensalt automatically generates a random salt with the specified workload
        String salt = BCrypt.gensalt(WORKLOAD);
        // hashpw performs the hashing using the generated salt
        return BCrypt.hashpw(plainPassword, salt);
    }

    /**
     * Checks if a provided plain text password matches a stored BCrypt hash.
     *
     * @param plainPassword  The password entered by the user during login.
     * @param hashedPassword The hash stored in the database (which includes the salt).
     * @return true if the password matches the hash, false otherwise.
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null || hashedPassword.isEmpty()) {
            return false; // Cannot compare against null/empty hash or with null password
        }
        try {
            // checkpw extracts the salt from hashedPassword and uses it to hash
            // plainPassword, then compares the results securely.
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            // Handle cases where the stored hash might not be a valid BCrypt hash
            System.err.println("WARN: Error checking password - likely invalid hash format: " + e.getMessage());
            return false;
        }
    }
}