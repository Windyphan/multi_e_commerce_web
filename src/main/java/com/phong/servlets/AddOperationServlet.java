package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

// Remove File I/O imports if no longer needed elsewhere
// import java.io.File;
// import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.util.UUID; // For unique filenames

import com.phong.dao.CategoryDao;
import com.phong.dao.ProductDao;
import com.phong.dao.VendorDao;
import com.phong.entities.Category;
import com.phong.entities.Message;
import com.phong.entities.Product;
import com.phong.entities.Admin;

// AWS S3 SDK Imports
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception; // More specific exception
import software.amazon.awssdk.core.sync.RequestBody;

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


	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession();
		Message message = null;
		String redirectPage = "";

		// Security Check
		Admin activeAdmin = (Admin) session.getAttribute("activeAdmin");
		if (activeAdmin == null) {
			message = new Message("Unauthorized access. Please log in as admin.", "error", "alert-danger");
			session.setAttribute("message", message);
			response.sendRedirect("adminlogin.jsp");
			return;
		}

		// DAOs
		CategoryDao categoryDao = new CategoryDao();
		ProductDao productDao = new ProductDao();
		VendorDao vendorDao = new VendorDao();

		// Operation
		String operation = request.getParameter("operation");
		if (operation == null || operation.trim().isEmpty()) {
			message = new Message("No operation specified.", "error", "alert-warning");
			session.setAttribute("message", message);
			response.sendRedirect("admin.jsp");
			return;
		}
		operation = operation.trim();


		// --- Process Operations ---
		try {
			boolean dbSuccess = false;
			boolean fileOpSuccess = false; // Track file operation success separately
			String fileNameForDb = null; // Will hold the filename to save
			String oldFileNameToDelete = null; // For updates/deletes

			if (operation.equals("addCategory")) {
				String categoryName = request.getParameter("category_name");
				Part part = request.getPart("category_img");

				if (categoryName == null || categoryName.trim().isEmpty() ) { throw new ServletException("Category name is required."); }
				// Image is required for add category
				if (part == null || part.getSize() == 0 || part.getSubmittedFileName() == null || part.getSubmittedFileName().trim().isEmpty()) { throw new ServletException("Category image is required."); }

				// 1. Upload file to S3 first
				fileNameForDb = uploadFileToS3(part, null); // Pass null as no existing file
				fileOpSuccess = (fileNameForDb != null); // Check if upload returned a filename

				// 2. If upload succeeded, save to DB
				if (fileOpSuccess) {
					Category category = new Category(categoryName.trim(), fileNameForDb);
					dbSuccess = categoryDao.saveCategory(category);
					if (dbSuccess) {
						message = new Message("Category added successfully!", "success", "alert-success");
					} else {
						message = new Message("Image uploaded to S3, but failed to save category to database!", "error", "alert-danger");
						// Attempt to delete the just-uploaded S3 file for consistency
						deleteFileFromS3(fileNameForDb);
					}
				} else {
					message = new Message("Failed to upload category image.", "error", "alert-danger");
				}

			}else if (operation.equals("updateCategory")) {
				int cid = Integer.parseInt(request.getParameter("cid").trim());
				String name = request.getParameter("category_name");
				Part part = request.getPart("category_img");
				String existingImage = request.getParameter("image"); // Current image filename

				if (name == null || name.trim().isEmpty()) { throw new ServletException("Category name is required for update."); }

				fileNameForDb = existingImage; // Start with existing image
				boolean newFileUploaded = (part != null && part.getSize() > 0 && part.getSubmittedFileName() != null && !part.getSubmittedFileName().trim().isEmpty());

				// 1. If new file uploaded, upload it and potentially mark old one for deletion
				if (newFileUploaded) {
					String uploadedFileName = uploadFileToS3(part, existingImage); // Pass existing in case new fails
					if(uploadedFileName != null && !uploadedFileName.equals(existingImage)) {
						fileNameForDb = uploadedFileName; // Use the newly uploaded filename
						oldFileNameToDelete = existingImage; // Mark the old one for deletion IF DB update succeeds
						fileOpSuccess = true;
					} else {
						// Upload failed, keep existing image name, set fileOp success to false (but DB update might proceed)
						fileOpSuccess = false;
						System.err.println("Update Category: New file upload failed for CID " + cid + ", keeping old image.");
						// Decide if you want to proceed with DB update even if file failed
						message = new Message("Category name updated, but new image upload failed!", "warning", "alert-warning");
					}
				} else {
					fileOpSuccess = true; // No new file to upload, so file operation is considered successful
				}

				// 2. Update database record (always try this unless upload failed and you don't want to proceed)
				Category category = new Category(cid, name.trim(), fileNameForDb); // Use potentially new filename
				dbSuccess = categoryDao.updateCategory(category);

				if (dbSuccess) {
					if (fileOpSuccess) {
						// If DB success AND file op success (new upload ok, or no new upload)
						if (oldFileNameToDelete != null) {
							deleteFileFromS3(oldFileNameToDelete); // Delete old image *after* DB success
						}
						if (message == null) { // Don't overwrite warning message if file upload failed earlier
							message = new Message("Category updated successfully!", "success", "alert-success");
						}
					} // else: fileOpSuccess was false, message already set to warning
				} else {
					message = new Message("Failed to update category in database.", "error", "alert-danger");
					// If new file was uploaded but DB failed, delete the new file from S3
					if (newFileUploaded && fileOpSuccess) {
						deleteFileFromS3(fileNameForDb);
					}
				}


			} else if (operation.equals("deleteCategory")) {
				int cid = Integer.parseInt(request.getParameter("cid").trim());

				// 1. Get category details BEFORE deleting from DB to know image filename
				Category catToDelete = categoryDao.getCategoryById(cid);
				oldFileNameToDelete = (catToDelete != null) ? catToDelete.getCategoryImage() : null;

				// 2. Delete from Database FIRST (handle FK constraints if necessary)
				dbSuccess = categoryDao.deleteCategory(cid);

				if (dbSuccess) {
					// 3. If DB delete succeeded, delete image from S3
					fileOpSuccess = deleteFileFromS3(oldFileNameToDelete);
					if (fileOpSuccess) {
						message = new Message("Category deleted successfully!", "success", "alert-success");
					} else {
						message = new Message("Category deleted from DB, but failed to remove image from S3.", "warning", "alert-warning");
					}
				} else {
					message = new Message("Failed to delete category. It might be in use or not exist.", "error", "alert-danger");
				}


			} else if (operation.equals("updateProduct")) {
				int pid = Integer.parseInt(request.getParameter("pid").trim());
				String name = request.getParameter("name");
				String priceStr = request.getParameter("price");
				String description = request.getParameter("description");
				String quantityStr = request.getParameter("quantity");
				String discountStr = request.getParameter("discount");
				String categoryTypeStr = request.getParameter("categoryType");
				Part part = request.getPart("product_img");
				String existingImage = request.getParameter("image");
				// ... Get and validate other parameters: price, desc, qty, discount, cid ...
				if (name == null || name.trim().isEmpty() || priceStr == null || priceStr.trim().isEmpty() ||
						description == null || description.trim().isEmpty() || discountStr == null || discountStr.trim().isEmpty() ||
						quantityStr == null || quantityStr.trim().isEmpty() || categoryTypeStr == null || categoryTypeStr.trim().isEmpty() ||
						part == null || part.getSize() == 0 || part.getSubmittedFileName() == null || part.getSubmittedFileName().trim().isEmpty())
				{ throw new ServletException("Required fields missing for update."); }
				float price = Float.parseFloat(priceStr.trim());
				int quantity = Integer.parseInt(quantityStr.trim());
				int discount = Integer.parseInt(discountStr.trim());
				int cid = /*... logic to determine category ID from request ...*/ 0;
				if (price < 0 || quantity < 0) throw new ServletException("Price and Quantity cannot be negative.");
				if (discount < 0 || discount > 100) discount = 0;


				fileNameForDb = existingImage; // Start with existing image
				boolean newFileUploaded = (part != null && part.getSize() > 0 && part.getSubmittedFileName() != null && !part.getSubmittedFileName().trim().isEmpty());

				// 1. Handle potential new file upload
				if (newFileUploaded) {
					String uploadedFileName = uploadFileToS3(part, existingImage);
					if(uploadedFileName != null && !uploadedFileName.equals(existingImage)) {
						fileNameForDb = uploadedFileName;
						oldFileNameToDelete = existingImage;
						fileOpSuccess = true;
					} else {
						fileOpSuccess = false;
						System.err.println("Update Product: New file upload failed for PID " + pid + ", keeping old image.");
						message = new Message("Product details updated, but new image upload failed!", "warning", "alert-warning");
					}
				} else {
					fileOpSuccess = true; // No new file upload needed
				}

				// 2. Update database record
				Product existingProduct = productDao.getProductsByProductId(pid);
				Product productToUpdate = new Product(pid, name.trim(), description.trim(), price, discount, quantity, fileNameForDb, cid, existingProduct.getVendorId()); // Keep original vendor ID
				if (existingProduct == null) throw new ServletException("Product to update not found.");
				dbSuccess = productDao.updateProduct(productToUpdate);

				if (dbSuccess) {
					if (fileOpSuccess) {
						if (oldFileNameToDelete != null) {
							deleteFileFromS3(oldFileNameToDelete);
						}
						if (message == null) {
							message = new Message("Product updated successfully!", "success", "alert-success");
						}
					} // else: fileOpSuccess false, warning message already set
				} else {
					message = new Message("Failed to update product in database.", "error", "alert-danger");
					if (newFileUploaded && fileOpSuccess) {
						deleteFileFromS3(fileNameForDb); // Rollback S3 upload if DB failed
					}
				}

			} else if (operation.equals("deleteProduct")) {
				int pid = Integer.parseInt(request.getParameter("pid").trim());

				// 1. Get product details to find image filename
				Product prodToDelete = productDao.getProductsByProductId(pid);
				oldFileNameToDelete = (prodToDelete != null) ? prodToDelete.getProductImages() : null;

				// 2. Delete from Database FIRST
				dbSuccess = productDao.deleteProduct(pid);

				if (dbSuccess) {
					// 3. If DB delete succeeded, delete image from S3
					fileOpSuccess = deleteFileFromS3(oldFileNameToDelete);
					if (fileOpSuccess) {
						message = new Message("Product deleted successfully!", "success", "alert-success");
					} else {
						message = new Message("Product deleted from DB, but failed to remove image from S3.", "warning", "alert-warning");
					}
				} else {
					message = new Message("Failed to delete product. It might be in use or not exist.", "error", "alert-danger");
				}

			} else if (operation.equals("approveVendor")) {
				try {
					int vendorId = Integer.parseInt(request.getParameter("vid"));
					if (vendorDao.approveVendor(vendorId)) {
						message = new Message("Vendor approved successfully.", "success", "alert-success");
						// TODO: Maybe send an approval email to the vendor?
					} else {
						message = new Message("Failed to approve vendor (maybe already approved or error occurred).", "error", "alert-danger");
					}
				} catch (NumberFormatException nfe) {
					message = new Message("Invalid Vendor ID for approval.", "error", "alert-warning");
				}
			} else if (operation.equals("suspendVendor")) {
					try {
						int vendorId = Integer.parseInt(request.getParameter("vid"));
						if (vendorDao.suspendVendor(vendorId)) {
							message = new Message("Vendor suspended successfully.", "success", "alert-success");
							// TODO: Maybe send an approval email to the vendor?
						} else {
							message = new Message("Failed to suspend vendor (maybe already approved or error occurred).", "error", "alert-danger");
						}
					} catch (NumberFormatException nfe) {
						message = new Message("Invalid Vendor ID for suspend.", "error", "alert-warning");
					}
			} else {
				message = new Message("Unknown operation: " + operation, "error", "alert-warning");
				redirectPage = "admin.jsp";
			}

		} catch (NumberFormatException e) {
			message = new Message("Invalid number format provided.", "error", "alert-danger");
			System.err.println("NumberFormatException in AddOperationServlet: " + e.getMessage());
			redirectPage = determineRedirectOnError(operation);
		} catch (S3Exception e) { // Catch specific S3 exceptions from helpers
			message = new Message("Error communicating with storage service: " + e.awsErrorDetails().errorMessage(), "error", "alert-danger");
			System.err.println("S3Exception in AddOperationServlet: " + e.getMessage());
			e.printStackTrace();
			redirectPage = determineRedirectOnError(operation);
		} catch (IOException | ServletException e) {
			message = new Message("Error processing request or file: " + e.getMessage(), "error", "alert-danger");
			System.err.println("IOException/ServletException in AddOperationServlet: " + e.getMessage());
			e.printStackTrace();
			redirectPage = determineRedirectOnError(operation);
		} catch (Exception e) {
			message = new Message("An unexpected error occurred: " + e.getMessage(), "error", "alert-danger");
			System.err.println("Unexpected Error in AddOperationServlet: " + e.getMessage());
			e.printStackTrace();
			redirectPage = determineRedirectOnError(operation);
		}

		// --- Set final message and Redirect ---
		if (message == null) { // Should have been set by logic above
			message = new Message("Operation status unknown.", "warning", "alert-warning");
			System.err.println("Warning: Operation '" + operation + "' completed without setting a message.");
		}
		session.setAttribute("message", message);
	}


	// Helper to determine redirect page on error
	private String determineRedirectOnError(String operation) {
		if (operation == null) return "admin.jsp";
		switch (operation) {
			case "addCategory":
				return "admin.jsp";
			case "updateCategory":
			case "deleteCategory":
				return "admin.jsp";
			case "updateProduct":
			case "deleteProduct":
				return "admin.jsp";
			case "approveVendor":
				return "admin.jsp";
			default:
				return "admin.jsp";
		}
	}


	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		// Redirect GET requests for admin operations
		HttpSession session = req.getSession();
		Message message = new Message("Invalid request method for this operation.", "error", "alert-warning");
		session.setAttribute("message", message);
		resp.sendRedirect("admin.jsp");
	}
}