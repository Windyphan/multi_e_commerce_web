package com.phong.servlets;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import com.phong.dao.ProductDao;
import com.phong.entities.Message;
import com.phong.entities.Product;
import com.phong.entities.Vendor;

// AWS S3 Imports
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception;
import software.amazon.awssdk.core.sync.RequestBody;

@MultipartConfig // Enable file uploads
public class VendorProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // --- S3 Configuration ---
    private static final String S3_BUCKET_NAME = "phong-ecommerce-assets"; // *** REPLACE ***
    private static final String S3_REGION_ID = "eu-north-1";
    private static final String S3_FOLDER_PATH = "Product_imgs/";

    // --- S3 Client Helper ---
    private S3Client getS3Client() {
        Region region = Region.of(S3_REGION_ID);
        return S3Client.builder().region(region).build();
    }

    // --- S3 Upload Helper ---
    private String uploadFileToS3(Part part, String existingFileName) throws IOException, S3Exception {
        if (part == null || part.getSize() == 0 || part.getSubmittedFileName() == null || part.getSubmittedFileName().isEmpty()) {
            return existingFileName; // Return existing name if no new file
        }
        String originalFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        if (originalFileName.isEmpty()) return existingFileName;

        String fileExtension = "";
        int lastDot = originalFileName.lastIndexOf('.');
        if (lastDot > 0) fileExtension = originalFileName.substring(lastDot);
        String uniqueFileName = UUID.randomUUID().toString() + fileExtension;
        String objectKey = S3_FOLDER_PATH + uniqueFileName;

        System.out.println("[VendorProductServlet] Attempting S3 upload: " + objectKey);
        S3Client s3 = getS3Client();
        try (InputStream fis = part.getInputStream()) {
            PutObjectRequest putReq = PutObjectRequest.builder()
                    .bucket(S3_BUCKET_NAME).key(objectKey).contentType(part.getContentType()).build();
            s3.putObject(putReq, RequestBody.fromInputStream(fis, part.getSize()));
            System.out.println("[VendorProductServlet] S3 Upload success: " + objectKey);
            return uniqueFileName;
        } catch (S3Exception e) {
            System.err.println("[VendorProductServlet] S3 Upload Error: " + e.awsErrorDetails().errorMessage());
            throw e;
        } finally {
            s3.close();
        }
    }

    // --- S3 Delete Helper ---
    private boolean deleteFileFromS3(String fileName) {
        if (fileName == null || fileName.trim().isEmpty()) return true;
        String objectKey = S3_FOLDER_PATH + fileName.trim();
        System.out.println("[VendorProductServlet] Attempting S3 delete: " + objectKey);
        S3Client s3 = getS3Client();
        try {
            DeleteObjectRequest delReq = DeleteObjectRequest.builder().bucket(S3_BUCKET_NAME).key(objectKey).build();
            s3.deleteObject(delReq);
            System.out.println("[VendorProductServlet] S3 Delete success: " + objectKey);
            return true;
        } catch (S3Exception e) {
            System.err.println("[VendorProductServlet] S3 Delete Error: " + e.awsErrorDetails().errorMessage());
            return false;
        } finally {
            s3.close();
        }
    }
    // --- End S3 Helpers ---


    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Message message = null;
        String redirectPage = "vendor_dashboard.jsp"; // Default redirect for vendor

        // --- Security Check: Ensure VENDOR is logged in and approved ---
        Vendor activeVendor = (Vendor) session.getAttribute("activeVendor");
        if (activeVendor == null || !activeVendor.isApproved()) {
            message = new Message("Access Denied. Please log in as an approved vendor.", "error", "alert-danger");
            session.setAttribute("message", message);
            response.sendRedirect("vendor_login.jsp");
            return;
        }
        int vendorId = activeVendor.getVendorId(); // Get the logged-in vendor's ID

        // DAO
        ProductDao productDao = new ProductDao();

        // Operation
        String operation = request.getParameter("operation");
        if (operation == null || operation.trim().isEmpty()) {
            message = new Message("No operation specified.", "error", "alert-warning");
            redirectPage = "vendor_products.jsp"; // Go back to product list
        } else {
            operation = operation.trim();

            try { // Wrap operations
                boolean dbSuccess = false;
                boolean fileOpSuccess = false;
                String fileNameForDb = null;
                String oldFileNameToDelete = null;

                if (operation.equals("addProduct")) {
                    redirectPage = "vendor_products.jsp";
                    // Get parameters (ensure names match the form in vendor_add_product_modal.jsp)
                    String pName = request.getParameter("name");
                    String pDesc = request.getParameter("description");
                    String pPriceStr = request.getParameter("price");
                    String pDiscountStr = request.getParameter("discount");
                    String pQuantityStr = request.getParameter("quantity");
                    Part part = request.getPart("photo"); // Name matches modal form
                    String categoryTypeStr = request.getParameter("categoryType");

                    // Validation
                    if (pName == null || pName.trim().isEmpty() || pDesc == null || pDesc.trim().isEmpty() ||
                            pPriceStr == null || pPriceStr.trim().isEmpty() || pDiscountStr == null || pDiscountStr.trim().isEmpty() ||
                            pQuantityStr == null || pQuantityStr.trim().isEmpty() || categoryTypeStr == null || categoryTypeStr.trim().isEmpty() ||
                            part == null || part.getSize() == 0 || part.getSubmittedFileName() == null || part.getSubmittedFileName().trim().isEmpty()) {
                        throw new ServletException("All product fields and photo are required.");
                    }

                    float pPrice = Float.parseFloat(pPriceStr.trim());
                    int pDiscount = Integer.parseInt(pDiscountStr.trim());
                    int pQuantity = Integer.parseInt(pQuantityStr.trim());
                    int categoryType = Integer.parseInt(categoryTypeStr.trim());
                    if (pPrice < 0 || pQuantity < 0) throw new ServletException("Price and Quantity must be non-negative.");
                    if (pDiscount < 0 || pDiscount > 100) pDiscount = 0;

                    // 1. Upload to S3
                    fileNameForDb = uploadFileToS3(part, null);
                    fileOpSuccess = (fileNameForDb != null);

                    // 2. Save to DB if upload OK
                    if (fileOpSuccess) {
                        // *** Use the LOGGED IN VENDOR'S ID ***
                        Product product = new Product(pName.trim(), pDesc.trim(), pPrice, pDiscount, pQuantity, fileNameForDb, categoryType, vendorId);
                        dbSuccess = productDao.saveProduct(product);
                        if (dbSuccess) {
                            message = new Message("Your product was added successfully!", "success", "alert-success");
                        } else {
                            message = new Message("Image uploaded, but failed to save product to database!", "error", "alert-danger");
                            deleteFileFromS3(fileNameForDb); // Rollback S3
                        }
                    } else {
                        message = new Message("Failed to upload product image.", "error", "alert-danger");
                    }

                } else if (operation.equals("updateProduct")) {
                    redirectPage = "vendor_products.jsp";
                    // Get parameters including pid and existing image name
                    int pid = Integer.parseInt(request.getParameter("pid").trim());
                    String name = request.getParameter("name");
                    String priceStr = request.getParameter("price");
                    String description = request.getParameter("description");
                    String quantityStr = request.getParameter("quantity");
                    String discountStr = request.getParameter("discount");
                    Part part = request.getPart("product_img"); // Name matches update form
                    String categoryTypeStr = request.getParameter("categoryType");
                    String existingImage = request.getParameter("image");

                    // ... (Add validation for required fields similar to addProduct) ...
                    if (name == null || name.trim().isEmpty() || priceStr == null || priceStr.trim().isEmpty() ||
                            description == null || description.trim().isEmpty() || discountStr == null || discountStr.trim().isEmpty() ||
                            quantityStr == null || quantityStr.trim().isEmpty() || categoryTypeStr == null || categoryTypeStr.trim().isEmpty())
                    { throw new ServletException("Required fields missing for update."); }

                    float price = Float.parseFloat(priceStr.trim());
                    int quantity = Integer.parseInt(quantityStr.trim());
                    int discount = Integer.parseInt(discountStr.trim());
                    int cid = Integer.parseInt(categoryTypeStr.trim());
                    if (price < 0 || quantity < 0) throw new ServletException("Price/Quantity cannot be negative.");
                    if (discount < 0 || discount > 100) discount = 0;


                    // *** OWNERSHIP VERIFICATION ***
                    Product productBeingEdited = productDao.getProductsByProductId(pid);
                    if (productBeingEdited == null || productBeingEdited.getVendorId() != vendorId) {
                        message = new Message("Unauthorized: You cannot edit this product.", "error", "alert-danger");
                        // Redirect immediately, do not proceed
                        session.setAttribute("message", message);
                        response.sendRedirect(redirectPage);
                        return;
                    }
                    // Update existingImage if fetched product had one (more reliable than hidden field)
                    existingImage = productBeingEdited.getProductImages();


                    // 1. Handle optional new file upload
                    fileNameForDb = existingImage;
                    boolean newFileUploaded = (part != null && part.getSize() > 0 /* ... check filename ...*/);
                    if (newFileUploaded) {
                        String uploadedFileName = uploadFileToS3(part, existingImage);
                        if (uploadedFileName != null && !uploadedFileName.equals(existingImage)) {
                            fileNameForDb = uploadedFileName;
                            oldFileNameToDelete = existingImage;
                            fileOpSuccess = true;
                        } else { fileOpSuccess = false; /* Failed upload, keep existing */ }
                    } else { fileOpSuccess = true; /* No new file needed */ }

                    // 2. Update DB record
                    Product productToUpdate = new Product(pid, name.trim(), description.trim(), price, discount, quantity, fileNameForDb, cid, vendorId); // Ensure vendorId is set!
                    dbSuccess = productDao.updateProduct(productToUpdate);

                    // 3. Handle results & S3 cleanup
                    if (dbSuccess) {
                        if (fileOpSuccess) {
                            if (oldFileNameToDelete != null) deleteFileFromS3(oldFileNameToDelete);
                            message = new Message("Product updated successfully!", "success", "alert-success");
                        } else { // DB updated, but file upload failed
                            message = new Message("Product details updated, but new image upload failed.", "warning", "alert-warning");
                        }
                    } else {
                        message = new Message("Failed to update product in database.", "error", "alert-danger");
                        if (newFileUploaded && fileOpSuccess) deleteFileFromS3(fileNameForDb); // Rollback S3
                    }


                } else if (operation.equals("deleteProduct")) {
                    redirectPage = "vendor_products.jsp";
                    int pid = Integer.parseInt(request.getParameter("pid").trim());

                    // *** OWNERSHIP VERIFICATION ***
                    Product prodToDelete = productDao.getProductsByProductId(pid);
                    if (prodToDelete == null || prodToDelete.getVendorId() != vendorId) {
                        message = new Message("Unauthorized: You cannot delete this product.", "error", "alert-danger");
                        dbSuccess = false; // Prevent deletion attempts
                    } else {
                        oldFileNameToDelete = prodToDelete.getProductImages();
                        // 1. Delete from DB FIRST
                        dbSuccess = productDao.deleteProduct(pid);
                    }

                    // 2. If DB delete succeeded, delete image from S3
                    if (dbSuccess) {
                        fileOpSuccess = deleteFileFromS3(oldFileNameToDelete);
                        if (fileOpSuccess) {
                            message = new Message("Product deleted successfully!", "success", "alert-success");
                        } else {
                            message = new Message("Product deleted from DB, but failed to remove image.", "warning", "alert-warning");
                        }
                    } else if (message == null) { // Only set failure message if not already set by auth check
                        message = new Message("Failed to delete product.", "error", "alert-danger");
                    }

                } else {
                    message = new Message("Unknown product operation: " + operation, "error", "alert-warning");
                    redirectPage = "vendor_dashboard.jsp";
                }

            } catch (NumberFormatException e) {
                message = new Message("Invalid number format provided.", "error", "alert-danger");
                System.err.println("NumberFormatException in VendorProductServlet: " + e.getMessage());
            } catch (IOException | ServletException e) {
                message = new Message("Error processing request/file: " + e.getMessage(), "error", "alert-danger");
                System.err.println("IOException/ServletException in VendorProductServlet: " + e.getMessage());
                e.printStackTrace();
            } catch (S3Exception e) {
                message = new Message("Storage error: " + e.awsErrorDetails().errorMessage(), "error", "alert-danger");
                System.err.println("S3Exception in VendorProductServlet: " + e.getMessage());
                e.printStackTrace();
            } catch (Exception e) {
                message = new Message("An unexpected error occurred: " + e.getMessage(), "error", "alert-danger");
                System.err.println("Unexpected Error in VendorProductServlet: " + e.getMessage());
                e.printStackTrace();
            }
        } // End of else block for valid operation

        // Final Redirect
        if (message != null) session.setAttribute("message", message);
        response.sendRedirect(redirectPage);
    }

    // doGet should redirect or show error for POST-only actions
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Message message = new Message("Invalid request method for product management.", "error", "alert-warning");
        session.setAttribute("message", message);
        response.sendRedirect("vendor_dashboard.jsp"); // Redirect vendor to dashboard
    }
}