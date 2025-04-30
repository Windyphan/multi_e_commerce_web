package com.phong.dao;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.phong.entities.Vendor;
import com.phong.helper.ConnectionProvider;

public class VendorDao {

    public VendorDao() {}

    /** Saves a new vendor, returning the generated vendor_id */
    public int saveVendor(Vendor vendor) {
        int generatedId = 0;
        String query = "INSERT INTO vendor(shop_name, owner_user_id, business_email, business_phone, is_approved) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement psmt = con.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {

            psmt.setString(1, vendor.getShopName());
            psmt.setInt(2, vendor.getOwnerUserId());
            psmt.setString(3, vendor.getBusinessEmail());
            psmt.setString(4, vendor.getBusinessPhone());
            psmt.setBoolean(5, vendor.isApproved()); // Default is false unless set otherwise

            int rows = psmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = psmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        generatedId = keys.getInt(1);
                    }
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            // Handle unique constraint violations (shop_name, owner_user_id, business_email)
            if (e instanceof SQLException && ((SQLException)e).getSQLState().startsWith("23")) { // Unique violation etc.
                System.err.println("WARN: Could not save vendor due to constraint: " + e.getMessage());
            } else {
                System.err.println("Error saving vendor: " + e.getMessage());
                e.printStackTrace();
            }
        }
        return generatedId;
    }

    /** Retrieves a Vendor by their vendor_id */
    public Vendor getVendorById(int vendorId) {
        Vendor vendor = null;
        String query = "SELECT * FROM vendor WHERE vendor_id = ?";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement psmt = con.prepareStatement(query)) {
            psmt.setInt(1, vendorId);
            try (ResultSet rs = psmt.executeQuery()) {
                if (rs.next()) {
                    vendor = mapResultSetToVendor(rs);
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting vendor by ID " + vendorId + ": " + e.getMessage());
            e.printStackTrace();
        }
        return vendor;
    }

    /** Retrieves a Vendor by the owner's user ID */
    public Vendor getVendorByOwnerUserId(int ownerUserId) {
        Vendor vendor = null;
        String query = "SELECT * FROM vendor WHERE owner_user_id = ?";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement psmt = con.prepareStatement(query)) {
            psmt.setInt(1, ownerUserId);
            try (ResultSet rs = psmt.executeQuery()) {
                if (rs.next()) {
                    vendor = mapResultSetToVendor(rs);
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting vendor by owner user ID " + ownerUserId + ": " + e.getMessage());
            e.printStackTrace();
        }
        return vendor;
    }

    /** Gets all vendors (e.g., for admin listing) */
    public List<Vendor> getAllVendors() {
        List<Vendor> list = new ArrayList<>();
        String query = "SELECT * FROM vendor ORDER BY shop_name";
        try (Connection con = ConnectionProvider.getConnection();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            while(rs.next()){
                list.add(mapResultSetToVendor(rs));
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting all vendors: " + e.getMessage());
            e.printStackTrace();
            return null; // Indicate error
        }
        return list;
    }

    /** Approves a vendor */
    public boolean approveVendor(int vendorId) {
        boolean flag = false;
        String query = "UPDATE vendor SET is_approved = TRUE WHERE vendor_id = ? AND is_approved = FALSE";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement psmt = con.prepareStatement(query)) {
            psmt.setInt(1, vendorId);
            int rows = psmt.executeUpdate();
            if(rows > 0) {
                flag = true;
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error approving vendor ID " + vendorId + ": " + e.getMessage());
            e.printStackTrace();
        }
        return flag;
    }

    /** Suspend a vendor */
    public boolean suspendVendor(int vendorId) {
        boolean flag = false;
        String query = "UPDATE vendor SET is_approved = FALSE WHERE vendor_id = ? AND is_approved = TRUE";
        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement psmt = con.prepareStatement(query)) {
            psmt.setInt(1, vendorId);
            int rows = psmt.executeUpdate();
            if(rows > 0) {
                flag = true;
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error suspending vendor ID " + vendorId + ": " + e.getMessage());
            e.printStackTrace();
        }
        return flag;
    }

    // Add updateVendor
    public boolean updateVendor(Vendor vendor) {
        boolean flag = false;
        // Update only fields vendors should be able to change
        String query = "UPDATE vendor SET shop_name = ?, business_email = ?, business_phone = ? " +
                // ", description = ?, logo_image = ?, etc... " +
                "WHERE vendor_id = ?"; // Update based on primary key

        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement psmt = con.prepareStatement(query)) {

            psmt.setString(1, vendor.getShopName());
            psmt.setString(2, vendor.getBusinessEmail());
            psmt.setString(3, vendor.getBusinessPhone());
            // Set other parameters for update...
            psmt.setInt(4, vendor.getVendorId()); // WHERE clause parameter (adjust index based on SET clause)

            int rowsAffected = psmt.executeUpdate();
            if (rowsAffected > 0) {
                flag = true;
            }
        } catch (SQLException | ClassNotFoundException e) {
            if (e instanceof SQLException && ((SQLException)e).getSQLState().startsWith("23")) {
                System.err.println("WARN: Could not update vendor due to constraint (e.g., duplicate shop name/email): " + e.getMessage());
            } else {
                System.err.println("Error updating vendor ID " + vendor.getVendorId() + ": " + e.getMessage());
                e.printStackTrace();
            }
        }
        return flag;
    }

    /**
     * Calculates sales summary (items sold, total revenue) for a vendor within a date range.
     * Considers only items from orders with status 'Shipped' or 'Delivered'.
     *
     * @param vendorId The ID of the vendor.
     * @param startDate The start date of the period (inclusive).
     * @param endDate The end date of the period (inclusive).
     * @return A Map containing "itemsSold" (Long) and "totalRevenue" (Double/BigDecimal), or null on error. Returns 0 values if no sales.
     */
    public Map<String, Number> getVendorSalesSummaryForPeriod(int vendorId, LocalDate startDate, LocalDate endDate) {
        Map<String, Number> summary = new HashMap<>();
        summary.put("itemsSold", 0L); // Default to 0 (use Long for count)
        summary.put("totalRevenue", 0.0); // Default to 0.0 (use Double or BigDecimal)

        // Query joins ordered_product with order table to filter by date and status
        // and calculates SUM of quantity and SUM of (quantity * price)
        String query = "SELECT " +
                "  COALESCE(SUM(op.quantity), 0) AS total_items, " +
                "  COALESCE(SUM(op.quantity * op.price), 0.0) AS total_value " +
                "FROM ordered_product op " +
                "JOIN \"order\" o ON op.orderid = o.id " +
                "WHERE op.vendor_id = ? " +
                "  AND o.status IN ('Shipped', 'Delivered') " + // Filter by relevant statuses
                "  AND o.date >= ? " +                         // Filter by start date
                "  AND o.date <= ? ";                          // Filter by end date (exclusive for timestamp comparison)

        // Use < endDate + 1 day because timestamp comparison should usually be exclusive for the end boundary
        LocalDate nextDay = endDate.plusDays(1);

        try (Connection con = ConnectionProvider.getConnection();
             PreparedStatement psmt = con.prepareStatement(query)) {

            psmt.setInt(1, vendorId);
            psmt.setDate(2, Date.valueOf(startDate)); // Convert LocalDate to java.sql.Date
            psmt.setDate(3, Date.valueOf(nextDay));   // Use next day for exclusive end boundary

            try (ResultSet rs = psmt.executeQuery()) {
                if (rs.next()) {
                    summary.put("itemsSold", rs.getLong("total_items"));
                    summary.put("totalRevenue", rs.getDouble("total_value")); // Use getDouble for NUMERIC/DECIMAL
                }
                // If no rows match WHERE clause, COALESCE returns 0, so defaults are fine.
            }

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Error getting vendor sales summary for vendor ID " + vendorId +
                    " between " + startDate + " and " + endDate + ": " + e.getMessage());
            e.printStackTrace();
            return null; // Indicate error
        }
        return summary;
    }

    // Helper
    private Vendor mapResultSetToVendor(ResultSet rs) throws SQLException {
        Vendor vendor = new Vendor();
        vendor.setVendorId(rs.getInt("vendor_id"));
        vendor.setShopName(rs.getString("shop_name"));
        vendor.setOwnerUserId(rs.getInt("owner_user_id"));
        vendor.setBusinessEmail(rs.getString("business_email"));
        vendor.setBusinessPhone(rs.getString("business_phone"));
        vendor.setRegistrationDate(rs.getTimestamp("registration_date"));
        vendor.setApproved(rs.getBoolean("is_approved"));
        // map other fields if added
        return vendor;
    }
}