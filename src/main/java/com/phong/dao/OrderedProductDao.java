package com.phong.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
// No need for Statement import if not used directly
// import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.phong.entities.OrderedProduct;
import com.phong.helper.ConnectionProvider; // Import ConnectionProvider

public class OrderedProductDao {

	// No Connection field needed
	// private Connection con;

	// Default constructor
	public OrderedProductDao() {
		super();
	}

	/**
	 * Inserts a record of a product associated with a specific order.
	 * Manages its own database connection.
	 *
	 * @param ordProduct The OrderedProduct object containing the details.
	 * @return true if the insertion was successful, false otherwise.
	 */
	public boolean insertOrderedProduct(OrderedProduct ordProduct) {
		boolean flag = false;
		String query = "insert into ordered_product(name, quantity, price, image, orderid) values(?, ?, ?, ?, ?)";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, ordProduct.getName());
			psmt.setInt(2, ordProduct.getQuantity());
			// Assuming getPrice() returns float, adjust if needed (e.g., BigDecimal for currency)
			psmt.setFloat(3, ordProduct.getPrice());
			psmt.setString(4, ordProduct.getImage());
			psmt.setInt(5, ordProduct.getOrderId()); // Foreign key to the 'order' table's primary key 'id'

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error inserting ordered product '" + ordProduct.getName() + "' for order ID " + ordProduct.getOrderId() + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Retrieves all products associated with a specific order ID (the foreign key).
	 * Manages its own database connection.
	 *
	 * @param orderTableId The primary key ('id') from the 'order' table corresponding to this order.
	 * @return A List of OrderedProduct objects for the given order, which may be empty. Returns null on major error.
	 */
	public List<OrderedProduct> getAllOrderedProduct(int orderTableId) {
		List<OrderedProduct> list = new ArrayList<>();
		// Query based on the foreign key 'orderid' which links to the 'order' table's primary key 'id'
		String query = "select * from ordered_product where orderid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, orderTableId);

			try (ResultSet rs = psmt.executeQuery()) {
				while (rs.next()) {
					list.add(mapResultSetToOrderedProduct(rs, orderTableId)); // Pass orderId to helper
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting ordered products for order primary key ID " + orderTableId + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			return null; // Indicate error
		}
		return list;
	}

	// --- Helper method to map ResultSet row to OrderedProduct object ---
	private OrderedProduct mapResultSetToOrderedProduct(ResultSet rs, int orderId) throws SQLException {
		OrderedProduct orderProd = new OrderedProduct();
		// Assuming OrderedProduct entity doesn't have its own primary key field 'oid' from the DB
		// If it does, add: orderProd.setOid(rs.getInt("oid"));
		orderProd.setName(rs.getString("name"));
		orderProd.setQuantity(rs.getInt("quantity"));
		orderProd.setPrice(rs.getFloat("price"));
		orderProd.setImage(rs.getString("image"));
		orderProd.setOrderId(orderId); // Set the order ID (foreign key) from the parameter
		return orderProd;
	}
}