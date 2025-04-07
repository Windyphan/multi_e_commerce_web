package com.phong.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.phong.entities.Category;
import com.phong.helper.ConnectionProvider; // Import ConnectionProvider

public class CategoryDao {

	// No Connection field needed
	// private Connection con;

	// Default constructor
	public CategoryDao() {
		super();
	}

	/**
	 * Saves a new category to the database.
	 * Manages its own database connection.
	 *
	 * @param category The Category object containing the data to save.
	 * @return true if the category was saved successfully, false otherwise.
	 */
	public boolean saveCategory(Category category) {
		boolean flag = false;
		String query = "insert into category(name, image) values(?, ?)";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, category.getCategoryName());
			psmt.setString(2, category.getCategoryImage());

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			// Catch specific exceptions
			System.err.println("Error saving category '" + category.getCategoryName() + "': " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Retrieves all categories from the database.
	 * Manages its own database connection.
	 *
	 * @return A List of all Category objects, which may be empty. Returns null on major error.
	 */
	public List<Category> getAllCategories() {
		List<Category> list = new ArrayList<>();
		String query = "select * from category order by name"; // Optional ordering

		try (Connection con = ConnectionProvider.getConnection();
			 Statement statement = con.createStatement(); // Simple query, Statement is fine
			 ResultSet rs = statement.executeQuery(query)) {

			while (rs.next()) {
				list.add(mapResultSetToCategory(rs)); // Use helper method
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting all categories: " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			return null; // Indicate error
		}
		return list;
	}

	/**
	 * Retrieves a single category by its primary key (cid).
	 * Manages its own database connection.
	 *
	 * @param cid The primary key (cid) of the category.
	 * @return The Category object if found, null otherwise.
	 */
	public Category getCategoryById(int cid) {
		Category category = null; // Initialize to null
		String query = "select * from category where cid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, cid);
			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // Check if category was found
					category = mapResultSetToCategory(rs); // Use helper method
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting category by ID " + cid + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return category; // Return null if not found or error
	}

	/**
	 * Retrieves the name of a category by its primary key (cid).
	 * Manages its own database connection.
	 *
	 * @param catId The category ID.
	 * @return The category name String if found, null otherwise.
	 */
	public String getCategoryName(int catId) {
		String categoryName = null; // Initialize to null
		String query = "select name from category where cid = ?"; // Select only name

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, catId);
			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) { // Check if category was found
					categoryName = rs.getString("name");
				}
			} // ResultSet automatically closed

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting category name for ID " + catId + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return categoryName; // Return null if not found or error
	}

	/**
	 * Updates an existing category's details.
	 * Manages its own database connection.
	 *
	 * @param cat The Category object containing the updated details and the categoryId (cid).
	 * @return true if the update was successful, false otherwise.
	 */
	public boolean updateCategory(Category cat) {
		boolean flag = false;
		String query = "update category set name=?, image=? where cid=?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, cat.getCategoryName());
			psmt.setString(2, cat.getCategoryImage());
			psmt.setInt(3, cat.getCategoryId());

			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error updating category ID " + cat.getCategoryId() + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Deletes a category by its primary key (cid).
	 * WARNING: Consider related data (products). Deleting might violate constraints.
	 * Manages its own database connection.
	 *
	 * @param cid The primary key (cid) of the category to delete.
	 * @return true if the deletion was successful, false otherwise.
	 */
	public boolean deleteCategory(int cid) {
		boolean flag = false;
		// TODO: Check if category contains products before deleting?
		String query = "delete from category where cid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, cid);
			int rowsAffected = psmt.executeUpdate();
			if (rowsAffected > 0) {
				flag = true;
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error deleting category ID " + cid + ": " + e.getMessage());
			// Catch specific constraint violation exceptions if needed (e.g., SQLState code)
			e.printStackTrace(); // Replace with proper logging
		}
		return flag;
	}

	/**
	 * Counts the total number of categories.
	 * Manages its own database connection.
	 *
	 * @return The total number of categories, or 0 if an error occurs.
	 */
	public int categoryCount() {
		int count = 0;
		String query = "select count(*) from category";

		try (Connection con = ConnectionProvider.getConnection();
			 Statement stmt = con.createStatement(); // Simple query, Statement is fine
			 ResultSet rs = stmt.executeQuery(query)) {

			if (rs.next()) { // count(*) always returns one row
				count = rs.getInt(1);
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error counting categories: " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			// Returns 0 on error
		}
		return count;
	}

	// --- Helper method to map ResultSet row to Category object ---
	private Category mapResultSetToCategory(ResultSet rs) throws SQLException {
		Category category = new Category();
		category.setCategoryId(rs.getInt("cid"));
		category.setCategoryName(rs.getString("name"));
		category.setCategoryImage(rs.getString("image"));
		return category;
	}
}