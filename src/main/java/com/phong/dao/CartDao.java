package com.phong.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement; // Needed for removeAllProduct if kept
import java.util.ArrayList;
import java.util.List;

import com.phong.entities.Cart;
import com.phong.helper.ConnectionProvider; // Import ConnectionProvider

public class CartDao {

	// No Connection field needed
	// private Connection con;

	// Default constructor
	public CartDao() {
		super();
	}

	/**
	 * Adds a new item to the cart or potentially updates quantity if item exists
	 * (Current implementation only adds, does not check for existing item).
	 * Manages its own database connection.
	 *
	 * @param cart The Cart object containing user ID, product ID, and quantity.
	 * @return true if the item was added successfully, false otherwise.
	 */
	public boolean addToCart(Cart cart) {
		boolean flag = false;
		// TODO: Consider logic here to check if the item (uid, pid) already exists.
		// If it exists, should it update the quantity instead of inserting a new row?
		// Current implementation inserts a new row regardless.

		String query = "insert into cart(uid, pid, quantity) values(?,?,?)";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, cart.getUserId());
			psmt.setInt(2, cart.getProductId());
			psmt.setInt(3, cart.getQuantity());

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error adding item to cart for user ID " + cart.getUserId() + ", product ID " + cart.getProductId() + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Retrieves all cart items for a specific user.
	 * Manages its own database connection.
	 *
	 * @param uid The user ID.
	 * @return A List of Cart objects for the user, which may be empty. Returns null if a major error occurs.
	 */
	public List<Cart> getCartListByUserId(int uid) {
		List<Cart> list = new ArrayList<>();
		String query = "select * from cart where uid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, uid);

			try (ResultSet rs = psmt.executeQuery()) {
				while (rs.next()) {
					Cart cart = new Cart();
					cart.setCartId(rs.getInt("id"));
					cart.setUserId(rs.getInt("uid"));
					cart.setProductId(rs.getInt("pid"));
					cart.setQuantity(rs.getInt("quantity"));
					list.add(cart);
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting cart list for user ID " + uid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			return null; // Indicate error by returning null, or return empty list? Consistent approach needed.
		}
		return list; // Return the list (possibly empty)
	}

	/**
	 * Gets the quantity of a specific product in a specific user's cart.
	 * Manages its own database connection.
	 *
	 * @param uid The user ID.
	 * @param pid The product ID.
	 * @return The quantity if the item exists, or 0 if not found or error occurs.
	 */
	public int getQuantity(int uid, int pid) {
		int qty = 0;
		String query = "select quantity from cart where uid = ? and pid = ?"; // Select only quantity

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, uid);
			psmt.setInt(2, pid);

			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // Check if the item exists
					qty = rs.getInt("quantity");
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting quantity for user ID " + uid + ", product ID " + pid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			// Returns 0 in case of error
		}
		return qty;
	}

	/**
	 * Gets the quantity of a cart item by its primary key (cart ID).
	 * Manages its own database connection.
	 *
	 * @param id The primary key (id) of the cart item.
	 * @return The quantity if the item exists, or 0 if not found or error occurs.
	 */
	public int getQuantityById(int id) {
		int qty = 0;
		String query = "select quantity from cart where id = ?"; // Select only quantity

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, id);
			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // Check if the item exists
					qty = rs.getInt("quantity");
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting quantity for cart ID " + id + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			// Returns 0 in case of error
		}
		return qty;
	}

	/**
	 * Updates the quantity of a specific cart item identified by its primary key (cart ID).
	 * Manages its own database connection.
	 *
	 * @param id  The primary key (id) of the cart item to update.
	 * @param qty The new quantity.
	 * @return true if the update was successful (row affected), false otherwise.
	 */
	public boolean updateQuantity(int id, int qty) {
		boolean flag = false;
		String query = "update cart set quantity = ? where id = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, qty);
			psmt.setInt(2, id);

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error updating quantity for cart ID " + id + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Removes a specific product (cart item) by its primary key (cart ID).
	 * Manages its own database connection.
	 *
	 * @param cid The primary key (id) of the cart item to remove.
	 * @return true if the removal was successful (row affected), false otherwise.
	 */
	public boolean removeProduct(int cid) {
		boolean flag = false;
		String query = "delete from cart where id = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, cid);

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error removing product from cart with cart ID " + cid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}


	/**
	 * Removes all cart items for a specific user.
	 * Needed for clearing cart after order placement.
	 * Manages its own database connection.
	 *
	 * @param userId The ID of the user whose cart should be cleared.
	 * @return true if the removal was successful or no items existed, false if an error occurred.
	 */
	public boolean removeCartByUserId(int userId) {
		boolean flag = false;
		String query = "delete from cart where uid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, userId);

			// executeUpdate returns the number of rows affected.
			psmt.executeUpdate();
			flag = true; // Success if no exception

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error removing cart items for user ID " + userId + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Gets the primary key (cart ID) of a cart item based on user ID and product ID.
	 * Manages its own database connection.
	 *
	 * @param uid The user ID.
	 * @param pid The product ID.
	 * @return The cart ID (id) if found, or 0 if not found or error occurs.
	 */
	public int getIdByUserIdAndProductId(int uid, int pid) {
		int cid = 0;
		String query = "select id from cart where uid = ? and pid = ?"; // Select only id

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, uid);
			psmt.setInt(2, pid);

			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // Check if item exists
					cid = rs.getInt("id");
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting cart ID for user ID " + uid + ", product ID " + pid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			// Returns 0 in case of error or not found
		}
		return cid;
	}

	/**
	 * Counts the number of distinct items (rows) in a user's cart.
	 * Manages its own database connection.
	 *
	 * @param uid The user ID.
	 * @return The number of items in the cart, or 0 if empty or error occurs.
	 */
	public int getCartCountByUserId(int uid) {
		int count = 0;
		String query = "select count(*) from cart where uid=?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, uid);

			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // count(*) always returns a row
					count = rs.getInt(1);
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error counting cart items for user ID " + uid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			// Returns 0 in case of error
		}
		return count;
	}

	/**
	 * Gets the product ID associated with a specific cart item ID.
	 * Manages its own database connection.
	 *
	 * @param cid The primary key (id) of the cart item.
	 * @return The product ID (pid) if found, or 0 if not found or error occurs.
	 */
	public int getProductId(int cid) {
		int pid = 0;
		String query = "select pid from cart where id=?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, cid);
			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // Check if item exists
					pid = rs.getInt("pid"); // Get by column name
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting product ID for cart ID " + cid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			// Returns 0 in case of error or not found
		}
		return pid;
	}


	// --- Method removeAllProduct() removed ---
	// This method is generally too dangerous as it deletes the entire table content.
	// Use removeCartByUserId(int userId) instead for clearing a specific user's cart.
    /*
    public void removeAllProduct() {
        // DANGEROUS - Clears the entire cart table for ALL users.
        // Usually not desired. Use removeCartByUserId instead.
        String query = "delete from cart"; // TRUNCATE might be faster but less standard for JDBC update
        try (Connection con = ConnectionProvider.getConnection();
             Statement stmt = con.createStatement()) { // Use Statement for query with no params

             stmt.executeUpdate(query);

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("CRITICAL Error removing ALL products from cart table: " + e.getMessage());
            e.printStackTrace(); // Replace with proper logging
        }
    }
    */
}