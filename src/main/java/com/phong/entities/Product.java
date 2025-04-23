package com.phong.entities;

public class Product {

	private int productId;
    private String productName;
    private String productDescription;
    private float productPrice;
    private int productDiscount;
    private int productQuantity;
    private String productImages;
    private int categoryId;
	private int vendorId;
    
	public Product() {
		super();
	}
	
	public Product(int productId, String productName, String productDescription, float productPrice,
			int productDiscount, int productQuantity, String productImages, int categoryId, int vendorId) {
		super();
		this.productId = productId;
		this.productName = productName;
		this.productDescription = productDescription;
		this.productPrice = productPrice;
		this.productDiscount = productDiscount;
		this.productQuantity = productQuantity;
		this.productImages = productImages;
		this.categoryId = categoryId;
		this.vendorId = vendorId;
	}

	public Product(String productName, String productDescription, float productPrice, int productDiscount,
			int productQuantity, String productImages) {
		super();
		this.productName = productName;
		this.productDescription = productDescription;
		this.productPrice = productPrice;
		this.productDiscount = productDiscount;
		this.productQuantity = productQuantity;
		this.productImages = productImages;
	}

	public Product(String productName, String productDescription, float productPrice, int productDiscount,
			int productQuantity, String productImages, int categoryId, int vendorId) {
		super();
		this.productName = productName;
		this.productDescription = productDescription;
		this.productPrice = productPrice;
		this.productDiscount = productDiscount;
		this.productQuantity = productQuantity;
		this.productImages = productImages;
		this.categoryId = categoryId;
		this.vendorId = vendorId;
	}
	
	public Product(int productId, String productName, float productPrice, int productDiscount, int productQuantity) {
		super();
		this.productId = productId;
		this.productName = productName;
		this.productPrice = productPrice;
		this.productDiscount = productDiscount;
		this.productQuantity = productQuantity;
	}

	public int getProductId() {
		return productId;
	}

	public void setProductId(int productId) {
		this.productId = productId;
	}

	public String getProductName() {
		return productName;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public String getProductDescription() {
		return productDescription;
	}

	public void setProductDescription(String productDescription) {
		this.productDescription = productDescription;
	}

	public float getProductPrice() {
		return productPrice;
	}

	public void setProductPrice(float productPrice) {
		this.productPrice = productPrice;
	}

	public int getProductDiscount() {
		return productDiscount;
	}

	public void setProductDiscount(int productDiscount) {
		this.productDiscount = productDiscount;
	}

	public int getProductQuantity() {
		return productQuantity;
	}

	public void setProductQuantity(int productQuantity) {
		this.productQuantity = productQuantity;
	}

	public String getProductImages() {
		return productImages;
	}

	public void setProductImages(String productImages) {
		this.productImages = productImages;
	}

	public int getCategoryId() {
		return categoryId;
	}

	public void setCategoryId(int categoryId) {
		this.categoryId = categoryId;
	}

	public int getVendorId() {
		return vendorId;
	}

	public void setVendorId(int vendorId) {
		this.vendorId = vendorId;
	}

	//calculate price of product by applying discount
    public float getProductPriceAfterDiscount(){
        float discount = (float) ((this.getProductDiscount()/100.0) * this.getProductPrice());
        return this.getProductPrice() - discount;
    }
	
	@Override
	public String toString() {
		return "Product [productId=" + productId + ", productName=" + productName + ", productDescription="
				+ productDescription + ", productPrice=" + productPrice + ", productDiscount=" + productDiscount
				+ ", productQuantity=" + productQuantity + ", productImages=" + productImages + ", categoryId="
				+ categoryId + ", vendorId=" + vendorId + "]";
	}
    
    
}
