package com.phong.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.phong.entities.Admin;
import com.phong.entities.User;
import com.phong.helper.ConnectionProvider; // Import ConnectionProvider

public class AdminDao {

	// No need to store Connection object here anymore
	// private Connection con;

	// Default constructor
	public AdminDao() {
		super();
	}

	/**
	 * Saves a new admin record to the database.
	 * Manages its own database connection.
	 *
	 * @param admin The Admin object containing the data to save.
	 * @return true if the admin was saved successfully, false otherwise.
	 */
	public boolean saveAdmin(Admin admin) {
		boolean flag = false;
		// SQL query using placeholders
		String query = "insert into admin(name, email, password, phone) values(?, ?, ?, ?)";

		// Use try-with-resources for Connection and PreparedStatement
		// These resources will be automatically closed at the end of the block
		try (Connection con = ConnectionProvider.getConnection(); // Get connection from provider
			 PreparedStatement psmt = con.prepareStatement(query)) {

			// Set parameters for the prepared statement
			psmt.setString(1, admin.getName());
			psmt.setString(2, admin.getEmail());
			psmt.setString(3, admin.getPassword()); // Consider hashing passwords before saving
			psmt.setString(4, admin.getPhone());

			// Execute the update
			int rowsAffected = psmt.executeUpdate();

			// Check if the insert was successful (at least one row affected)
			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			// Log the exception properly in a real application instead of just printing stack trace
			System.err.println("Error saving admin: " + e.getMessage());
			e.printStackTrace();
		}
		// Connection and PreparedStatement are guaranteed to be closed here
		return flag;
	}

	/**
	 * Retrieves an Admin by their email and password.
	 * Manages its own database connection.
	 *
	 * @param email    The email of the admin.
	 * @param password The password of the admin.
	 * @return The Admin object if found and credentials match, null otherwise.
	 */
	public Admin getAdminByEmailPassword(String email, String password) {
		Admin admin = null;
		String query = "select * from admin where email = ? and password = ?"; // Consider using hashed passwords

		// Use try-with-resources for Connection, PreparedStatement, and ResultSet
		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, email);
			psmt.setString(2, password);

			// Nested try-with-resources for the ResultSet
			try (ResultSet set = psmt.executeQuery()) {
				// Expecting only one admin or none
				if (set.next()) {
					admin = new Admin();
					admin.setId(set.getInt("id"));
					admin.setName(set.getString("name"));
					admin.setEmail(set.getString("email"));
					admin.setPassword(set.getString("password")); // Be cautious retrieving plain text passwords
					admin.setPhone(set.getString("phone"));
				}
			} // ResultSet 'set' is automatically closed here

		} catch (SQLException | ClassNotFoundException e) {
			// Log the exception properly
			System.err.println("Error getting admin by email/password: " + e.getMessage());
			e.printStackTrace();
		}
		// Connection and PreparedStatement are automatically closed here
		return admin;
	}


	/**
	 * Retrieves a Admin by their email address.
	 * Used for login checks before password verification and potentially for vendor checks.
	 * Manages its own database connection.
	 * Note: Table name "admin" is enclosed in quotes.
	 *
	 * @param adminEmail The email address to search for.
	 * @return The Admin object if found, null otherwise or on error.
	 */
	public Admin getAdminByEmail(String adminEmail) {
		Admin admin = null;
		// Enclose table name "admin" in double quotes
		String query = "select * from \"admin\" where email = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, adminEmail);

			try (ResultSet set = psmt.executeQuery()) {
				if (set.next()) { // Check if a user was found
					admin = new Admin();
					admin.setId(set.getInt("id"));
					admin.setName(set.getString("name"));
					admin.setEmail(set.getString("email"));
					admin.setPassword(set.getString("password")); // Be cautious retrieving plain text passwords
					admin.setPhone(set.getString("phone"));
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting user by email '" + adminEmail + "': " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return admin; // Return null if not found or error
	}

	/**
	 * Retrieves a list of all admins from the database.
	 * Manages its own database connection.
	 *
	 * @return A List of Admin objects, which may be empty.
	 */
	public List<Admin> getAllAdmin() {
		List<Admin> list = new ArrayList<>(); // Initialize the list immediately
		String query = "select * from admin";

		// Use try-with-resources for Connection, Statement, and ResultSet
		try (Connection con = ConnectionProvider.getConnection();
			 Statement statement = con.createStatement(); // Simple Statement is fine here
			 ResultSet rs = statement.executeQuery(query)) {

			// Iterate through the results
			while (rs.next()) {
				Admin admin = new Admin();
				admin.setId(rs.getInt("id"));
				admin.setName(rs.getString("name"));
				admin.setEmail(rs.getString("email"));
				admin.setPhone(rs.getString("phone"));
				admin.setPassword(rs.getString("password")); // Be cautious retrieving plain text passwords

				list.add(admin);
			}

		} catch (SQLException | ClassNotFoundException e) {
			// Log the exception properly
			System.err.println("Error getting all admins: " + e.getMessage());
			e.printStackTrace();
		}
		// Connection, Statement, and ResultSet are automatically closed here
		return list; // Return the list (possibly empty)
	}

	/**
	 * Deletes an admin by their ID.
	 * Manages its own database connection.
	 *
	 * @param id The ID of the admin to delete.
	 * @return true if the admin was deleted successfully, false otherwise.
	 */
	public boolean deleteAdmin(int id) {
		boolean flag = false;
		String query = "delete from admin where id = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, id);
			int rowsAffected = psmt.executeUpdate();

			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			// Log the exception properly
			System.err.println("Error deleting admin with ID " + id + ": " + e.getMessage());
			e.printStackTrace();
		}
		// Connection and PreparedStatement are automatically closed here
		return flag;
	}
}