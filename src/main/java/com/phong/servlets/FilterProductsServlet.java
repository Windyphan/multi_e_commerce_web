package com.phong.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.util.stream.Collectors;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.fasterxml.jackson.databind.ObjectMapper; // Jackson for JSON
import com.phong.dao.ProductDao;
import com.phong.dao.ReviewDao;
import com.phong.dao.VendorDao;
import com.phong.entities.Product;
import com.phong.entities.Vendor;

public class FilterProductsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final ObjectMapper objectMapper = new ObjectMapper(); // For JSON conversion

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // --- Set CORS headers (important for AJAX from different origins/ports) ---
        // Consider making the origin more specific in production
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS"); // Allow GET and preflight OPTIONS
        response.setHeader("Access-Control-Allow-Headers", "Content-Type"); // Add others if needed
        response.setContentType("application/json"); // Set response type to JSON
        response.setCharacterEncoding("UTF-8");

        // --- Get Filter Parameters ---
        // Categories (can be multiple)
        String[] categoryParams = request.getParameterValues("category"); // Use getParameterValues
        List<Integer> categoryIds = new ArrayList<>();
        if (categoryParams != null) {
            for (String catIdStr : categoryParams) {
                try {
                    int catId = Integer.parseInt(catIdStr);
                    if (catId > 0) { // Ignore "0" or invalid IDs
                        categoryIds.add(catId);
                    }
                } catch (NumberFormatException e) {
                    System.err.println("FilterServlet: Invalid category parameter skipped: " + catIdStr);
                }
            }
        }

        // Price Range
        Float minPrice = null;
        Float maxPrice = null;
        try {
            String minPriceStr = request.getParameter("minPrice");
            if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
                minPrice = Float.parseFloat(minPriceStr.trim());
                if (minPrice < 0) minPrice = 0f; // Ensure non-negative
            }
            String maxPriceStr = request.getParameter("maxPrice");
            if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
                maxPrice = Float.parseFloat(maxPriceStr.trim());
                if (maxPrice < 0) maxPrice = null; // Ignore negative max price
                if (minPrice != null && maxPrice != null && maxPrice < minPrice) maxPrice = null; // Ignore if max < min
            }
        } catch (NumberFormatException e) {
            System.err.println("FilterServlet: Invalid price format skipped.");
            // Ignore invalid prices, don't filter by them
        }

        // Rating Sort
        String ratingSort = request.getParameter("ratingSort"); // Expects "asc", "desc", or null/empty
        if (ratingSort != null && !ratingSort.equals("asc") && !ratingSort.equals("desc")) {
            ratingSort = null; // Default to no specific rating sort if value is invalid
        }

        // Search Term (optional, can be combined)
        String searchKey = request.getParameter("search");
        if (searchKey != null) {
            searchKey = searchKey.trim();
            if (searchKey.isEmpty()) searchKey = null;
        }

        System.out.println("FilterServlet: Received Filters - Cats: " + categoryIds +
                ", MinPrice: " + minPrice + ", MaxPrice: " + maxPrice +
                ", RatingSort: " + ratingSort + ", Search: " + searchKey);


        // --- Call DAO to Fetch Filtered Products ---
        ProductDao productDao = new ProductDao();
        List<Product> filteredProducts = null;
        Map<String, Object> responseMap = new HashMap<>(); // Map to hold final JSON response

        try {
            // ** You NEED to create this method in ProductDao **
            filteredProducts = productDao.getFilteredProducts(
                    categoryIds, // List<Integer>
                    minPrice,    // Float
                    maxPrice,    // Float
                    ratingSort,  // String ("asc", "desc", or null)
                    searchKey    // String
            );

            if (filteredProducts == null) { // Check for DAO error indication
                throw new Exception("Product DAO returned null, indicating an error.");
            }

            // --- Fetch Supporting Data (Vendor Names, Ratings) for the Filtered Products ---
            Map<Integer, String> vendorNameMap = new HashMap<>();
            Map<Integer, Float> averageRatingsMap = new HashMap<>();

            if (!filteredProducts.isEmpty()) {
                Set<Integer> vendorIdsNeeded = filteredProducts.stream()
                        .map(Product::getVendorId)
                        .filter(vid -> vid > 0)
                        .collect(Collectors.toSet());
                // Fetch vendors
                if(!vendorIdsNeeded.isEmpty()) {
                    VendorDao vendorDao = new VendorDao();
                    for(int vid : vendorIdsNeeded) {
                        if(!vendorNameMap.containsKey(vid)) {
                            Vendor v = vendorDao.getVendorById(vid);
                            if (v != null && v.isApproved()) vendorNameMap.put(vid, v.getShopName());
                            else vendorNameMap.put(vid, "Phong Shop"); // Fallback
                        }
                    }
                }
                // Fetch ratings
                ReviewDao reviewDao = new ReviewDao();
                for(Product p : filteredProducts) {
                    averageRatingsMap.put(p.getProductId(), reviewDao.getAverageRatingByProductId(p.getProductId()));
                }
            }

            // --- Prepare JSON Response ---
            responseMap.put("products", filteredProducts);
            responseMap.put("vendorNames", vendorNameMap);
            responseMap.put("averageRatings", averageRatingsMap);
            // Optionally add wishlist status if needed (more complex, requires user ID)

            response.setStatus(HttpServletResponse.SC_OK); // 200 OK

        } catch (Exception e) {
            System.err.println("Error processing product filter request: " + e.getMessage());
            e.printStackTrace(); // Log full trace
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR); // 500 Internal Server Error
            responseMap.put("error", "Could not retrieve filtered products.");
            responseMap.put("products", Collections.emptyList()); // Send empty list on error
            responseMap.put("vendorNames", Collections.emptyMap());
            responseMap.put("averageRatings", Collections.emptyMap());
        }

        // --- Write JSON Response ---
        try (PrintWriter out = response.getWriter()) {
            objectMapper.writeValue(out, responseMap); // Convert Map to JSON and write
        }
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Handle CORS preflight requests
        resp.setHeader("Access-Control-Allow-Origin", "*");
        resp.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        resp.setHeader("Access-Control-Allow-Headers", "Content-Type");
        resp.setStatus(HttpServletResponse.SC_OK);
    }
}