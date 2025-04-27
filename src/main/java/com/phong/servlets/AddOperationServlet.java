package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.phong.dao.CategoryDao;
import com.phong.dao.ProductDao;
import com.phong.dao.VendorDao;
import com.phong.entities.Category;
import com.phong.entities.Message; // Keep for potential non-AJAX errors if needed later
import com.phong.entities.Product;
import com.phong.entities.Admin;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception;
import software.amazon.awssdk.core.sync.RequestBody;

@MultipartConfig
public class AddOperationServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	// --- Configuration ---
	private static final String S3_BUCKET_NAME = "phong-ecommerce-assets";
	private static final String S3_REGION_ID = "eu-north-1";
	private static final String S3_FOLDER_PATH = "Product_imgs/";
	// Helper to create the S3 client (ensure credentials are provided via Instance Profile)
	private S3Client getS3Client() {
		Region region = Region.of(S3_REGION_ID);
		// The SDK will automatically use credentials from the EC2 Instance Profile
		// when running on Elastic Beanstalk/EC2 if the role has S3 permissions.
		return S3Client.builder()
				.region(region)
				.build();
	}

	// Helper method to upload to S3
	private String uploadFileToS3(Part part, String existingFileName) throws IOException, S3Exception {
		if (part == null || part.getSize() == 0 || part.getSubmittedFileName() == null || part.getSubmittedFileName().isEmpty()) {
			System.err.println("S3 Upload: No file part provided or file is empty.");
			return existingFileName; // Return existing name if no new file
		}

		String originalFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
		if (originalFileName.isEmpty()) {
			System.err.println("S3 Upload: Invalid submitted filename.");
			return existingFileName; // Return existing name if new name invalid
		}

		// Generate unique filename
		String fileExtension = "";
		int lastDot = originalFileName.lastIndexOf('.');
		if (lastDot > 0) {
			fileExtension = originalFileName.substring(lastDot); // e.g., ".jpg"
		}
		// Using UUID for better uniqueness than timestamp
		String uniqueFileName = UUID.randomUUID().toString() + fileExtension;
		String objectKey = S3_FOLDER_PATH + uniqueFileName;

		System.out.println("Attempting to upload to S3: bucket=" + S3_BUCKET_NAME + ", key=" + objectKey);

		S3Client s3 = getS3Client();
		try (InputStream fileInputStream = part.getInputStream()) {
			PutObjectRequest putObjectRequest = PutObjectRequest.builder()
					.bucket(S3_BUCKET_NAME)
					.key(objectKey)
					.contentType(part.getContentType()) // Important for browser display
					// ACLs are usually not needed if bucket policy allows public read
					// .acl(ObjectCannedACL.PUBLIC_READ)
					.build();

			// Upload file
			s3.putObject(putObjectRequest, RequestBody.fromInputStream(fileInputStream, part.getSize()));
			System.out.println("S3 Upload successful for key: " + objectKey);
			return uniqueFileName; // Return the new unique filename ONLY

		} catch (S3Exception e) {
			System.err.println("S3 Upload Error: " + e.awsErrorDetails().errorMessage());
			e.printStackTrace();
			throw e; // Re-throw to be caught by servlet's main catch block
		} finally {
			s3.close(); // Close client
		}
	}

	// Helper method to delete from S3
	private boolean deleteFileFromS3(String fileName) {
		if (fileName == null || fileName.trim().isEmpty()) {
			System.out.println("S3 Delete: No filename provided to delete.");
			return true; // Consider deletion successful if no file exists
		}
		String objectKey = S3_FOLDER_PATH + fileName.trim();
		System.out.println("Attempting to delete from S3: bucket=" + S3_BUCKET_NAME + ", key=" + objectKey);
		S3Client s3 = getS3Client();
		try {
			DeleteObjectRequest deleteObjectRequest = DeleteObjectRequest.builder()
					.bucket(S3_BUCKET_NAME)
					.key(objectKey)
					.build();
			s3.deleteObject(deleteObjectRequest);
			System.out.println("S3 Delete successful for key: " + objectKey);
			return true;
		} catch (S3Exception e) {
			System.err.println("S3 Delete Error: " + e.awsErrorDetails().errorMessage());
			e.printStackTrace();
			return false; // Indicate delete failure
		} finally {
			s3.close();
		}
	}
	// --- End S3 ---

	private final ObjectMapper objectMapper = new ObjectMapper();

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession();

		// Security Check
		Admin activeAdmin = (Admin) session.getAttribute("activeAdmin");
		if (activeAdmin == null) {
			// For AJAX, we should return a JSON error, not redirect immediately
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // Set 401 status
			PrintWriter out = response.getWriter();
			Map<String, Object> errorResponse = new HashMap<>();
			errorResponse.put("status", "error");
			errorResponse.put("message", "Unauthorized access. Please log in as admin.");
			out.print(objectMapper.writeValueAsString(errorResponse));
			out.flush();
			return;
		}

		// Get Operation
		String operation = request.getParameter("operation");
		if (operation == null || operation.trim().isEmpty()) {
			sendJsonError(response, "No operation specified.");
			return;
		}
		operation = operation.trim();

		// --- Setup for JSON Response ---
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		PrintWriter out = response.getWriter();
		Map<String, Object> jsonResponse = new HashMap<>();
		String jsonStatus = "error"; // Default status
		String jsonMessage = "An unknown error occurred."; // Default message

		// DAOs
		CategoryDao categoryDao = new CategoryDao();
		ProductDao productDao = new ProductDao();
		VendorDao vendorDao = new VendorDao();

		// --- Process ALL Operations within a Single Try-Catch for AJAX ---
		try {
			String fileOpResultName = null;
			String oldFileNameToDeleteOnSuccess = null;
			boolean fileOpOccurred = false;

			// --- Category Operations ---
			if (operation.equals("addCategory")) {
				Part part = request.getPart("category_img");
				String categoryName = request.getParameter("category_name");

				if (categoryName == null || categoryName.trim().isEmpty()) throw new Exception("Category name is required.");
				if (part == null || part.getSize() == 0 || part.getSubmittedFileName() == null || part.getSubmittedFileName().trim().isEmpty()) throw new Exception("Category image is required.");

				fileOpResultName = uploadFileToS3(part, null);
				if (fileOpResultName != null) {
					Category category = new Category(categoryName.trim(), fileOpResultName);
					boolean saveSuccess = categoryDao.saveCategory(category);
					Category savedCategory = null;
					if(saveSuccess) {
						savedCategory = category; // TEMPORARY - Lacks ID
						System.err.println("WARN: addCategory response lacks generated ID. Modify DAO.saveCategory or fetch category again.");
					}

					if (savedCategory != null) {
						jsonStatus = "success";
						jsonMessage = "Category added successfully!";
						jsonResponse.put("newCategory", savedCategory);
					} else {
						jsonMessage = "Image uploaded, but failed to save category to database!";
						deleteFileFromS3(fileOpResultName); // Rollback S3
					}
				} else {
					jsonMessage = "Failed to upload category image.";
				}

			} else if (operation.equals("updateCategory")) {
				Part part = request.getPart("category_img");
				int cid = Integer.parseInt(request.getParameter("cid").trim());
				String name = request.getParameter("category_name");
				String existingImage = request.getParameter("image");

				if (name == null || name.trim().isEmpty()) throw new Exception("Category name is required for update.");

				String finalImageNameToSave = existingImage;
				boolean newFileProvided = (part != null && part.getSize() > 0 && part.getSubmittedFileName() != null && !part.getSubmittedFileName().trim().isEmpty());

				if (newFileProvided) {
					fileOpResultName = uploadFileToS3(part, existingImage);
					if (fileOpResultName != null && !fileOpResultName.equals(existingImage)) {
						finalImageNameToSave = fileOpResultName;
						oldFileNameToDeleteOnSuccess = existingImage;
						fileOpOccurred = true;
					} else {
						System.err.println("Product Update: Upload of new image failed or was same. Keeping existing.");
						// Maybe set warning: jsonMessage = "Details updated, but image upload failed.";
					}
				}

				Category categoryToUpdate = new Category(cid, name.trim(), finalImageNameToSave);
				boolean dbSuccess = categoryDao.updateCategory(categoryToUpdate);

				if (dbSuccess) {
					jsonStatus = "success";
					jsonMessage = "Category updated successfully!";
					if (fileOpOccurred && oldFileNameToDeleteOnSuccess != null) {
						deleteFileFromS3(oldFileNameToDeleteOnSuccess);
					}
					jsonResponse.put("updatedCategory", categoryToUpdate);
				} else {
					jsonMessage = "Failed to update category in database.";
					if (fileOpOccurred && oldFileNameToDeleteOnSuccess != null) {
						deleteFileFromS3(finalImageNameToSave); // Rollback new S3 upload
					}
				}

			} else if (operation.equals("deleteCategory")) {
				int cid = Integer.parseInt(request.getParameter("cid").trim());
				Category catToDelete = categoryDao.getCategoryById(cid);
				if (catToDelete == null) throw new Exception("Category not found for deletion.");

				oldFileNameToDeleteOnSuccess = catToDelete.getCategoryImage();
				boolean dbSuccess = categoryDao.deleteCategory(cid);

				if (dbSuccess) {
					jsonStatus = "success";
					jsonMessage = "Category deleted successfully!";
					deleteFileFromS3(oldFileNameToDeleteOnSuccess);
					jsonResponse.put("deletedCategoryId", cid);
				} else {
					jsonMessage = "Failed to delete category (might be in use or DB error).";
				}

				// --- Vendor Operations ---
			} else if (operation.equals("approveVendor") || operation.equals("suspendVendor")) {
				int vendorId = Integer.parseInt(request.getParameter("vid"));
				boolean dbSuccess = false;
				boolean newStatusIsApproved = false;

				if (operation.equals("approveVendor")) {
					dbSuccess = vendorDao.approveVendor(vendorId);
					newStatusIsApproved = dbSuccess; // Status is approved if success
					jsonMessage = dbSuccess ? "Vendor approved successfully." : "Failed to approve vendor.";
				} else { // suspendVendor
					dbSuccess = vendorDao.suspendVendor(vendorId);
					newStatusIsApproved = !dbSuccess; // Status is NOT approved if success (it's suspended)
					jsonMessage = dbSuccess ? "Vendor suspended successfully." : "Failed to suspend vendor.";
				}

				if(dbSuccess) {
					jsonStatus = "success";
					jsonResponse.put("vendorId", vendorId);
					jsonResponse.put("isApproved", newStatusIsApproved);
				} // else status remains 'error', message set above

				// --- Product Operations ---
			} else if (operation.equals("updateProduct")) {
				Part part = request.getPart("product_img");
				int pid = Integer.parseInt(request.getParameter("pid").trim());
				String name = request.getParameter("name");
				String priceStr = request.getParameter("price");
				String description = request.getParameter("description");
				String quantityStr = request.getParameter("quantity");
				String discountStr = request.getParameter("discount");
				String categoryIdStr = request.getParameter("categoryType");
				String existingImage = request.getParameter("image");

				if (name == null || name.trim().isEmpty() || priceStr == null || categoryIdStr == null) throw new Exception("Name, Price, Category are required.");
				float price = Float.parseFloat(priceStr.trim());
				int quantity = Integer.parseInt(quantityStr.trim());
				int discount = Integer.parseInt(discountStr.trim());
				int cid = Integer.parseInt(categoryIdStr.trim());
				if (price < 0 || quantity < 0 || cid <= 0) throw new Exception("Invalid price, quantity, or category.");
				if (discount < 0 || discount > 100) discount = 0;

				String finalImageNameToSave = existingImage;
				boolean newFileProvided = (part != null && part.getSize() > 0 && part.getSubmittedFileName() != null && !part.getSubmittedFileName().trim().isEmpty());

				if (newFileProvided) {
					fileOpResultName = uploadFileToS3(part, existingImage);
					if (fileOpResultName != null && !fileOpResultName.equals(existingImage)) {
						finalImageNameToSave = fileOpResultName;
						oldFileNameToDeleteOnSuccess = existingImage;
						fileOpOccurred = true;
					} else {
						System.err.println("Product Update: Upload of new image failed or was same. Keeping existing.");
						// Maybe set warning: jsonMessage = "Details updated, but image upload failed.";
					}
				}

				Product existingProduct = productDao.getProductsByProductId(pid);
				if (existingProduct == null) throw new Exception("Product not found.");

				Product productToUpdate = new Product(pid, name.trim(), description.trim(), price, discount, quantity, finalImageNameToSave, cid, existingProduct.getVendorId());
				boolean dbSuccess = productDao.updateProduct(productToUpdate);

				if (dbSuccess) {
					jsonStatus = "success";
					jsonMessage = "Product updated successfully!";
					if (fileOpOccurred && oldFileNameToDeleteOnSuccess != null) {
						deleteFileFromS3(oldFileNameToDeleteOnSuccess);
					}
					// Fetch updated product data again to include calculated priceAfterDiscount if needed by JS
					Product fetchedUpdatedProduct = productDao.getProductsByProductId(pid);
					jsonResponse.put("updatedProduct", fetchedUpdatedProduct != null ? fetchedUpdatedProduct : productToUpdate ); // Send back updated product
				} else {
					jsonMessage = "Failed to update product in database.";
					if (fileOpOccurred && oldFileNameToDeleteOnSuccess != null) {
						deleteFileFromS3(finalImageNameToSave); // Rollback S3
					}
				}

			} else if (operation.equals("deleteProduct")) {
				int pid = Integer.parseInt(request.getParameter("pid").trim());
				Product prodToDelete = productDao.getProductsByProductId(pid);
				if (prodToDelete == null) throw new Exception("Product not found for deletion.");

				String imageToDelete = prodToDelete.getProductImages();
				boolean dbSuccess = productDao.deleteProduct(pid);

				if (dbSuccess) {
					jsonStatus = "success";
					jsonMessage = "Product deleted successfully!";
					deleteFileFromS3(imageToDelete);
					jsonResponse.put("deletedProductId", pid);
				} else {
					jsonMessage = "Failed to delete product (DB error or constraints).";
				}

				// --- Unknown Operation ---
			} else {
				jsonMessage = "Unknown operation specified: " + operation;
				// Status remains 'error'
			}

		} catch (NumberFormatException nfe) { jsonMessage = "Invalid number format provided."; logError(operation, nfe); }
		catch (S3Exception s3e) { jsonMessage = "Storage error: " + s3e.awsErrorDetails().errorMessage(); logError(operation, s3e); }
		catch (IOException | ServletException io_se) { jsonMessage = "Error processing request/file: "+ io_se.getMessage(); logError(operation, io_se); }
		catch (Exception e) { jsonMessage = "Error: " + e.getMessage(); logError(operation, e); }

		// --- Send the final JSON Response ---
		jsonResponse.put("status", jsonStatus);
		jsonResponse.put("message", jsonMessage);
		out.print(objectMapper.writeValueAsString(jsonResponse));
		out.flush();
		// No redirect needed, AJAX handles response
	}


	// Helper to log errors consistently
	private void logError(String operation, Exception e) {
		System.err.println("Error during AJAX operation '" + operation + "': " + e.getMessage());
		e.printStackTrace(); // Print stack trace for details
	}

	// Helper to send JSON error (used for early exits like missing operation)
	private void sendJsonError(HttpServletResponse response, String message) throws IOException {
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // Set 400 status for bad request
		PrintWriter out = response.getWriter();
		Map<String, Object> errorResponse = new HashMap<>();
		errorResponse.put("status", "error");
		errorResponse.put("message", message);
		out.print(objectMapper.writeValueAsString(errorResponse));
		out.flush();
	}


	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		// Reject GET requests for modification operations
		sendJsonError(resp, "GET method not supported for this operation.");
	}
}