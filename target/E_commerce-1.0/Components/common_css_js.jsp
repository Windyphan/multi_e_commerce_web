<!--CSS-->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="CSS/style.css"/> <%-- Verify path --%>


<!--JavaScript-->
<%-- jQuery (Load first if script.js depends on it) --%>
<script src="https://code.jquery.com/jquery-3.7.0.min.js" integrity="sha256-2Pmvv0kuTBOenSvLm6bvfBSSHrUJ+3A7x6P5Ebd07/g=" crossorigin="anonymous"></script>

<%-- Bootstrap JS Bundle --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>

<%-- SweetAlert2 (Keep ONLY this one) --%>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<%-- Custom JavaScript (Load last) --%>
<script src="JS/script.js"></script> <%-- Verify path --%>

<%-- Define S3 Base URL --%>
<c:set var="s3BaseUrl" value="https://phong-ecommerce-assets.s3.eu-north-1.amazonaws.com/Product_imgs/" scope="application"/>