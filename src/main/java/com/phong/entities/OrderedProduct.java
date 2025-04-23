package com.phong.entities;

public class OrderedProduct {
	
	private int id;
	private String name;
	private int quantity;
	private float price;
	private String image;
	private int orderId;
	private int vendorId;
	
	public OrderedProduct() {
		super();
	}

	public OrderedProduct(String name, int quantity, float price, String image, int orderId, int vendorId) {
		super();
		this.name = name;
		this.quantity = quantity;
		this.price = price;
		this.image = image;
		this.orderId = orderId;
		this.vendorId = vendorId;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getQuantity() {
		return quantity;
	}

	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}

	public float getPrice() {
		return price;
	}

	public void setPrice(float price) {
		this.price = price;
	}

	public String getImage() {
		return image;
	}

	public void setImage(String image) {
		this.image = image;
	}

	public int getOrderId() {
		return orderId;
	}

	public void setOrderId(int orderId) {
		this.orderId = orderId;
	}

	public int getVendorId() {
		return vendorId;
	}

	public void setVendorId(int vendorId) {
		this.vendorId = vendorId;
	}
	
}
