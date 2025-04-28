<%-- Components/sidebar.jsp --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- This component expects 'navbarCategoryList' --%>
<%-- It will now submit the form for a full page reload --%>

<%-- Form submits via GET to products.jsp --%>
<form id="filter-form-reload" action="products.jsp" method="GET">
    <div class="sidebar">

        <%-- Category Filter --%>
        <h5 class="sidebar-title">Categories</h5>
        <div class="filter-section mb-3" id="category-filter-options">
            <c:if test="${not empty navbarCategoryList}">
                <c:forEach var="cat" items="${navbarCategoryList}">
                    <div class="form-check">
                            <%-- Determine if this category checkbox should be checked based on request parameters --%>
                        <c:set var="categoryIsChecked" value="false" />
                        <c:forEach var="selectedCatId" items="${paramValues.category}"> <%-- Iterate through submitted 'category' values --%>
                            <c:if test="${cat.categoryId == selectedCatId}">
                                <c:set var="categoryIsChecked" value="true" />
                            </c:if>
                        </c:forEach>
                            <%-- Add 'checked' attribute if categoryIsChecked is true --%>
                        <input class="form-check-input category-filter-cb filter-input-autosubmit" name="category" type="checkbox" value="${cat.categoryId}" id="cat-${cat.categoryId}" ${categoryIsChecked ? 'checked' : ''}>
                        <label class="form-check-label" for="cat-${cat.categoryId}">
                            <c:out value="${cat.categoryName}"/>
                        </label>
                    </div>
                </c:forEach>
            </c:if>
            <c:if test="${empty navbarCategoryList}">
                <span class="text-muted small">Categories unavailable</span>
            </c:if>
        </div>
        <hr>

        <%-- Price Filter --%>
        <h5 class="sidebar-title">Price Range</h5>
        <div class="filter-section mb-3" id="price-filter-options">
            <div class="row g-2 align-items-center">
                <div class="col">
                    <label for="minPrice" class="form-label visually-hidden">Min Price</label>
                    <%-- Set value from request parameter --%>
                    <input type="number" class="form-control form-control-sm price-filter-input filter-input-autosubmit" id="minPrice" name="minPrice" placeholder="Min" min="0" step="10" value="${param.minPrice}">
                </div>
                <div class="col-auto px-0">-</div>
                <div class="col">
                    <label for="maxPrice" class="form-label visually-hidden">Max Price</label>
                    <%-- Set value from request parameter --%>
                    <input type="number" class="form-control form-control-sm price-filter-input filter-input-autosubmit" id="maxPrice" name="maxPrice" placeholder="Max" min="0" step="10" value="${param.maxPrice}">
                </div>
            </div>
        </div>
        <hr>

        <%-- Rating Sort --%>
        <h5 class="sidebar-title">Sort by Rating</h5>
        <div class="filter-section mb-3" id="rating-sort-options">
            <%-- Check submitted ratingSort value to set 'checked' --%>
            <div class="form-check">
                <input class="form-check-input rating-sort-radio filter-input-autosubmit" type="radio" name="ratingSort" id="ratingSortNone" value="" ${empty param.ratingSort ? 'checked' : ''}>
                <label class="form-check-label" for="ratingSortNone">
                    Relevance / Default
                </label>
            </div>
            <div class="form-check">
                <input class="form-check-input rating-sort-radio filter-input-autosubmit" type="radio" name="ratingSort" id="ratingSortHighLow" value="desc" ${param.ratingSort == 'desc' ? 'checked' : ''}>
                <label class="form-check-label" for="ratingSortHighLow">
                    Highest to Lowest <i class="fas fa-star text-warning"></i>
                </label>
            </div>
            <div class="form-check">
                <input class="form-check-input rating-sort-radio filter-input-autosubmit" type="radio" name="ratingSort" id="ratingSortLowHigh" value="asc" ${param.ratingSort == 'asc' ? 'checked' : ''}>
                <label class="form-check-label" for="ratingSortLowHigh">
                    Lowest to Highest <i class="far fa-star text-warning"></i>
                </label>
            </div>
        </div>
        <%-- Optional Apply Button (useful if JS fails) --%>
        <%-- <button type="submit" class="btn btn-sm btn-outline-primary w-100 mt-2">Apply Filters</button> --%>
    </div>
</form>

<%-- Script to trigger form submission on input change/blur --%>
<script>
    document.addEventListener('DOMContentLoaded', () => {
        const filterFormReload = document.getElementById('filter-form-reload');
        if(filterFormReload) {
            // Select all input types within the form that should trigger submit
            const inputs = filterFormReload.querySelectorAll('input[type="checkbox"], input[type="radio"], input[type="number"]');

            inputs.forEach(input => {
                // Use 'change' for checkboxes and radios
                // Use 'blur' (when focus is lost) for number inputs to avoid submitting on every digit typed
                const eventType = (input.type === 'number') ? 'blur' : 'change';

                input.addEventListener(eventType, () => {
                    console.log(`Filter input changed (${input.name}, type: ${eventType}), submitting form.`);
                    // Optional: Add a small delay if needed, especially for number inputs
                    // setTimeout(() => { filterFormReload.submit(); }, 250);
                    filterFormReload.submit();
                });
            });
        } else {
            console.warn("Sidebar filter form #filter-form-reload not found.");
        }
    });
</script>