package com.phong.helper;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Date;
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

	private static final String DB_HOST_ENV = "DB_HOST";
	private static final String DB_PORT_ENV = "DB_PORT";
	private static final String DB_NAME_ENV = "DB_NAME";
	private static final String DB_USER_ENV = "DB_USER";
	private static final String DB_PASS_ENV = "DB_PASS";

	public static Connection getConnection() throws SQLException, ClassNotFoundException {
		// *** START DEBUG LOGGING ***
		System.out.println("### CONN_PROVIDER [" + new Date() + "]: Attempting getConnection()...");

		String dbHost = System.getenv(DB_HOST_ENV);
		String dbPort = System.getenv(DB_PORT_ENV);
		String dbName = System.getenv(DB_NAME_ENV);
		String dbUser = System.getenv(DB_USER_ENV);
		// Avoid logging password directly in real scenarios
		String dbPass = System.getenv(DB_PASS_ENV);
		boolean passPresent = (dbPass != null && !dbPass.isEmpty()); // Log presence, not value

		System.out.println("### CONN_PROVIDER [" + new Date() + "]: Env Vars Read: " +
				" HOST=" + dbHost +
				" PORT=" + dbPort +
				" NAME=" + dbName +
				" USER=" + dbUser +
				" PASS_PRESENT=" + passPresent);
		// *** END DEBUG LOGGING ***

		if (dbHost == null || dbPort == null || dbName == null || dbUser == null || dbPass == null) {
			System.err.println("### CONN_PROVIDER [" + new Date() + "]: CRITICAL ERROR: Database environment variables not set! Throwing SQLException.");
			throw new SQLException("Database configuration environment variables are missing.");
		}

		String jdbcUrl = String.format("jdbc:postgresql://%s:%s/%s", dbHost, dbPort, dbName);
		System.out.println("### CONN_PROVIDER [" + new Date() + "]: Loading driver...");
		Class.forName("org.postgresql.Driver");
		System.out.println("### CONN_PROVIDER [" + new Date() + "]: Driver loaded. Connecting to " + jdbcUrl + " as " + dbUser);
		Connection connection = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
		System.out.println("### CONN_PROVIDER [" + new Date() + "]: Connection SUCCESS!");
		return connection;
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