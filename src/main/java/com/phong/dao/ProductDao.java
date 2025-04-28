package com.phong.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

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
		String query = "insert into product(name, description, price, quantity, discount, image, cid, vendor_id) values(?, ?, ?, ?, ?, ?, ?, ?)";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setString(1, product.getProductName());
			psmt.setString(2, product.getProductDescription());
			psmt.setFloat(3, product.getProductPrice());
			psmt.setInt(4, product.getProductQuantity());
			psmt.setInt(5, product.getProductDiscount());
			psmt.setString(6, product.getProductImages());
			psmt.setInt(7, product.getCategoryId());
			psmt.setInt(8, product.getVendorId());

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
	 * Retrieves products with a discount, ordered by discount descending.
	 * Manages its own database connection.
	 *
	 * @return A List of discounted Product objects, which may be empty. Returns null on major error.
	 */
	public List<Product> getDiscountedProducts() {
		List<Product> list = new ArrayList<>();
		String query = "select * from product where discount > 0 order by discount desc";

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
			psmt.setInt(4, product.getProductQuantity());
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

	/**
	 * Retrieves all products belonging to a specific vendor.
	 * Manages its own database connection.
	 *
	 * @param vendorId The vendor ID.
	 * @return A List of Product objects for the vendor, which may be empty. Returns null on major error.
	 */
	public List<Product> getAllProductsByVendorId(int vendorId) {
		List<Product> list = new ArrayList<>();
		String query = "select * from product where vendor_id = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(query)) {

			psmt.setInt(1, vendorId);
			try (ResultSet rs = psmt.executeQuery()) {
				while (rs.next()) {
					list.add(mapResultSetToProduct(rs)); // Use helper method
				}
			} // ResultSet automatically closed
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error getting products for vendor ID " + vendorId + ": " + e.getMessage());
			e.printStackTrace(); // Replace with proper logging
			return null; // Indicate error
		}
		return list;
	}

	/**
	 * Retrieves a list of products based on various filter criteria.
	 * Handles filtering by category (multiple), price range, search key, and sorting by rating.
	 * Manages its own database connection.
	 *
	 * @param categoryIds   List of category IDs to filter by (if empty or null, no category filter).
	 * @param minPrice      Minimum price filter (inclusive, null if no min price).
	 * @param maxPrice      Maximum price filter (inclusive, null if no max price).
	 * @param ratingSortOrder Sorting order for average rating ("asc", "desc", or null/empty for no rating sort).
	 * @param searchKey     Search term to match in name or description (null if no search).
	 * @return A List of matching Product objects, may be empty. Returns null on major DB error.
	 */
	public List<Product> getFilteredProducts(List<Integer> categoryIds, Float minPrice, Float maxPrice, String ratingSortOrder, String searchKey) {

		List<Product> list = new ArrayList<>();
		// Use StringBuilder to dynamically build the query
		StringBuilder queryBuilder = new StringBuilder();
		List<Object> parameters = new ArrayList<>(); // To hold parameters for PreparedStatement in order

		// Base query - Select product columns
		// If sorting by rating, we need to calculate average rating first
		boolean sortByRating = (ratingSortOrder != null && !ratingSortOrder.trim().isEmpty());

		if (sortByRating) {
			// Need to join reviews and group to get average rating for filtering/sorting
			queryBuilder.append("SELECT p.*, COALESCE(AVG(r.rating), 0) as avg_rating ");
			queryBuilder.append("FROM product p ");
			queryBuilder.append("LEFT JOIN review r ON p.pid = r.product_id "); // LEFT JOIN to include products with no reviews
		} else {
			// Simple select if not sorting/filtering by rating
			queryBuilder.append("SELECT p.* FROM product p ");
		}

		// --- WHERE Clauses ---
		StringBuilder whereClause = new StringBuilder();
		boolean firstWhere = true;

		// Category Filter (handle multiple categories using IN)
		if (categoryIds != null && !categoryIds.isEmpty()) {
			whereClause.append(firstWhere ? "WHERE " : "AND ");
			// Create placeholders (?,?,?) for IN clause
			String categoryPlaceholders = categoryIds.stream()
					.map(id -> "?")
					.collect(Collectors.joining(", "));
			whereClause.append("p.cid IN (").append(categoryPlaceholders).append(") ");
			parameters.addAll(categoryIds); // Add category IDs to parameters list
			firstWhere = false;
		}

		// Min Price Filter
		if (minPrice != null) {
			whereClause.append(firstWhere ? "WHERE " : "AND ");
			whereClause.append("p.price >= ? ");
			parameters.add(minPrice);
			firstWhere = false;
		}

		// Max Price Filter
		if (maxPrice != null) {
			whereClause.append(firstWhere ? "WHERE " : "AND ");
			whereClause.append("p.price <= ? ");
			parameters.add(maxPrice);
			firstWhere = false;
		}

		// Search Key Filter (case-insensitive)
		if (searchKey != null && !searchKey.trim().isEmpty()) {
			whereClause.append(firstWhere ? "WHERE " : "AND ");
			whereClause.append("(lower(p.name) LIKE lower(?) OR lower(p.description) LIKE lower(?)) ");
			String searchPattern = "%" + searchKey.trim() + "%";
			parameters.add(searchPattern);
			parameters.add(searchPattern);
			firstWhere = false;
		}

		// Append WHERE clause if any conditions were added
		queryBuilder.append(whereClause);

		// --- GROUP BY Clause (Only if calculating average rating) ---
		if (sortByRating) {
			queryBuilder.append("GROUP BY p.pid "); // Group by all columns of product or just pid if DB allows
			// Depending on PostgreSQL version and settings, you might need to list ALL selected 'p' columns here
			// GROUP BY p.pid, p.name, p.description, p.price, ... etc. OR just p.pid if primary key grouping is sufficient
		}

		// --- ORDER BY Clause ---
		StringBuilder orderByClause = new StringBuilder();
		boolean firstOrder = true;

		// Rating Sort
		if (sortByRating) {
			orderByClause.append("ORDER BY avg_rating ");
			orderByClause.append("asc".equalsIgnoreCase(ratingSortOrder) ? "ASC" : "DESC");
			// Add NULLS LAST/FIRST if desired
			orderByClause.append(" NULLS LAST "); // Show products without ratings last
			firstOrder = false;
		}

		// Default sort or secondary sort (e.g., by product ID or name)
		orderByClause.append(firstOrder ? "ORDER BY " : ", ");
		orderByClause.append("p.pid ASC "); // Example: sort by ID ascending as secondary/default


		queryBuilder.append(orderByClause);

		// Final Query String
		String finalQuery = queryBuilder.toString();
		System.out.println("Executing Filtered Query: " + finalQuery); // Log the generated query
		System.out.println("Parameters: " + parameters); // Log parameters

		// --- Execute Query ---
		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(finalQuery)) {

			// Set parameters dynamically
			int paramIndex = 1;
			for (Object param : parameters) {
				// Need to check type, PreparedStatement needs specific set methods
				if (param instanceof Integer) {
					psmt.setInt(paramIndex++, (Integer) param);
				} else if (param instanceof Float) {
					psmt.setFloat(paramIndex++, (Float) param);
				} else if (param instanceof String) {
					psmt.setString(paramIndex++, (String) param);
				} else if (param instanceof Double) { // In case prices become double
					psmt.setDouble(paramIndex++, (Double) param);
				}
				// Add other types if needed
			}

			try (ResultSet rs = psmt.executeQuery()) {
				while (rs.next()) {
					// Map using existing helper - it ignores extra columns like avg_rating
					list.add(mapResultSetToProduct(rs));
				}
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error executing filtered product query: " + e.getMessage());
			e.printStackTrace();
			return null; // Return null on major query execution error
		}

		return list; // Return the filtered (potentially empty) list
	}


	/**
	 * Gets a specific page of ALL products.
	 * Manages its own database connection.
	 * @param page Page number (1-based).
	 * @param productsPerPage Number of products to fetch per page.
	 * @return List of products for the requested page, empty if none found. Null on error.
	 */
	public List<Product> getProductsPaginated(int page, int productsPerPage) {
		List<Product> list = new ArrayList<>();
		if (page < 1) page = 1;
		int offset = (page - 1) * productsPerPage;
		String query = "SELECT * FROM product ORDER BY pid DESC LIMIT ? OFFSET ?"; // Adjust ORDER BY if needed

		try (Connection con = ConnectionProvider.getConnection(); // Get connection in try-with-resources
			 PreparedStatement pstmt = con.prepareStatement(query)) {

			pstmt.setInt(1, productsPerPage);
			pstmt.setInt(2, offset);

			try (ResultSet rs = pstmt.executeQuery()) { // Also use try-with-resources for ResultSet
				while (rs.next()) {
					list.add(mapResultSetToProduct(rs));
				}
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error fetching paginated products: " + e.getMessage());
			e.printStackTrace();
			return null; // Indicate error
		}
		return list;
	}

	/**
	 * Gets a specific page of products BY CATEGORY.
	 * Manages its own database connection.
	 * @param categoryId The category ID to filter by.
	 * @param page Page number (1-based).
	 * @param productsPerPage Number of products to fetch per page.
	 * @return List of products for the category and page. Null on error.
	 */
	public List<Product> getProductsByCategoryPaginated(int categoryId, int page, int productsPerPage) {
		List<Product> list = new ArrayList<>();
		if (page < 1) page = 1;
		int offset = (page - 1) * productsPerPage;
		String query = "SELECT * FROM product WHERE cid = ? ORDER BY pid DESC LIMIT ? OFFSET ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement pstmt = con.prepareStatement(query)) {

			pstmt.setInt(1, categoryId);
			pstmt.setInt(2, productsPerPage);
			pstmt.setInt(3, offset);

			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					list.add(mapResultSetToProduct(rs));
				}
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error fetching paginated products by category " + categoryId + ": " + e.getMessage());
			e.printStackTrace();
			return null;
		}
		return list;
	}

	/**
	 * Gets a specific page of products BY SEARCH KEY (case-insensitive).
	 * Manages its own database connection.
	 * @param searchKey The search term.
	 * @param page Page number (1-based).
	 * @param productsPerPage Number of products to fetch per page.
	 * @return List of matching products for the page. Null on error.
	 */
	public List<Product> getProductsBySearchPaginated(String searchKey, int page, int productsPerPage) {
		List<Product> list = new ArrayList<>();
		if (page < 1) page = 1;
		int offset = (page - 1) * productsPerPage;
		// Using lower() for case-insensitivity
		String query = "SELECT * FROM product WHERE lower(name) LIKE lower(?) OR lower(description) LIKE lower(?) ORDER BY pid DESC LIMIT ? OFFSET ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement pstmt = con.prepareStatement(query)) {

			String likeParam = "%" + searchKey + "%";
			pstmt.setString(1, likeParam);
			pstmt.setString(2, likeParam);
			pstmt.setInt(3, productsPerPage);
			pstmt.setInt(4, offset);

			try(ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					list.add(mapResultSetToProduct(rs));
				}
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error fetching paginated products by search '" + searchKey + "': " + e.getMessage());
			e.printStackTrace();
			return null;
		}
		return list;
	}


	// --- NEW: Count Methods (Corrected) ---

	/**
	 * Gets the total count of ALL products.
	 * Manages its own database connection.
	 * @return Total product count, or -1 on error.
	 */
	public int getTotalProductCount() {
		int count = -1; // Use -1 to indicate error state clearly
		String query = "SELECT COUNT(*) FROM product";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement pstmt = con.prepareStatement(query); // Use PreparedStatement even for simple count
			 ResultSet rs = pstmt.executeQuery()) {

			if (rs.next()) {
				count = rs.getInt(1);
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error counting all products: " + e.getMessage());
			e.printStackTrace();
			// count remains -1
		}
		return count;
	}

	/**
	 * Gets the total count of products BY CATEGORY.
	 * Manages its own database connection.
	 * @param categoryId The category ID.
	 * @return Total product count for the category, or -1 on error.
	 */
	public int getTotalProductCountByCategory(int categoryId) {
		int count = -1;
		String query = "SELECT COUNT(*) FROM product WHERE cid = ?";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement pstmt = con.prepareStatement(query)) {

			pstmt.setInt(1, categoryId);
			try(ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					count = rs.getInt(1);
				}
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error counting products by category " + categoryId + ": " + e.getMessage());
			e.printStackTrace();
		}
		return count;
	}

	/**
	 * Gets the total count of products BY SEARCH KEY (case-insensitive).
	 * Manages its own database connection.
	 * @param searchKey The search term.
	 * @return Total matching product count, or -1 on error.
	 */
	public int getTotalProductCountBySearch(String searchKey) {
		int count = -1;
		String query = "SELECT COUNT(*) FROM product WHERE lower(name) LIKE lower(?) OR lower(description) LIKE lower(?)";

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement pstmt = con.prepareStatement(query)) {

			String likeParam = "%" + searchKey + "%";
			pstmt.setString(1, likeParam);
			pstmt.setString(2, likeParam);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					count = rs.getInt(1);
				}
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error counting products by search '" + searchKey + "': " + e.getMessage());
			e.printStackTrace();
		}
		return count;
	}

	/**
	 * Gets the total count of products matching various filter criteria.
	 * Manages its own database connection.
	 * @param categoryIds List of category IDs (null/empty for no filter).
	 * @param minPrice Minimum price (null for no filter).
	 * @param maxPrice Maximum price (null for no filter).
	 * @param searchKey Search term (null/empty for no filter).
	 * @return Total count of matching products, or -1 on error.
	 */
	public int getFilteredProductCount(List<Integer> categoryIds, Float minPrice, Float maxPrice, String searchKey) {
		int count = -1;
		StringBuilder queryBuilder = new StringBuilder("SELECT COUNT(*) FROM product p ");
		List<Object> parameters = new ArrayList<>();
		StringBuilder whereClause = new StringBuilder();
		boolean firstWhere = true;

		// --- Build WHERE clause (same logic as getFilteredProductsPaginated below) ---
		// Category Filter
		if (categoryIds != null && !categoryIds.isEmpty()) {
			whereClause.append(firstWhere ? "WHERE " : "AND ");
			String categoryPlaceholders = categoryIds.stream().map(id -> "?").collect(Collectors.joining(", "));
			whereClause.append("p.cid IN (").append(categoryPlaceholders).append(") ");
			parameters.addAll(categoryIds);
			firstWhere = false;
		}
		// Min Price Filter
		if (minPrice != null) {
			whereClause.append(firstWhere ? "WHERE " : "AND ");
			whereClause.append("p.price >= ? ");
			parameters.add(minPrice);
			firstWhere = false;
		}
		// Max Price Filter
		if (maxPrice != null) {
			whereClause.append(firstWhere ? "WHERE " : "AND ");
			whereClause.append("p.price <= ? ");
			parameters.add(maxPrice);
			firstWhere = false;
		}
		// Search Key Filter
		if (searchKey != null && !searchKey.trim().isEmpty()) {
			whereClause.append(firstWhere ? "WHERE " : "AND ");
			whereClause.append("(lower(p.name) LIKE lower(?) OR lower(p.description) LIKE lower(?)) ");
			String searchPattern = "%" + searchKey.trim() + "%";
			parameters.add(searchPattern);
			parameters.add(searchPattern);
			firstWhere = false;
		}
		// --- End WHERE clause build ---

		queryBuilder.append(whereClause); // Append the WHERE clause
		String finalQuery = queryBuilder.toString();

		System.out.println("Executing Filtered Count Query: " + finalQuery); // Log query
		System.out.println("Parameters: " + parameters); // Log parameters

		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(finalQuery)) {

			// Set parameters
			setDynamicParameters(psmt, parameters);

			try (ResultSet rs = psmt.executeQuery()) {
				if (rs.next()) {
					count = rs.getInt(1);
				}
			}
		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error counting filtered products: " + e.getMessage());
			e.printStackTrace();
			// count remains -1
		}
		return count;
	}

	/**
	 * Retrieves a specific page of products based on various filter criteria.
	 * Handles filtering by category (multiple), price range, search key, and sorting by rating.
	 * Manages its own database connection.
	 *
	 * @param categoryIds   List of category IDs to filter by (if empty or null, no category filter).
	 * @param minPrice      Minimum price filter (inclusive, null if no min price).
	 * @param maxPrice      Maximum price filter (inclusive, null if no max price).
	 * @param ratingSortOrder Sorting order for average rating ("asc", "desc", or null/empty for no rating sort).
	 * @param searchKey     Search term to match in name or description (null if no search).
	 * @param page          Page number (1-based).
	 * @param productsPerPage Number of products per page.
	 * @return A List of matching Product objects for the requested page, may be empty. Returns null on major DB error.
	 */
	public List<Product> getFilteredProductsPaginated(List<Integer> categoryIds, Float minPrice, Float maxPrice,
													  String ratingSortOrder, String searchKey,
													  int page, int productsPerPage) {

		List<Product> list = new ArrayList<>();
		StringBuilder queryBuilder = new StringBuilder();
		List<Object> parameters = new ArrayList<>();
		boolean sortByRating = (ratingSortOrder != null && !ratingSortOrder.trim().isEmpty());

		// --- Build SELECT and FROM clause (Handle rating sort join) ---
		if (sortByRating) {
			queryBuilder.append("SELECT p.*, COALESCE(AVG(r.rating), 0) as avg_rating ");
			queryBuilder.append("FROM product p ");
			queryBuilder.append("LEFT JOIN review r ON p.pid = r.product_id ");
		} else {
			queryBuilder.append("SELECT p.* FROM product p ");
		}

		// --- Build WHERE clause (Same logic as count method) ---
		StringBuilder whereClause = new StringBuilder();
		boolean firstWhere = true;
		// Category Filter
		if (categoryIds != null && !categoryIds.isEmpty()) {
			whereClause.append(firstWhere ? "WHERE " : "AND ");
			String categoryPlaceholders = categoryIds.stream().map(id -> "?").collect(Collectors.joining(", "));
			whereClause.append("p.cid IN (").append(categoryPlaceholders).append(") ");
			parameters.addAll(categoryIds);
			firstWhere = false;
		}
		// Min Price Filter
		if (minPrice != null) {
			whereClause.append(firstWhere ? "WHERE " : "AND ");
			whereClause.append("p.price >= ? ");
			parameters.add(minPrice);
			firstWhere = false;
		}
		// Max Price Filter
		if (maxPrice != null) {
			whereClause.append(firstWhere ? "WHERE " : "AND ");
			whereClause.append("p.price <= ? ");
			parameters.add(maxPrice);
			firstWhere = false;
		}
		// Search Key Filter
		if (searchKey != null && !searchKey.trim().isEmpty()) {
			whereClause.append(firstWhere ? "WHERE " : "AND ");
			whereClause.append("(lower(p.name) LIKE lower(?) OR lower(p.description) LIKE lower(?)) ");
			String searchPattern = "%" + searchKey.trim() + "%";
			parameters.add(searchPattern);
			parameters.add(searchPattern);
			firstWhere = false;
		}
		queryBuilder.append(whereClause); // Append WHERE clause
		// --- End WHERE clause ---


		// --- Build GROUP BY (Only if sorting by rating) ---
		if (sortByRating) {
			queryBuilder.append("GROUP BY p.pid "); // Adjust if your DB requires listing all non-aggregated columns
		}

		// --- Build ORDER BY ---
		StringBuilder orderByClause = new StringBuilder();
		boolean firstOrder = true;
		if (sortByRating) {
			orderByClause.append("ORDER BY avg_rating ");
			orderByClause.append("asc".equalsIgnoreCase(ratingSortOrder) ? "ASC" : "DESC");
			orderByClause.append(" NULLS LAST ");
			firstOrder = false;
		}
		// Default/secondary sort
		orderByClause.append(firstOrder ? "ORDER BY " : ", ");
		orderByClause.append("p.pid ASC "); // Or p.name, etc.
		queryBuilder.append(orderByClause); // Append ORDER BY clause
		// --- End ORDER BY ---


		// --- Build LIMIT and OFFSET ---
		queryBuilder.append("LIMIT ? OFFSET ?");
		if (page < 1) page = 1;
		int offset = (page - 1) * productsPerPage;
		parameters.add(productsPerPage); // Add LIMIT parameter
		parameters.add(offset);          // Add OFFSET parameter
		// --- End LIMIT/OFFSET ---


		// Final Query String
		String finalQuery = queryBuilder.toString();
		System.out.println("Executing Filtered Paginated Query: " + finalQuery); // Log query
		System.out.println("Parameters: " + parameters); // Log parameters

		// --- Execute Query ---
		try (Connection con = ConnectionProvider.getConnection();
			 PreparedStatement psmt = con.prepareStatement(finalQuery)) {

			// Set parameters dynamically
			setDynamicParameters(psmt, parameters);

			try (ResultSet rs = psmt.executeQuery()) {
				while (rs.next()) {
					// Map using existing helper
					list.add(mapResultSetToProduct(rs));
				}
			}

		} catch (SQLException | ClassNotFoundException e) {
			System.err.println("Error executing filtered paginated product query: " + e.getMessage());
			e.printStackTrace();
			return null; // Return null on major query execution error
		}

		return list; // Return the filtered & paginated list
	}

	// --- NEW Helper method to set parameters dynamically ---
	private void setDynamicParameters(PreparedStatement psmt, List<Object> parameters) throws SQLException {
		int paramIndex = 1;
		for (Object param : parameters) {
			if (param instanceof Integer) {
				psmt.setInt(paramIndex++, (Integer) param);
			} else if (param instanceof Float) {
				psmt.setFloat(paramIndex++, (Float) param);
			} else if (param instanceof String) {
				psmt.setString(paramIndex++, (String) param);
			} else if (param instanceof Double) {
				psmt.setDouble(paramIndex++, (Double) param);
			} else if (param == null) {
				// Handle null if necessary, e.g., for different DB types or specific checks
				// psmt.setNull(paramIndex++, Types.VARCHAR); // Example, adjust type
			} else {
				System.err.println("Warning: Unhandled parameter type in setDynamicParameters: " + param.getClass().getName());
				// Fallback or throw error
				psmt.setObject(paramIndex++, param);
			}
		}
	}


	// --- Helper method to map ResultSet row to Product object ---
	private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
		Product product = new Product();
		product.setProductId(rs.getInt("pid"));
		product.setProductName(rs.getString("name"));
		product.setProductDescription(rs.getString("description"));
		product.setProductPrice(rs.getFloat("price"));
		product.setProductQuantity(rs.getInt("quantity"));
		product.setProductDiscount(rs.getInt("discount"));
		product.setProductImages(rs.getString("image"));
		product.setCategoryId(rs.getInt("cid"));
		product.setVendorId(rs.getInt("vendor_id"));
		// You might want to set the calculated discounted price here too if the entity supports it
		// product.setPriceAfterDiscount(product.calculateDiscountedPrice()); // Example
		return product;
	}
}