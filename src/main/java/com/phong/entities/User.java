package com.phong.entities;

import java.sql.Timestamp;

public class User {
	
	private int userId;
	private String userName;
	private String userEmail;
	private String userPassword;
	private String userPhone;
	private String userGender;
	private Timestamp dateTime;
	private String userAddress;
	private String userCity;
	private String userPostcode;
	private String userCounty;
	
	public User() {
		
	}

	public User(String userName, String userEmail, String userPassword, String userPhone, String userGender,
			String userAddress, String userCity, String userPostcode, String userCounty) {
		super();
		this.userName = userName;
		this.userEmail = userEmail;
		this.userPassword = userPassword;
		this.userPhone = userPhone;
		this.userGender = userGender;
		this.userAddress = userAddress;
		this.userCity = userCity;
		this.userPostcode = userPostcode;
		this.userCounty = userCounty;
	}

	public User(String userName, String userEmail, String userPassword, String userPhone, String userGender,
			Timestamp dateTime, String userAddress, String userCity, String userPostcode, String userCounty) {
		super();
		this.userName = userName;
		this.userEmail = userEmail;
		this.userPassword = userPassword;
		this.userPhone = userPhone;
		this.userGender = userGender;
		this.dateTime = dateTime;
		this.userAddress = userAddress;
		this.userCity = userCity;
		this.userPostcode = userPostcode;
		this.userCounty = userCounty;
	}
	
	public User(String userName, String userEmail, String userPhone, String userGender, String userAddress,
			String userCity, String userPostcode, String userCounty) {
		super();
		this.userName = userName;
		this.userEmail = userEmail;
		this.userPhone = userPhone;
		this.userGender = userGender;
		this.userAddress = userAddress;
		this.userCity = userCity;
		this.userPostcode = userPostcode;
		this.userCounty = userCounty;
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getUserEmail() {
		return userEmail;
	}

	public void setUserEmail(String userEmail) {
		this.userEmail = userEmail;
	}

	public String getUserPassword() {
		return userPassword;
	}

	public void setUserPassword(String userPassword) {
		this.userPassword = userPassword;
	}

	public String getUserPhone() {
		return userPhone;
	}

	public void setUserPhone(String userPhone) {
		this.userPhone = userPhone;
	}

	public String getUserGender() {
		return userGender;
	}

	public void setUserGender(String userGender) {
		this.userGender = userGender;
	}

	public Timestamp getDateTime() {
		return dateTime;
	}

	public void setDateTime(Timestamp dateTime) {
		this.dateTime = dateTime;
	}

	public String getUserAddress() {
		return userAddress;
	}

	public void setUserAddress(String userAddress) {
		this.userAddress = userAddress;
	}

	public String getUserCity() {
		return userCity;
	}

	public void setUserCity(String userCity) {
		this.userCity = userCity;
	}

	public String getUserPostcode() {
		return userPostcode;
	}

	public void setUserPostcode(String userPostcode) {
		this.userPostcode = userPostcode;
	}

	public String getUserCounty() {
		return userCounty;
	}

	public void setUserCounty(String userCounty) {
		this.userCounty = userCounty;
	}
	
}
