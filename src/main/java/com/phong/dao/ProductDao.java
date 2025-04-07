package com.phong.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.phong.entities.Product;
import com.phong.helper.ConnectionProvider; // Import ConnectionProvider

public class ProductDao {

	// No Connection field needed
	// private Connection con;

	// Default constructor
	public ProductDao() {
		super();
	}

	/**
	 * Saves a new product to the database.
	 * Manages its own database connection.
	 *
	 * @param product The Product object containing the data to save.
	 * @return true if the product was saved successfully, false otherwise.
	 */
	public boolean saveProduct(Product product) {
		boolean flag = false;
		String query = "insert into product(name, description, price, quantity, discount, image, cid) values(?, ?, ?, ?, ?, ?, ?)";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, product.getProductName());
			psmt.setString(2, product.getProductDescription());
			psmt.setFloat(3, product.getProductPrice());
			// Assuming the correct getter is getProductQuantity() - adjust if needed
			psmt.setInt(4, product.getProductQuantity());
			psmt.setInt(5, product.getProductDiscount());
			psmt.setString(6, product.getProductImages());
			psmt.setInt(7, product.getCategoryId());

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error saving product '" + product.getProductName() + "': " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Retrieves all products from the database.
	 * Manages its own database connection.
	 *
	 * @return A List of all Product objects, which may be empty. Returns null on major error.
	 */
	public List<Product> getAllProducts() {
		List<Product> list = new ArrayList<>();
		String query = "select * from product";

		try (Connection con = ConnectionProvider.getConnection();
			 Statement statement = con.createStatement();
			 ResultSet rs = statement.executeQuery(query)) {

			while (rs.next()) {
				list.add(mapResultSetToProduct(rs)); // Use helper method
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting all products: " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			return null; // Indicate error
		}
		return list;
	}

	/**
	 * Retrieves all products ordered by newest first (descending pid).
	 * Manages its own database connection.
	 *
	 * @return A List of Product objects ordered by ID desc, which may be empty. Returns null on major error.
	 */
	public List<Product> getAllLatestProducts() {
		List<Product> list = new ArrayList<>();
		String query = "select * from product order by pid desc";

		try (Connection con = ConnectionProvider.getConnection();
			 Statement statement = con.createStatement();
			 ResultSet rs = statement.executeQuery(query)) {

			while (rs.next()) {
				list.add(mapResultSetToProduct(rs)); // Use helper method
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting latest products: " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			return null; // Indicate error
		}
		return list;
	}

	/**
	 * Retrieves a single product by its primary key (pid).
	 * Manages its own database connection.
	 *
	 * @param pid The primary key (pid) of the product.
	 * @return The Product object if found, null otherwise.
	 */
	public Product getProductsByProductId(int pid) {
		Product product = null; // Initialize to null
		String query = "select * from product where pid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, pid);
			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // Check if product was found
					product = mapResultSetToProduct(rs); // Use helper method
				}
			} // ResultSet automatically closed
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting product by ID " + pid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return product; // Return null if not found or error
	}

	/**
	 * Retrieves all products belonging to a specific category.
	 * Manages its own database connection.
	 *
	 * @param catId The category ID.
	 * @return A List of Product objects for the category, which may be empty. Returns null on major error.
	 */
	public List<Product> getAllProductsByCategoryId(int catId) {
		List<Product> list = new ArrayList<>();
		String query = "select * from product where cid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, catId);
			try (ResultSet rs = psmt.executeQuery()) {
				while (rs.next()) {
					list.add(mapResultSetToProduct(rs)); // Use helper method
				}
			} // ResultSet automatically closed
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting products for category ID " + catId + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			return null; // Indicate error
		}
		return list;
	}

	/**
	 * Retrieves products matching a search key in name or description (case-insensitive).
	 * Manages its own database connection.
	 *
	 * @param search The search keyword.
	 * @return A List of matching Product objects, which may be empty. Returns null on major error.
	 */
	public List<Product> getAllProductsBySearchKey(String search) {
		List<Product> list = new ArrayList<>();
		// Using lower() function for case-insensitive search
		String query = "select * from product where lower(name) like lower(?) or lower(description) like lower(?)";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			String searchPattern = "%" + search + "%"; // Prepare search pattern
			psmt.setString(1, searchPattern);
			psmt.setString(2, searchPattern);

			try (ResultSet rs = psmt.executeQuery()) {
				while (rs.next()) {
					list.add(mapResultSetToProduct(rs)); // Use helper method
				}
			} // ResultSet automatically closed
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error searching products with key '" + search + "': " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			return null; // Indicate error
		}
		return list;
	}

	/**
	 * Retrieves products with a discount of 30% or higher, ordered by discount descending.
	 * Manages its own database connection.
	 *
	 * @return A List of discounted Product objects, which may be empty. Returns null on major error.
	 */
	public List<Product> getDiscountedProducts() {
		List<Product> list = new ArrayList<>();
		// Assuming discount is stored as an integer percentage (e.g., 30 for 30%)
		String query = "select * from product where discount >= 30 order by discount desc";

		try (Connection con = ConnectionProvider.getConnection();
			 Statement statement = con.createStatement();
			 ResultSet rs = statement.executeQuery(query)) {

			while (rs.next()) {
				list.add(mapResultSetToProduct(rs)); // Use helper method
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting discounted products: " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			return null; // Indicate error
		}
		return list;
	}

	/**
	 * Updates an existing product's details (excluding category ID).
	 * Manages its own database connection.
	 *
	 * @param product The Product object containing the updated details and the productId (pid).
	 * @return true if the update was successful, false otherwise.
	 */
	public boolean updateProduct(Product product) {
		boolean flag = false;
		// Note: Category ID (cid) is not updated here. Add it if needed.
		String query = "update product set name=?, description=?, price=?, quantity=?, discount=?, image=? where pid=?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, product.getProductName());
			psmt.setString(2, product.getProductDescription());
			psmt.setFloat(3, product.getProductPrice());
			psmt.setInt(4, product.getProductQuantity()); // Assuming correct getter name
			psmt.setInt(5, product.getProductDiscount());
			psmt.setString(6, product.getProductImages());
			psmt.setInt(7, product.getProductId());

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error updating product ID " + product.getProductId() + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Updates the quantity of a specific product.
	 * Manages its own database connection.
	 *
	 * @param id  The primary key (pid) of the product to update.
	 * @param qty The new quantity. Should not be negative.
	 * @return true if the update was successful, false otherwise.
	 */
	public boolean updateQuantity(int id, int qty) {
		boolean flag = false;
		// Add check for negative quantity if desired
		if (qty < 0) {
			System.err.println("Warning: Attempted to set negative quantity (" + qty + ") for product ID " + id);
			return false; // Prevent setting negative quantity
		}
		String query = "update product set quantity = ? where pid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, qty);
			psmt.setInt(2, id);

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error updating quantity for product ID " + id + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Deletes a product by its primary key (pid).
	 * WARNING: Consider related data (e.g., in carts, wishlists, ordered_product). Deleting might violate constraints or leave orphaned data.
	 * Manages its own database connection.
	 *
	 * @param pid The primary key (pid) of the product to delete.
	 * @return true if the deletion was successful, false otherwise.
	 */
	public boolean deleteProduct(int pid) {
		boolean flag = false;
		// Add checks here if product exists in carts/orders before allowing deletion?
		String query = "delete from product where pid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, pid);
			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error deleting product ID " + pid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			// Catch specific constraint violation exceptions if needed
		}
		return flag;
	}

	/**
	 * Counts the total number of products.
	 * Manages its own database connection.
	 *
	 * @return The total number of products, or 0 if an error occurs.
	 */
	public int productCount() {
		int count = 0;
		String query = "select count(*) from product";

		try (Connection con = ConnectionProvider.getConnection();
			 Statement stmt = con.createStatement(); // Use Statement for simple query
			 ResultSet rs = stmt.executeQuery(query)) {

			if (rs.next()) { // count(*) always returns a row
				count = rs.getInt(1);
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error counting products: " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			// Returns 0 on error
		}
		return count;
	}

	/**
	 * Gets the calculated price after discount for a product.
	 * Note: This seems redundant if the Product entity already has getProductPriceAfterDiscount().
	 * Consider calculating this in the entity or service layer.
	 * Manages its own database connection.
	 *
	 * @param pid The product ID.
	 * @return The calculated price after discount, or 0 if product not found or error occurs.
	 */
	public float getProductPriceById(int pid) {
		float price = 0;
		String query = "select price, discount from product where pid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, pid);
			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // Check if product exists
					float orgPrice = rs.getFloat("price"); // Use getFloat
					int discount = rs.getInt("discount");

					// Calculation logic (same as in Product entity likely)
					float discountAmount = (float) ((discount / 100.0) * orgPrice);
					price = orgPrice - discountAmount;
				}
			} // ResultSet automatically closed
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting price for product ID " + pid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			// Returns 0 on error or not found
		}
		return price;
	}

	/**
	 * Gets the current quantity (stock) of a product.
	 * Manages its own database connection.
	 *
	 * @param pid The product ID.
	 * @return The quantity, or 0 if product not found or error occurs.
	 */
	public int getProductQuantityById(int pid) {
		int qty = 0;
		String query = "select quantity from product where pid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, pid);
			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // Check if product exists
					qty = rs.getInt("quantity");
				}
			} // ResultSet automatically closed
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting quantity for product ID " + pid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			// Returns 0 on error or not found
		}
		return qty;
	}


	// --- Helper method to map ResultSet row to Product object ---
	private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
		Product product = new Product();
		product.setProductId(rs.getInt("pid"));
		product.setProductName(rs.getString("name"));
		product.setProductDescription(rs.getString("description"));
		product.setProductPrice(rs.getFloat("price"));
		// Assuming the correct setter is setProductQuantity() - adjust if needed
		product.setProductQuantity(rs.getInt("quantity"));
		product.setProductDiscount(rs.getInt("discount"));
		product.setProductImages(rs.getString("image"));
		product.setCategoryId(rs.getInt("cid"));
		// You might want to set the calculated discounted price here too if the entity supports it
		// product.setPriceAfterDiscount(product.calculateDiscountedPrice()); // Example
		return product;
	}
}