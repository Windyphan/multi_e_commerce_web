package com.phong.entities;

import java.sql.Timestamp;

public class Vendor {
    private int vendorId;
    private String shopName;
    private int ownerUserId; // Link to the User entity
    private String businessEmail;
    private String businessPhone;
    private Timestamp registrationDate;
    private boolean isApproved;
    // Add other fields if you included them in the DB (description, logo, etc.)

    // Constructors
    public Vendor() { }

    public Vendor(String shopName, int ownerUserId, String businessEmail, String businessPhone, boolean isApproved) {
        this.shopName = shopName;
        this.ownerUserId = ownerUserId;
        this.businessEmail = businessEmail;
        this.businessPhone = businessPhone;
        this.isApproved = isApproved;
    }

    // Full constructor
    public Vendor(int vendorId, String shopName, int ownerUserId, String businessEmail, String businessPhone, Timestamp registrationDate, boolean isApproved) {
        this.vendorId = vendorId;
        this.shopName = shopName;
        this.ownerUserId = ownerUserId;
        this.businessEmail = businessEmail;
        this.businessPhone = businessPhone;
        this.registrationDate = registrationDate;
        this.isApproved = isApproved;
    }

    // --- Getters and Setters for all fields ---
    public int getVendorId() { return vendorId; }
    public void setVendorId(int vendorId) { this.vendorId = vendorId; }
    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }
    public int getOwnerUserId() { return ownerUserId; }
    public void setOwnerUserId(int ownerUserId) { this.ownerUserId = ownerUserId; }
    public String getBusinessEmail() { return businessEmail; }
    public void setBusinessEmail(String businessEmail) { this.businessEmail = businessEmail; }
    public String getBusinessPhone() { return businessPhone; }
    public void setBusinessPhone(String businessPhone) { this.businessPhone = businessPhone; }
    public Timestamp getRegistrationDate() { return registrationDate; }
    public void setRegistrationDate(Timestamp registrationDate) { this.registrationDate = registrationDate; }
    public boolean isApproved() { return isApproved; }
    public void setApproved(boolean approved) { isApproved = approved; }

    // Consider adding toString()
}