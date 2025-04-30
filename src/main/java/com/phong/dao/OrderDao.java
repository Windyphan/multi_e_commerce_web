package com.phong.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp; // Import Timestamp
import java.util.ArrayList;
import java.util.List;

import com.phong.entities.Order;
import com.phong.helper.ConnectionProvider; // Import ConnectionProvider

public class OrderDao {

	// Default constructor
	public OrderDao() {
		super();
	}

	/**
	 * Inserts a new order into the database and returns the generated primary key (id).
	 * Manages its own database connection.
	 * Note: Table name "order" is enclosed in double quotes.
	 *
	 * @param order The Order object containing the data to insert.
	 * @return The generated primary key (id) of the newly inserted order, or 0 if insertion fails.
	 */
	public int insertOrder(Order order) {
		int generatedId = 0;
		// Enclose table name "order" in double quotes
		String query = "insert into \"order\"(orderid, status, paymentType, userId) values(?, ?, ?, ?)";

		// Use try-with-resources for Connection and PreparedStatement
		try (Connection con = ConnectionProvider.getConnection();
			 // Request generated keys using Statement.RETURN_GENERATED_KEYS
			 PreparedStatement psmt = con.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {

			psmt.setString(1, order.getOrderId());
			psmt.setString(2, order.getStatus());
			psmt.setString(3, order.getPaymentType()); // Ensure getter name matches
			psmt.setInt(4, order.getUserId());

			int affectedRows = psmt.executeUpdate();

			if (affectedRows > 0) {
				// Retrieve the generated key (the primary key 'id')
				try (ResultSet generatedKeys = psmt.getGeneratedKeys()) {
					if (generatedKeys.next()) {
						generatedId = generatedKeys.getInt(1); // Get the first column (usually the ID)
					} else {
						// This case should ideally not happen if affectedRows > 0 and RETURN_GENERATED_KEYS works
						System.err.println("Warning: Order insertion succeeded but failed to retrieve generated ID.");
					}
				}
			} else {
				System.err.println("Error: Order insertion failed, no rows affected.");
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error inserting order: " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			// generatedId remains 0 indicating failure
		}
		return generatedId; // Return 0 if any error occurred
	}

	/**
	 * Retrieves all orders for a specific user ID.
	 * Manages its own database connection.
	 * Note: Table name "order" is enclosed in double quotes.
	 *
	 * @param uid The user ID whose orders are to be retrieved.
	 * @return A List of Order objects, which may be empty.
	 */
	public List<Order> getAllOrderByUserId(int uid) {
		List<Order> list = new ArrayList<>();
		// Enclose table name "order" in double quotes
		String query = "select * from \"order\" where userId = ? order by date desc"; // Optional: order by date

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, uid);

			try (ResultSet rs = psmt.executeQuery()) {
				while (rs.next()) {
					Order order = mapResultSetToOrder(rs); // Use helper method
					list.add(order);
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting orders for user ID " + uid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return list;
	}

	/**
	 * Retrieves a single order by its primary key (id).
	 * Manages its own database connection.
	 * Note: Table name "order" is enclosed in double quotes.
	 *
	 * @param id The primary key (id) of the order.
	 * @return The Order object if found, null otherwise.
	 */
	public Order getOrderById(int id) {
		Order order = null; // Initialize to null
		// Enclose table name "order" in double quotes
		String query = "select * from \"order\" where id = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, id);

			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // Check if an order was found
					order = mapResultSetToOrder(rs); // Use helper method
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting order by ID " + id + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return order; // Return null if not found or error
	}

	/**
	 * Retrieves all orders from the database.
	 * Manages its own database connection.
	 * Note: Table name "order" is enclosed in double quotes.
	 *
	 * @return A List of all Order objects, which may be empty.
	 */
	public List<Order> getAllOrder() {
		List<Order> list = new ArrayList<>();
		// Enclose table name "order" in double quotes
		String query = "select * from \"order\" order by date desc"; // Optional: order by date

		try (Connection con = ConnectionProvider.getConnection();
			 Statement statement = con.createStatement();
			 ResultSet rs = statement.executeQuery(query)) {

			while (rs.next()) {
				Order order = mapResultSetToOrder(rs); // Use helper method
				list.add(order);
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting all orders: " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return list;
	}

	/**
	 * Updates the status of a specific order.
	 * Manages its own database connection.
	 * Note: Table name "order" is enclosed in double quotes.
	 *
	 * @param oid    The primary key (id) of the order to update.
	 * @param status The new status string.
	 * @return true if the update was successful (at least one row affected), false otherwise.
	 */
	public boolean updateOrderStatus(int oid, String status) {
		boolean flag = false;
		// Enclose table name "order" in double quotes
		String query = "update \"order\" set status = ? where id = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, status);
			psmt.setInt(2, oid);

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true; // Update successful
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error updating order status for order ID " + oid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Retrieves all Orders that contain at least one item fulfilled by the specified vendor.
	 * Orders are typically sorted by date descending.
	 * Manages its own database connection.
	 *
	 * @param vendorId The ID of the vendor.
	 * @return A List of Order objects relevant to the vendor, may be empty. Returns null on error.
	 */
	public List<Order> getAllOrderByVendorId(int vendorId) {
		List<Order> list = new ArrayList<>();
		// Select distinct orders where at least one associated ordered_product matches the vendor ID
		// Using EXISTS is generally efficient.
		String query = "SELECT o.* FROM \"order\" o WHERE EXISTS (" +
				"  SELECT 1 FROM ordered_product op " +
				"  WHERE op.orderid = o.id AND op.vendor_id = ?" +
				") ORDER BY o.date DESC";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, vendorId);

			try (ResultSet rs = psmt.executeQuery()) {
				while (rs.next()) {
					list.add(mapResultSetToOrder(rs));
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting orders for vendor ID " + vendorId + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			return null; // Indicate error
		}
		return list;
	}

	// --- Helper method to map ResultSet row to Order object ---
	private Order mapResultSetToOrder(ResultSet rs) throws SQLException {
		Order order = new Order();
		order.setId(rs.getInt("id"));
		order.setOrderId(rs.getString("orderid"));
		order.setStatus(rs.getString("status"));
		// Handle potential null Timestamp for date if column allows nulls
		Timestamp ts = rs.getTimestamp("date");
		if (ts != null) {
			order.setDate(ts);
		}
		order.setPaymentType(rs.getString("paymentType")); // Check getter/setter names
		order.setUserId(rs.getInt("userId"));
		return order;
	}
}