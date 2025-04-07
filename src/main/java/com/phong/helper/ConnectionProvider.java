package com.phong.helper;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.http.HttpServlet;

/**
 * Code that connect postgres db at local
 */
//public class ConnectionProvider extends HttpServlet {
//
//	private static final long serialVersionUID = 1L;
//	private static Connection connection;
//
//	public static Connection getConnection() {
//
//		try {
//			if (connection == null) {
//				Class.forName("org.postgresql.Driver"); // PostgreSQL Driver
//				connection = DriverManager.getConnection(
//						"jdbc:postgresql://localhost:5432/phong", // PostgreSQL JDBC URL
//						"postgres", // PostgreSQL username
//						"admin"); // PostgreSQL password
//			}
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
//		return connection;
//
//
//	}
//}
public class ConnectionProvider {

	// Use environment variables for configuration
	// These names MUST match the names you set in Elastic Beanstalk configuration
	private static final String DB_HOST_ENV = "DB_HOST";
	private static final String DB_PORT_ENV = "DB_PORT"; // Usually 5432 for PostgreSQL
	private static final String DB_NAME_ENV = "DB_NAME"; // Should be "phong"
	private static final String DB_USER_ENV = "DB_USER";
	private static final String DB_PASS_ENV = "DB_PASS";

	// Remove the static connection field. It's bad practice in web apps.
	// Each request should ideally get a connection from a pool or create/close one.

	public static Connection getConnection() throws SQLException, ClassNotFoundException {

		// Read configuration from Environment Variables provided by Elastic Beanstalk
		String dbHost = System.getenv(DB_HOST_ENV);
		String dbPort = System.getenv(DB_PORT_ENV);
		String dbName = System.getenv(DB_NAME_ENV);
		String dbUser = System.getenv(DB_USER_ENV);
		String dbPass = System.getenv(DB_PASS_ENV);

		// Basic validation (add more robust logging in a real app)
		if (dbHost == null || dbPort == null || dbName == null || dbUser == null || dbPass == null) {
			System.err.println("CRITICAL ERROR: Database environment variables not set!");
			System.err.println("Missing: " +
					(dbHost == null ? DB_HOST_ENV + " " : "") +
					(dbPort == null ? DB_PORT_ENV + " " : "") +
					(dbName == null ? DB_NAME_ENV + " " : "") +
					(dbUser == null ? DB_USER_ENV + " " : "") +
					(dbPass == null ? DB_PASS_ENV + " " : "")
			);
			throw new SQLException("Database configuration environment variables are missing.");
		}

		// Construct the JDBC URL dynamically
		// Example: jdbc:postgresql://your-rds-endpoint:5432/phong
		String jdbcUrl = String.format("jdbc:postgresql://%s:%s/%s", dbHost, dbPort, dbName);

		// Load the PostgreSQL driver (ensure the driver JAR is in your WAR's WEB-INF/lib)
		Class.forName("org.postgresql.Driver");

		// Get connection - **DO NOT STORE STATICALLY**. Return a new connection.
		// A Connection Pool (like HikariCP or Tomcat DBCP) is STRONGLY recommended for production.
		Connection connection = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);

		return connection; // Return the newly created connection
	}

	/**
	 * Utility method to safely close a Connection, Statement, and ResultSet.
	 * Closes resources in the correct order (ResultSet -> Statement -> Connection).
	 * Suppresses exceptions during closing, logging them instead (optional).
	 *
	 * @param conn The Connection to close (can be null).
	 * @param stmt The Statement to close (can be null).
	 * @param rs   The ResultSet to close (can be null).
	 */
	public static void closeConnection(Connection conn, Statement stmt, ResultSet rs) {
		try {
			if (rs != null) {
				rs.close();
			}
		} catch (SQLException e) {
			System.err.println("Warning: Failed to close ResultSet: " + e.getMessage());
			// Log exception properly in a real application
		}
		try {
			if (stmt != null) {
				stmt.close();
			}
		} catch (SQLException e) {
			System.err.println("Warning: Failed to close Statement: " + e.getMessage());
			// Log exception properly in a real application
		}
		try {
			// Check if conn is not null AND not already closed before trying to close
			if (conn != null && !conn.isClosed()) {
				conn.close();
			}
		} catch (SQLException e) {
			System.err.println("Warning: Failed to close Connection: " + e.getMessage());
			// Log exception properly in a real application
		}
	}

	/**
	 * Overloaded version for PreparedStatement.
	 */
	public static void closeConnection(Connection conn, PreparedStatement pstmt, ResultSet rs) {
		// Delegate to the Statement version, as PreparedStatement is a subclass of Statement
		closeConnection(conn, (Statement)pstmt, rs);
	}

	/**
	 * Overloaded version when no ResultSet is involved.
	 */
	public static void closeConnection(Connection conn, Statement stmt) {
		closeConnection(conn, stmt, null);
	}

	/**
	 * Overloaded version for PreparedStatement when no ResultSet is involved.
	 */
	public static void closeConnection(Connection conn, PreparedStatement pstmt) {
		closeConnection(conn, (Statement)pstmt, null);
	}

	/**
	 * Overloaded version when only the Connection needs closing (less common in JDBC flows).
	 */
	public static void closeConnection(Connection conn) {
		closeConnection(conn, null, null);
	}
}