package com.phong.servlets;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths; // Use Paths for cleaner filename extraction

import com.phong.dao.CategoryDao;
import com.phong.dao.ProductDao;
import com.phong.entities.Category;
import com.phong.entities.Message;
import com.phong.entities.Product;
import com.phong.entities.Admin; // Import Admin for auth check
// ConnectionProvider import no longer needed
// import com.phong.helper.ConnectionProvider;

// Enable multipart handling
@MultipartConfig(
		// Optional: configure file size limits, temp location etc.
		// fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
		// maxFileSize = 1024 * 1024 * 10, // 10 MB
		// maxRequestSize = 1024 * 1024 * 15 // 15 MB
)
public class AddOperationServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String UPLOAD_DIR = "Product_imgs"; // Define upload directory constant

	// Helper method for saving uploaded file
	private boolean saveUploadedFile(HttpServletRequest request, Part part) throws IOException {
		if (part == null || part.getSize() == 0 || part.getSubmittedFileName() == null || part.getSubmittedFileName().isEmpty()) {
			System.err.println("No file uploaded or invalid part.");
			return false; // No file to save or invalid part
		}

		// Get the real path for uploads - ensure the directory exists!
		String applicationPath = request.getServletContext().getRealPath("");
		String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;

		File uploadDir = new File(uploadFilePath);
		if (!uploadDir.exists()) {
			if (!uploadDir.mkdirs()) { // Try to create directory including parent dirs
				System.err.println("Failed to create upload directory: " + uploadFilePath);
				throw new IOException("Could not create directory for uploads.");
			}
		}

		// Extract filename safely - prevents path traversal issues
		String submittedFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
		if (submittedFileName.isEmpty()) {
			System.err.println("Submitted file name is invalid.");
			return false;
		}
		String filePath = uploadFilePath + File.separator + submittedFileName;

		// Use try-with-resources for streams
		try (InputStream inputStream = part.getInputStream();
			 FileOutputStream outputStream = new FileOutputStream(filePath)) {

			byte[] buffer = new byte[1024];
			int bytesRead;
			while ((bytesRead = inputStream.read(buffer)) != -1) {
				outputStream.write(buffer, 0, bytesRead);
			}
			System.out.println("File saved successfully to: " + filePath);
			return true; // File saved successfully

		} catch (IOException e) {
			System.err.println("Error saving uploaded file '" + submittedFileName + "': " + e.getMessage());
			e.printStackTrace(); // Log the full error
			throw e; // Re-throw exception to be caught by the main try-catch
		}
	}


	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession();
		Message message = null;
		String redirectPage = "admin.jsp"; // Default redirect for adds

		// --- Security Check: Ensure an Admin is logged in ---
		Admin activeAdmin = (Admin) session.getAttribute("activeAdmin");
		if (activeAdmin == null) {
			message = new Message("Unauthorized access. Please log in as admin.", "error", "alert-danger");
			session.setAttribute("message", message);
			response.sendRedirect("adminlogin.jsp");
			return;
		}

		// --- Instantiate DAOs (Refactored) ---
		// Assuming CategoryDao is refactored like the others
		CategoryDao categoryDao = new CategoryDao();
		ProductDao productDao = new ProductDao();

		// --- Get Operation ---
		String operation = request.getParameter("operation");

		if (operation == null || operation.trim().isEmpty()) {
			message = new Message("No operation specified.", "error", "alert-warning");
			session.setAttribute("message", message);
			response.sendRedirect(redirectPage);
			return;
		}
		operation = operation.trim();


		// --- Process Operations ---
		try { // Wrap all operations in a try-catch block

			if (operation.equals("addCategory")) {
				redirectPage = "admin.jsp";
				String categoryName = request.getParameter("category_name");
				Part part = request.getPart("category_img"); // Throws IOException/ServletException if request not multipart

				// Validation
				if (categoryName == null || categoryName.trim().isEmpty()) {
					throw new ServletException("Category name is required.");
				}
				if (part == null || part.getSize() == 0 || part.getSubmittedFileName() == null || part.getSubmittedFileName().trim().isEmpty()) {
					throw new ServletException("Category image is required.");
				}
				String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString(); // Sanitize filename

				Category category = new Category(categoryName.trim(), fileName);
				boolean dbSuccess = categoryDao.saveCategory(category); // Assume returns boolean

				if (dbSuccess) {
					boolean fileSaveSuccess = saveUploadedFile(request, part);
					if (fileSaveSuccess) {
						message = new Message("Category added successfully!", "success", "alert-success");
					} else {
						// DB succeeded, file failed - Inconsistency! Needs manual cleanup or better handling.
						message = new Message("Category added to DB, but image upload failed!", "error", "alert-danger");
						System.err.println("CRITICAL: DB category save succeeded, but file save failed for: " + fileName);
						// Maybe try to delete the DB entry? Complex without transactions.
					}
				} else {
					message = new Message("Failed to save category to database.", "error", "alert-danger");
				}

			} else if (operation.equals("addProduct")) {
				redirectPage = "admin.jsp";
				// Get parameters
				String pName = request.getParameter("name");
				String pDesc = request.getParameter("description");
				String pPriceStr = request.getParameter("price");
				String pDiscountStr = request.getParameter("discount");
				String pQuantityStr = request.getParameter("quantity");
				Part part = request.getPart("photo");
				String categoryTypeStr = request.getParameter("categoryType");

				// Validation
				if (pName == null || pName.trim().isEmpty() || pDesc == null || pDesc.trim().isEmpty() ||
						pPriceStr == null || pPriceStr.trim().isEmpty() || pDiscountStr == null || pDiscountStr.trim().isEmpty() ||
						pQuantityStr == null || pQuantityStr.trim().isEmpty() || categoryTypeStr == null || categoryTypeStr.trim().isEmpty() ||
						part == null || part.getSize() == 0 || part.getSubmittedFileName() == null || part.getSubmittedFileName().trim().isEmpty()) {
					throw new ServletException("All product fields and photo are required.");
				}

				// Parse numeric values with error handling (already inside try-catch for ServletException)
				float pPrice = Float.parseFloat(pPriceStr.trim());
				int pDiscount = Integer.parseInt(pDiscountStr.trim());
				int pQuantity = Integer.parseInt(pQuantityStr.trim());
				int categoryType = Integer.parseInt(categoryTypeStr.trim());
				String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();

				// Validate ranges
				if (pPrice < 0 || pQuantity < 0) {
					throw new ServletException("Price and Quantity cannot be negative.");
				}
				if (pDiscount < 0 || pDiscount > 100) {
					pDiscount = 0; // Default discount to 0 if out of range
					System.out.println("Warning: Invalid discount provided, defaulting to 0.");
				}

				Product product = new Product(pName.trim(), pDesc.trim(), pPrice, pDiscount, pQuantity, fileName, categoryType);
				boolean dbSuccess = productDao.saveProduct(product); // Assume returns boolean

				if (dbSuccess) {
					boolean fileSaveSuccess = saveUploadedFile(request, part);
					if (fileSaveSuccess) {
						message = new Message("Product added successfully!", "success", "alert-success");
					} else {
						message = new Message("Product added to DB, but image upload failed!", "error", "alert-danger");
						System.err.println("CRITICAL: DB product save succeeded, but file save failed for: " + fileName);
					}
				} else {
					message = new Message("Failed to save product to database.", "error", "alert-danger");
				}


			} else if (operation.equals("updateCategory")) {
				redirectPage = "display_category.jsp";
				String cidParam = request.getParameter("cid");
				String name = request.getParameter("category_name");
				Part part = request.getPart("category_img"); // May or may not contain a new file
				String existingImage = request.getParameter("image"); // Hidden field with current image name?

				if (cidParam == null || cidParam.trim().isEmpty() || name == null || name.trim().isEmpty()) {
					throw new ServletException("Category ID and Name are required for update.");
				}
				int cid = Integer.parseInt(cidParam.trim());
				String imageToSave = existingImage; // Assume keeping old image initially
				boolean newFileUploaded = false;

				// Check if a new file was actually uploaded
				if (part != null && part.getSize() > 0 && part.getSubmittedFileName() != null && !part.getSubmittedFileName().trim().isEmpty()) {
					imageToSave = Paths.get(part.getSubmittedFileName()).getFileName().toString();
					newFileUploaded = true;
					if(imageToSave.isEmpty()) { // Double check after sanitizing
						imageToSave = existingImage; // Fallback if sanitized name is empty
						newFileUploaded = false;
						System.err.println("Warning: New category image upload has invalid name, keeping old image.");
					}
				}

				Category category = new Category(cid, name.trim(), imageToSave);
				boolean dbSuccess = categoryDao.updateCategory(category); // Assume returns boolean

				if (dbSuccess) {
					boolean fileOpSuccess = true; // Assume success if no new file needed
					if (newFileUploaded) {
						// TODO: Consider deleting the old image file if update is successful and filename changed
						fileOpSuccess = saveUploadedFile(request, part);
						if (!fileOpSuccess) {
							message = new Message("Category updated in DB, but new image upload failed!", "error", "alert-danger");
							System.err.println("CRITICAL: DB category update succeeded, but NEW file save failed for: " + imageToSave);
						}
					}
					if (fileOpSuccess) {
						message = new Message("Category updated successfully!", "success", "alert-success");
					}
				} else {
					message = new Message("Failed to update category in database.", "error", "alert-danger");
				}

			} else if (operation.equals("deleteCategory")) {
				redirectPage = "display_category.jsp";
				String cidParam = request.getParameter("cid");
				if (cidParam == null || cidParam.trim().isEmpty()) {
					throw new ServletException("Category ID is required for deletion.");
				}
				int cid = Integer.parseInt(cidParam.trim());

				// TODO: Add check: Are there products in this category? Prevent deletion if so?
				// List<Product> productsInCategory = productDao.getAllProductsByCategoryId(cid);
				// if (productsInCategory != null && !productsInCategory.isEmpty()) {
				//    throw new ServletException("Cannot delete category: It contains products.");
				// }

				// TODO: Delete the associated image file?
				// Category catToDelete = categoryDao.getCategoryById(cid); // Assuming this method exists
				// if (catToDelete != null) { deleteFile(request, catToDelete.getCategoryImage()); }

				boolean success = categoryDao.deleteCategory(cid); // Assume returns boolean
				if (success) {
					message = new Message("Category deleted successfully!", "success", "alert-success");
				} else {
					message = new Message("Failed to delete category. It might be in use or an error occurred.", "error", "alert-danger");
				}


			} else if (operation.equals("updateProduct")) {
				redirectPage = "display_products.jsp";
				// Get parameters
				String pidParam = request.getParameter("pid");
				String name = request.getParameter("name");
				String priceStr = request.getParameter("price");
				String description = request.getParameter("description");
				String quantityStr = request.getParameter("quantity");
				String discountStr = request.getParameter("discount");
				Part part = request.getPart("product_img"); // Optional new image
				String categoryTypeStr = request.getParameter("categoryType"); // From dropdown?
				String categoryHiddenStr = request.getParameter("category"); // From hidden field?
				String existingImage = request.getParameter("image"); // Hidden field with current image

				// Basic Validation
				if (pidParam == null || pidParam.trim().isEmpty() || name == null || name.trim().isEmpty() ||
						priceStr == null || priceStr.trim().isEmpty() || description == null || description.trim().isEmpty() ||
						quantityStr == null || quantityStr.trim().isEmpty() || discountStr == null || discountStr.trim().isEmpty() ||
						existingImage == null ) { // Need existing image name even if not changing
					throw new ServletException("All product fields (except new image) are required for update.");
				}

				// Parse & Validate Numerics
				int pid = Integer.parseInt(pidParam.trim());
				float price = Float.parseFloat(priceStr.trim());
				int quantity = Integer.parseInt(quantityStr.trim());
				int discount = Integer.parseInt(discountStr.trim());

				if (price < 0 || quantity < 0) throw new ServletException("Price and Quantity cannot be negative.");
				if (discount < 0 || discount > 100) discount = 0;

				// Determine Category ID
				int cid = 0;
				if (categoryTypeStr != null && !categoryTypeStr.trim().isEmpty() && !categoryTypeStr.trim().equals("0")) {
					cid = Integer.parseInt(categoryTypeStr.trim());
				} else if (categoryHiddenStr != null && !categoryHiddenStr.trim().isEmpty()) {
					cid = Integer.parseInt(categoryHiddenStr.trim()); // Fallback to hidden if dropdown not selected
				} else {
					throw new ServletException("Product category must be specified.");
				}


				// Handle Image Update
				String imageToSave = existingImage;
				boolean newFileUploaded = false;
				if (part != null && part.getSize() > 0 && part.getSubmittedFileName() != null && !part.getSubmittedFileName().trim().isEmpty()) {
					imageToSave = Paths.get(part.getSubmittedFileName()).getFileName().toString();
					newFileUploaded = true;
					if(imageToSave.isEmpty()){
						imageToSave = existingImage;
						newFileUploaded = false;
						System.err.println("Warning: New product image upload has invalid name, keeping old image.");
					}
				}

				Product product = new Product(pid, name.trim(), description.trim(), price, discount, quantity, imageToSave, cid);
				boolean dbSuccess = productDao.updateProduct(product); // Assume returns boolean

				if (dbSuccess) {
					boolean fileOpSuccess = true;
					if (newFileUploaded) {
						// TODO: Delete old image?
						fileOpSuccess = saveUploadedFile(request, part);
						if (!fileOpSuccess) {
							message = new Message("Product updated in DB, but new image upload failed!", "error", "alert-danger");
							System.err.println("CRITICAL: DB product update succeeded, but NEW file save failed for: " + imageToSave);
						}
					}
					if (fileOpSuccess) {
						message = new Message("Product updated successfully!", "success", "alert-success");
					}
				} else {
					message = new Message("Failed to update product in database.", "error", "alert-danger");
				}


			} else if (operation.equals("deleteProduct")) {
				redirectPage = "display_products.jsp";
				String pidParam = request.getParameter("pid");
				if (pidParam == null || pidParam.trim().isEmpty()) {
					throw new ServletException("Product ID is required for deletion.");
				}
				int pid = Integer.parseInt(pidParam.trim());

				// TODO: Delete the associated image file?
				// Product prodToDelete = productDao.getProductsByProductId(pid);
				// if (prodToDelete != null) { deleteFile(request, prodToDelete.getProductImages()); }

				// TODO: Check if product is in carts/orders? Prevent deletion?

				boolean success = productDao.deleteProduct(pid); // Assume returns boolean
				if (success) {
					message = new Message("Product deleted successfully!", "success", "alert-success");
				} else {
					message = new Message("Failed to delete product. It might be in use or an error occurred.", "error", "alert-danger");
				}

			} else {
				// Unknown operation
				message = new Message("Unknown operation: " + operation, "error", "alert-warning");
				redirectPage = "admin.jsp"; // Default redirect for unknown admin ops
			}

		} catch (NumberFormatException e) {
			message = new Message("Invalid number format provided for ID, price, quantity, or discount.", "error", "alert-danger");
			System.err.println("NumberFormatException in AddOperationServlet: " + e.getMessage());
			// Determine redirect based on context if possible, else default
			redirectPage = determineRedirectOnError(operation);
		} catch (IOException | ServletException e) { // Catch file/servlet exceptions explicitly
			message = new Message("Error processing request: " + e.getMessage(), "error", "alert-danger");
			System.err.println("IOException/ServletException in AddOperationServlet: " + e.getMessage());
			e.printStackTrace();
			redirectPage = determineRedirectOnError(operation);
		} catch (Exception e) { // Catch any other unexpected errors
			message = new Message("An unexpected error occurred: " + e.getMessage(), "error", "alert-danger");
			System.err.println("Unexpected Error in AddOperationServlet: " + e.getMessage());
			e.printStackTrace(); // Log full error
			redirectPage = determineRedirectOnError(operation);
		}

		// --- Set message and Redirect ---
		if (message == null) {
			// Should not happen if logic is correct, but set a default success if needed
			message = new Message("Operation completed.", "info", "alert-info");
			System.err.println("Warning: Operation '" + operation + "' completed without setting a message.");
		}
		session.setAttribute("message", message);
		response.sendRedirect(redirectPage);
	}


	// Helper to determine redirect page on error, based on operation context
	private String determineRedirectOnError(String operation) {
		if (operation == null) return "admin.jsp";
		switch (operation) {
			case "addCategory":
			case "addProduct":
				return "admin.jsp";
			case "updateCategory":
			case "deleteCategory":
				return "display_category.jsp";
			case "updateProduct":
			case "deleteProduct":
				return "display_products.jsp";
			default:
				return "admin.jsp";
		}
	}


	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		// Admin operations should generally be POST. Redirect GET requests.
		HttpSession session = req.getSession();
		Message message = new Message("Invalid request method for this operation.", "error", "alert-warning");
		session.setAttribute("message", message);
		resp.sendRedirect("admin.jsp");
	}
}