package com.phong.helper;

import java.sql.Connection;
import java.sql.DriverManager;
import javax.servlet.http.HttpServlet;

public class ConnectionProvider extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private static Connection connection;

	public static Connection getConnection() {

		try {
			if (connection == null) {
				Class.forName("org.postgresql.Driver"); // PostgreSQL Driver
				connection = DriverManager.getConnection(
						"jdbc:postgresql://localhost:5432/phong", // PostgreSQL JDBC URL
						"postgres", // PostgreSQL username
						"postgres"); // PostgreSQL password
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return connection;
	}
}