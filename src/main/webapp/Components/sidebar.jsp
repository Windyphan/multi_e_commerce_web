<%-- Components/sidebar.jsp --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- This component expects 'navbarCategoryList' --%>
<%-- It will now use JS to trigger filtering, not direct links --%>

<form id="filter-form" novalidate> <%-- Add novalidate to prevent browser default validation popups --%>
    <div class="sidebar">

        <%-- Category Filter --%>
        <h5 class="sidebar-title">Categories</h5>
        <div class="filter-section mb-3" id="category-filter-options">
            <c:if test="${not empty navbarCategoryList}">
                <c:forEach var="cat" items="${navbarCategoryList}">
                    <div class="form-check">
                            <%-- Value is categoryId, name allows multiple selections --%>
                        <input class="form-check-input category-filter-cb" name="category" type="checkbox" value="${cat.categoryId}" id="cat-${cat.categoryId}">
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
                    <input type="number" class="form-control form-control-sm price-filter-input" id="minPrice" name="minPrice" placeholder="Min £" min="0" step="10"> <%-- Added £ sign --%>
                </div>
                <div class="col-auto px-0">-</div>
                <div class="col">
                    <label for="maxPrice" class="form-label visually-hidden">Max Price</label>
                    <input type="number" class="form-control form-control-sm price-filter-input" id="maxPrice" name="maxPrice" placeholder="Max £" min="0" step="10"> <%-- Added £ sign --%>
                </div>
            </div>
        </div>
        <hr> <%-- Keep hr or remove --%>

        <%-- Rating Sort --%>
        <h5 class="sidebar-title">Sort by Rating</h5>
        <div class="filter-section mb-3" id="rating-sort-options">
            <%-- Default/No Sorting Option --%>
            <div class="form-check">
                <input class="form-check-input rating-sort-radio" type="radio" name="ratingSort" id="ratingSortNone" value="" checked>
                <label class="form-check-label" for="ratingSortNone">
                    Relevance / Default
                </label>
            </div>
            <%-- High to Low --%>
            <div class="form-check">
                <input class="form-check-input rating-sort-radio" type="radio" name="ratingSort" id="ratingSortHighLow" value="desc">
                <label class="form-check-label" for="ratingSortHighLow">
                    Highest to Lowest <i class="fas fa-star text-warning"></i>
                </label>
            </div>
            <%-- Low to High --%>
            <div class="form-check">
                <input class="form-check-input rating-sort-radio" type="radio" name="ratingSort" id="ratingSortLowHigh" value="asc">
                <label class="form-check-label" for="ratingSortLowHigh">
                    Lowest to Highest <i class="far fa-star text-warning"></i>
                </label>
            </div>
        </div>
        <%-- No final hr needed after the last section --%>
    </div>
</form>