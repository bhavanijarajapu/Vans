/*
 * This js file is used to hide and show different dropdown and tab options of Swatch UI.
 */
(function (document, $) {

    "use strict";

    $(document).on("foundation-contentloaded", function (e) {
        showHide($(".cq-dialog-dropdown-showhide", e.target));
    });


    $(document).on("selected", ".cq-dialog-dropdown-showhide", function (e) {
        showHide($(this));
    });

    function showHide(el) {

        var widget = el.data("select");
        if (widget) {
            var swatchTypeValue = widget.getValue();
            var basicObject = el.closest('.cq-dialog-dropdown-showhide-basic');
            var material = basicObject.find('.cq-dialog-dropdown-showhide-material');
            var matGroup = basicObject.find('.cq-dialog-dropdown-showhide-mat-group');
            var hexValue = basicObject.find('.cq-dialog-dropdown-showhide-hexvalue');
            var addedCost = basicObject.find('.cq-dialog-dropdown-showhide-addedcost');
            var assetsTab = basicObject.find('.cq-dialog-dropdown-showhide-assets');

            var tabPanel = el.closest('.coral-TabPanel');
            var tabPanelInactive = tabPanel.find('.coral-TabPanel-tab');

            if (swatchTypeValue == "solid") {
                material.parent().parent().slice(0).addClass('hide');
                matGroup.parent().parent().slice(0).addClass('hide');
                hexValue.parent().parent().slice(0).removeClass('hide');
                tabPanelInactive.slice(1).addClass('hide');
                addedCost.parent().slice(0).addClass('hide');

            } else if (swatchTypeValue == "material") {
                matGroup.parent().parent().slice(0).removeClass('hide');
                material.parent().parent().slice(0).removeClass('hide');
                hexValue.parent().parent().slice(0).addClass('hide');
                tabPanelInactive.slice(1).removeClass('hide');
                addedCost.parent().slice(0).removeClass('hide');
            } else {
                material.parent().parent().slice(0).addClass('hide');
                matGroup.parent().parent().slice(0).addClass('hide');
                hexValue.parent().parent().slice(0).addClass('hide');
                tabPanelInactive.slice(1).removeClass('hide');
                addedCost.parent().slice(0).addClass('hide');
            }
            validateHexValue(swatchTypeValue);
        }
    }

    function validateHexValue(swatchTypeValue){

        var hexObj = $("form [data-validation='vf-innovation.hexValue']");

        if (swatchTypeValue == "solid") {
            var hexValue = hexObj.val();
            if (hexValue == '') {
                var errorIcon = '<span class="coral-Form-fielderror coral-Icon coral-Icon--alert coral-Icon--sizeS" data-quicktip-content="Please fill out this field." aria-label="Please fill out this field."></span>';
                hexObj.addClass("is-invalid");
                hexObj.parent().append(errorIcon);
                return false;
            }
        } else {
            if(hexObj.hasClass('is-invalid')) {
                hexObj.removeClass('is-invalid');
                hexObj.parent().find('span').remove();
            }
            return true;
        }
    }

})(document, Granite.$);