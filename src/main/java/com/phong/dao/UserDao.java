package com.phong.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp; // Import Timestamp
import java.util.ArrayList;
import java.util.List;

import com.phong.entities.User;
import com.phong.helper.ConnectionProvider; // Import ConnectionProvider

public class UserDao {

	// No Connection field needed here anymore
	// private Connection con;

	// Default constructor
	public UserDao() {
		super();
	}

	/**
	 * Saves a new user record to the database.
	 * Manages its own database connection.
	 * Note: Table name "user" is enclosed in quotes because it's a reserved keyword in SQL.
	 *
	 * @param user The User object containing the data to save.
	 * @return true if the user was saved successfully, false otherwise.
	 */
	public boolean saveUser(User user) {
		boolean flag = false;
		// Enclose table name "user" in double quotes
		String query = "insert into \"user\"(name, email, password, phone, gender, address, city, pincode, state) values(?, ?, ?, ?, ?, ?, ?, ?, ?)";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, user.getUserName());
			psmt.setString(2, user.getUserEmail());
			psmt.setString(3, user.getUserPassword()); // Hash passwords in production!
			psmt.setString(4, user.getUserPhone());
			psmt.setString(5, user.getUserGender());
			psmt.setString(6, user.getUserAddress());
			psmt.setString(7, user.getUserCity());
			psmt.setString(8, user.getUserPincode());
			psmt.setString(9, user.getUserState());

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error saving user: " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Retrieves a User by their email and password.
	 * Manages its own database connection.
	 * Note: Table name "user" is enclosed in quotes.
	 *
	 * @param userEmail    The email of the user.
	 * @param userPassword The password of the user.
	 * @return The User object if found and credentials match, null otherwise.
	 */
	public User getUserByEmailPassword(String userEmail, String userPassword) {
		User user = null;
		// Enclose table name "user" in double quotes
		String query = "select * from \"user\" where email = ? and password = ?"; // Consider hashed passwords

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, userEmail);
			psmt.setString(2, userPassword); // Compare hashed passwords in production

			try (ResultSet set = psmt.executeQuery()) {
				if (set.next()) {
					user = mapResultSetToUser(set); // Use helper method
				}
			} // ResultSet 'set' is automatically closed here

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting user by email/password: " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return user;
	}

	/**
	 * Retrieves a list of all users from the database.
	 * Manages its own database connection.
	 * Note: Table name "user" is enclosed in quotes.
	 *
	 * @return A List of User objects, which may be empty.
	 */
	public List<User> getAllUser() {
		List<User> list = new ArrayList<>();
		// Enclose table name "user" in double quotes
		String query = "select * from \"user\"";

		try (Connection con = ConnectionProvider.getConnection();
			 Statement statement = con.createStatement();
			 ResultSet set = statement.executeQuery(query)) {

			while (set.next()) {
				User user = mapResultSetToUser(set); // Use helper method
				list.add(user);
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting all users: " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return list;
	}

	/**
	 * Updates the address details for a given user.
	 * Manages its own database connection.
	 * Note: Table name "user" is enclosed in quotes.
	 *
	 * @param user The User object containing the updated address and the userId.
	 * @return true if the update was successful, false otherwise.
	 */
	public boolean updateUserAddresss(User user) {
		boolean flag = false;
		// Enclose table name "user" in double quotes
		String query = "update \"user\" set address = ?, city = ?, pincode = ?, state = ? where userid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, user.getUserAddress());
			psmt.setString(2, user.getUserCity());
			psmt.setString(3, user.getUserPincode());
			psmt.setString(4, user.getUserState());
			psmt.setInt(5, user.getUserId());

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error updating user address for user ID " + user.getUserId() + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Updates the password for a user identified by email.
	 * Manages its own database connection.
	 * Note: Table name "user" is enclosed in quotes.
	 *
	 * @param password The new password (should be hashed before calling this method).
	 * @param mail     The email address of the user whose password needs updating.
	 * @return true if the update was successful, false otherwise.
	 */
	public boolean updateUserPasswordByEmail(String password, String mail) {
		boolean flag = false;
		// Enclose table name "user" in double quotes
		String query = "update \"user\" set password = ? where email = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, password); // Store hashed password
			psmt.setString(2, mail);

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error updating password for email " + mail + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Updates user details (excluding password and registration date).
	 * Manages its own database connection.
	 * Note: Table name "user" is enclosed in quotes.
	 *
	 * @param user The User object containing the updated details and the userId.
	 * @return true if the update was successful, false otherwise.
	 */
	public boolean updateUser(User user) {
		boolean flag = false;
		// Enclose table name "user" in double quotes
		String query = "update \"user\" set name = ?, email = ?, phone = ?, gender = ?, address = ?, city = ?, pincode = ?, state = ? where userid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, user.getUserName());
			psmt.setString(2, user.getUserEmail());
			psmt.setString(3, user.getUserPhone());
			psmt.setString(4, user.getUserGender());
			psmt.setString(5, user.getUserAddress());
			psmt.setString(6, user.getUserCity());
			psmt.setString(7, user.getUserPincode());
			psmt.setString(8, user.getUserState());
			psmt.setInt(9, user.getUserId());

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error updating user details for user ID " + user.getUserId() + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Counts the total number of users in the database.
	 * Manages its own database connection.
	 * Note: Table name "user" is enclosed in quotes.
	 *
	 * @return The total number of users, or 0 if an error occurs.
	 */
	public int userCount() {
		int count = 0;
		// Enclose table name "user" in double quotes
		String query = "select count(*) from \"user\"";

		try (Connection con = ConnectionProvider.getConnection();
			 Statement stmt = con.createStatement();
			 ResultSet rs = stmt.executeQuery(query)) {

			// Check if a result was returned (should always be one row for count(*))
			if (rs.next()) {
				count = rs.getInt(1);
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error counting users: " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return count;
	}

	// --- Helper method to get single fields, handling potential null results ---

	private String getUserFieldById(int uid, String fieldName, String query) {
		String value = null; // Return null if not found or error
		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, uid);

			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // Check if user exists
					value = rs.getString(fieldName); // Get by column name
				}
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting field '" + fieldName + "' for user ID " + uid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return value;
	}


	/**
	 * Gets the full formatted address for a user.
	 * Manages its own database connection.
	 * Note: Table name "user" is enclosed in quotes.
	 *
	 * @param uid The ID of the user.
	 * @return The formatted address string, or null if user not found or error occurs.
	 */
	public String getUserAddress(int uid) {
		String address = null;
		// Enclose table name "user" in double quotes
		String query = "select address, city, pincode, state from \"user\" where userid = ?";
		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, uid);

			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // Check if user exists
					address = rs.getString("address") + ", " + rs.getString("city") + "-" + rs.getString("pincode") + ", " + rs.getString("state");
				}
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting address for user ID " + uid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return address;
	}

	/**
	 * Gets the name for a user.
	 * Manages its own database connection.
	 * Note: Table name "user" is enclosed in quotes.
	 *
	 * @param uid The ID of the user.
	 * @return The user's name, or null if user not found or error occurs.
	 */
	public String getUserName(int uid) {
		// Enclose table name "user" in double quotes
		String query = "select name from \"user\" where userid = ?";
		return getUserFieldById(uid, "name", query);
	}

	/**
	 * Gets the email for a user.
	 * Manages its own database connection.
	 * Note: Table name "user" is enclosed in quotes.
	 *
	 * @param uid The ID of the user.
	 * @return The user's email, or null if user not found or error occurs.
	 */
	public String getUserEmail(int uid) {
		// Enclose table name "user" in double quotes
		String query = "select email from \"user\" where userid = ?";
		return getUserFieldById(uid, "email", query);
	}

	/**
	 * Gets the phone number for a user.
	 * Manages its own database connection.
	 * Note: Table name "user" is enclosed in quotes.
	 *
	 * @param uid The ID of the user.
	 * @return The user's phone number, or null if user not found or error occurs.
	 */
	public String getUserPhone(int uid) {
		// Enclose table name "user" in double quotes
		String query = "select phone from \"user\" where userid = ?";
		return getUserFieldById(uid, "phone", query);
	}

	/**
	 * Deletes a user by their ID.
	 * Manages its own database connection.
	 * Note: Table name "user" is enclosed in quotes.
	 *
	 * @param uid The ID of the user to delete.
	 * @return true if the user was deleted successfully, false otherwise.
	 */
	public boolean deleteUser(int uid) {
		boolean flag = false;
		// Enclose table name "user" in double quotes
		String query = "delete from \"user\" where userid = ?";
		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, uid);
			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error deleting user ID " + uid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Retrieves a list of all user emails from the database.
	 * Manages its own database connection.
	 * Note: Table name "user" is enclosed in quotes.
	 *
	 * @return A List of email strings, which may be empty.
	 */
	public List<String> getAllEmail() {
		List<String> list = new ArrayList<>();
		// Enclose table name "user" in double quotes
		String query = "select email from \"user\"";

		try (Connection con = ConnectionProvider.getConnection();
			 Statement statement = con.createStatement();
			 ResultSet set = statement.executeQuery(query)) {

			while (set.next()) {
				list.add(set.getString("email")); // Get by column name
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting all emails: " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return list;
	}

	// --- Helper method to map ResultSet row to User object ---
	private User mapResultSetToUser(ResultSet set) throws SQLException {
		User user = new User();
		user.setUserId(set.getInt("userid"));
		user.setUserName(set.getString("name"));
		user.setUserEmail(set.getString("email"));
		user.setUserPassword(set.getString("password")); // Be cautious with plain text passwords
		user.setUserPhone(set.getString("phone"));
		user.setUserGender(set.getString("gender"));
		// Handle potential null Timestamp for registerdate if column allows nulls
		Timestamp ts = set.getTimestamp("registerdate");
		if (ts != null) {
			user.setDateTime(ts);
		}
		user.setUserAddress(set.getString("address"));
		user.setUserCity(set.getString("city"));
		user.setUserPincode(set.getString("pincode"));
		user.setUserState(set.getString("state"));
		return user;
	}
}