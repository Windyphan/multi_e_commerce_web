package com.phong.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
// No need for Statement import if not used directly
// import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.phong.entities.Wishlist;
import com.phong.helper.ConnectionProvider; // Import ConnectionProvider

public class WishlistDao {

	// No Connection field needed
	// private Connection con;

	// Default constructor
	public WishlistDao() {
		super();
	}

	/**
	 * Adds a product to a user's wishlist.
	 * Manages its own database connection.
	 *
	 * @param w The Wishlist object containing userId and productId.
	 * @return true if the item was added successfully, false otherwise (e.g., DB error, duplicate entry if constraint exists).
	 */
	public boolean addToWishlist(Wishlist w) {
		boolean flag = false;
		// Consider adding a check here first: if (!getWishlist(w.getUserId(), w.getProductId())) { ... }
		// To avoid inserting duplicates if there's no unique constraint in the DB.
		String query = "insert into wishlist(iduser, idproduct) values(?,?)";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, w.getUserId());
			psmt.setInt(2, w.getProductId());

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			// Check if it's a duplicate entry error (vendor-specific SQLState or error code)
			// if (e instanceof SQLException && ((SQLException)e).getSQLState().equals("23505")) { // Example for PostgreSQL unique violation
			//     System.err.println("Info: Item already in wishlist for user " + w.getUserId() + ", product " + w.getProductId());
			//     // Optionally return true here if "already exists" counts as success for the caller
			// } else {
			System.err.println("Error adding to wishlist for user " + w.getUserId() + ", product " + w.getProductId() + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			// }
		}
		return flag;
	}

	/**
	 * Checks if a specific product exists in a specific user's wishlist.
	 * Manages its own database connection.
	 *
	 * @param uid The user ID.
	 * @param pid The product ID.
	 * @return true if the item exists in the wishlist, false otherwise (or if an error occurs).
	 */
	public boolean getWishlist(int uid, int pid) {
		boolean exists = false;
		// Select a constant value (1) for efficiency
		String query = "select 1 from wishlist where iduser = ? and idproduct = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, uid);
			psmt.setInt(2, pid);

			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // Check if any row was returned
					exists = true;
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error checking wishlist for user " + uid + ", product " + pid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			// Returns false on error
		}
		return exists;
	}

	/**
	 * Retrieves all wishlist items for a specific user.
	 * Manages its own database connection.
	 *
	 * @param uid The user ID.
	 * @return A List of Wishlist objects for the user, which may be empty. Returns null on major error.
	 */
	public List<Wishlist> getListByUserId(int uid) {
		List<Wishlist> list = new ArrayList<>();
		String query = "select * from wishlist where iduser = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, uid);

			try (ResultSet rs = psmt.executeQuery()) {
				while (rs.next()) {
					list.add(mapResultSetToWishlist(rs)); // Use helper method
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting wishlist items for user ID " + uid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			return null; // Indicate error
		}
		return list;
	}

	/**
	 * Deletes a specific product from a user's wishlist.
	 * Manages its own database connection.
	 *
	 * @param uid The user ID.
	 * @param pid The product ID.
	 * @return true if the item was deleted successfully (at least one row affected), false otherwise.
	 */
	public boolean deleteWishlist(int uid, int pid) {
		boolean flag = false;
		String query = "delete from wishlist where iduser = ? and idproduct = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, uid);
			psmt.setInt(2, pid);

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			} else {
				// Optional: Log if no item was found to delete
				System.err.println("Info: No wishlist item found to delete for user " + uid + ", product " + pid);
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error deleting from wishlist for user " + uid + ", product " + pid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	// --- Helper method to map ResultSet row to Wishlist object ---
	private Wishlist mapResultSetToWishlist(ResultSet rs) throws SQLException {
		Wishlist wishlist = new Wishlist();
		wishlist.setWishlistId(rs.getInt("idwishlist"));
		wishlist.setUserId(rs.getInt("iduser"));
		wishlist.setProductId(rs.getInt("idproduct"));
		return wishlist;
	}
}