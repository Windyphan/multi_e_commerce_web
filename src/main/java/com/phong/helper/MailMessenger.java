package com.phong.helper;
import com.phong.entities.OrderedProduct;

import java.util.List;

public class MailMessenger {

	public static void successfullyRegister(String userName, String userEmail) {

		String subject = "Welcome to Phong - Successful Registration!";
		String body = "Hi " + userName
				+ ",<p>Congratulations and a warm welcome to Phong! We are thrilled to have you as a part of our growing community. Thank you for choosing us for your online shopping needs.</p>"
				+ "<p>Your registration was successful, and we are excited to inform you that you are now a valued member of our platform. With Phong, you'll discover a wide selection of products and exciting deals that cater to your interests and preferences."
				+ "<p>Once again, welcome aboard! We look forward to serving you and making your shopping experience delightful and rewarding.</p>"
				+ "<p>Happy shopping!</p>";
		try {
			Mail.sendMail(userEmail, subject, body);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static void successfullyOrderPlaced(String userName, String userEmail, String orderId, String OrderDate) {
		String subject = "Order Confirmation - Your Product is on its way!";
		String body = "Hi " + userName
				+ ",<p>We are delighted to inform you that your order has been successfully placed and is now being processed. Thank you for choosing Phong for your shopping needs!</p>"
				+ "<p>Order Details: <br>" + "Order Number: " + orderId + "<br>Order Date: " + OrderDate + "</p>"
				+ "<p>Please note that your order is currently being prepared for shipment. Our dedicated team is working diligently to ensure that your products are packed securely and dispatched at the earliest.</p>"
				+ "<p>Once your order is shipped, we will send you another email containing the tracking details, allowing you to monitor its journey until it reaches your doorstep. We understand how exciting it is to receive a package, and we'll do our best to get it to you as soon as possible.</p>"
				+ "<p>Thank you for shopping with us! Your trust in <b>Phong</b> means a lot to us, and we promise to provide you with an exceptional shopping experience.</p>";
		try {
			Mail.sendMail(userEmail, subject, body);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static void orderShipped(String userName, String userEmail, String orderId, String OrderDate) {
		String subject = "Your Order is Out for Delivery!";
		String body = "Hi " + userName
				+ "<p>Greetings from <b>Phong</b>! We are thrilled to inform you that your order is on its way to you. Your package has been successfully shipped and will soon be at your doorstep!</p>"
				+ "<p>Order Details: <br>" + "Order Number: " + orderId + "<br>Order Date: " + OrderDate + "</p>"
				+ "<p>Our dedicated team has carefully processed and packed your order to ensure that it reaches you in perfect condition. As it is out for delivery, our trusted delivery partner is committed to bringing your package to you as swiftly as possible.</p>"
				+ "<p>Once again, we appreciate your trust in <b>Phong</b> for your shopping needs. We aim to provide you with an outstanding shopping experience, and your satisfaction is our priority.</p>"
				+ "<p>Thank you for choosing us!</p>";
		try {
			Mail.sendMail(userEmail, subject, body);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static void sendOtp(String userEmail, int code) {
		String subject = "Verification code for password change";
		String body = "Hi, " + "<p>Please use the below verification code to reset your password!</p>" + "<h3>" + code
				+ "</h3>";
		try {
			Mail.sendMail(userEmail, subject, body);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static void notifyVendorOfStatusUpdate(String vendorShopName, String vendorEmail, String orderId,
												  String newStatus, String customerName, List<OrderedProduct> vendorItems) {

		String subject = "Order Update [" + orderId + "] - Status: " + newStatus;

		// Build the email body
		StringBuilder bodyBuilder = new StringBuilder();
		bodyBuilder.append("Hi ").append(vendorShopName).append(",<br><br>");
		bodyBuilder.append("The status for order <strong>#").append(orderId).append("</strong> placed by customer '")
				.append(customerName).append("' has been updated to: <strong>").append(newStatus).append("</strong><br><br>");

		if ("Shipped".equalsIgnoreCase(newStatus) || "Out For Delivery".equalsIgnoreCase(newStatus)) {
			bodyBuilder.append("Please ensure you have updated tracking information if applicable.<br><br>");
		} else if ("Delivered".equalsIgnoreCase(newStatus)) {
			bodyBuilder.append("The order has been marked as delivered.<br><br>");
		} else if ("Order Confirmed".equalsIgnoreCase(newStatus)) {
			bodyBuilder.append("The order has been confirmed and you may prepare the items for shipment.<br><br>");
		} else {
			bodyBuilder.append("Please review the order details in your dashboard.<br><br>");
		}


		// List the specific items for this vendor in this order
		if (vendorItems != null && !vendorItems.isEmpty()) {
			bodyBuilder.append("The following item(s) from your shop are included in this update:<br>");
			bodyBuilder.append("<ul>");
			for (OrderedProduct item : vendorItems) {
				bodyBuilder.append("<li>").append(item.getName())
						.append(" (Qty: ").append(item.getQuantity())
						.append(")</li>");
			}
			bodyBuilder.append("</ul><br>");
		}

		bodyBuilder.append("Please log in to your vendor dashboard for more details.<br><br>");
		bodyBuilder.append("Thank you,<br>Phong Shop Platform");

		String body = bodyBuilder.toString();

		try {
			System.out.println("Attempting to send vendor status update to: " + vendorEmail); // Log attempt
			Mail.sendMail(vendorEmail, subject, body);
			System.out.println("Vendor status update email presumably sent to: " + vendorEmail); // Log success assumption
		} catch (Exception e) {
			System.err.println("Failed sending vendor status update to " + vendorEmail + " : " + e.getMessage());
			e.printStackTrace(); // Log error
		}
	}
}
