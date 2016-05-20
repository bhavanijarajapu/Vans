$(document).ready(function () {

    $(".cq-social-edit-submit").on("click", function () {

        if (validateFields()) {
            submitAssets();
        } else {
            return false;
        }
    });

    var validateFields = function () {

        var storeId = $("form [data-validation='vf-innovation.storeId']");
        var catalogId = $("form [data-validation='vf-innovation.catalogId']");
        var isValidStoreId = validateTagField(storeId);
        var isValidCatalogId = validateTagField(catalogId);
        var swatchTypeValue = $("form [data-validation='vf-innovation.swatchType']").find('select').val();
        var isValidHexValue = validateHexValue(swatchTypeValue);
        var isValidAssets = validateImageAssets(swatchTypeValue);
        return ((isValidStoreId && isValidCatalogId) && ( isValidAssets && isValidHexValue));
    };

    var validateHexValue = function (swatchTypeValue) {

        var hexObj = $("form [data-validation='vf-innovation.hexValue']");
        var result = true;
        if (swatchTypeValue == "solid") {
            var hexValue = hexObj.val();
            if (hexValue == '') {
                var errorIcon = '<span class="coral-Form-fielderror coral-Icon coral-Icon--alert coral-Icon--sizeS" data-quicktip-content="Please fill out this field." aria-label="Please fill out this field."></span>';
                hexObj.addClass("is-invalid");
                hexObj.parent().append(errorIcon);
                result = false;
            }
        }
        return result;
    };


    var validateTagField = function (tagObj) {

        var errorIcon = '<span class="coral-Form-fielderror coral-Icon coral-Icon--alert coral-Icon--sizeS" data-init="quicktip" data-quicktip-type="error" data-quicktip-arrow="right" data-quicktip-content="Please fill out this field." aria-label="Please fill out this field."></span>';
        tagObj = tagObj.closest('div');
        var li = tagObj.find('li');
        if (li == '' || li.length == 0) {
            tagObj.find('.js-coral-pathbrowser-input').addClass("is-invalid");
            tagObj.append(errorIcon);
            return false;
        } else {
            return true;
        }
    };

    var validateImageAssets = function (swatchTypeValue) {

        if (swatchTypeValue != 'solid') {
            var pageThumbnail = $("form [data-validation='vf-innovation.pageThumbnail']");
            var diffuseAsset = $("form [data-validation='vf-innovation.diffuseAsset']");
            var isValidThumbnailImagePath = validateAsset(pageThumbnail);
            if(!isValidThumbnailImagePath){
                pageThumbnail.closest('table').addClass('invalid-asset');
            }
            var isValidDiffuseAssetImagePath = validateAsset(diffuseAsset);
            if(!isValidDiffuseAssetImagePath){
                diffuseAsset.closest('table').addClass('invalid-asset');
            }
            return (isValidThumbnailImagePath && isValidDiffuseAssetImagePath);
        } else {
            return true;
        }
    };

    var validateAsset = function (assetObject) {

        var assetValue = assetObject.val();
        return (assetValue != '');
    };


    var submitAssets = function (evt) {
        var formData = new FormData();
        var fileInput = $('.coral-FileUpload-input');
        fileInput.each(function (index) {
            var file = fileInput[index].files[0];
            if (file) {
                formData.append(index, file);
            }
        });
        addAssets(formData);
        sendXHRequest(formData);
    };


    function sendXHRequest(formData) {

        $.ajax({
            type: 'POST',
            url: '/bin/upload/asset',
            processData: false,
            contentType: false,
            data: formData,
            success: function (msg) {
                console.log("Assets Uploaded Successfully." + msg);
            }
        });
    }

    function addAssets(formData) {

        var formId = $(".cq-dialog-vans-uniqueId").val();
        formData.append("id", formId);
        var imageFiles = $('.coral-FileUpload-input');
        var imageData = {};
        var i = 0;
        imageFiles.each(function () {
            var filename = $(this).val().replace(/^.*\\/, "");
            var refImagePath = $(this).siblings('#refImagePath').val();
            if (filename !== undefined && filename != '') {
                formData.append("asset_" + i, filename + ":" + refImagePath);
                i = i + 1;
            }
        });
    }

    $('.swatch-edit').on("click", function () {
        $('.divChangeBranding').show();
    });

    $('.swatch-cancel').on("click", function () {
        $('.divChangeBranding').hide();
    });
});