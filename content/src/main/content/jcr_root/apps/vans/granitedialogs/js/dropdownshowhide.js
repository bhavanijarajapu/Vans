/*
* This js file is used to hide and show different dropdown and tab options of Swatch UI.
*/
(function(document, $) {

    "use strict";

    $(document).on("foundation-contentloaded", function(e) {
        showHide($(".cq-dialog-dropdown-showhide", e.target))  ;
    });

    $(document).on("selected", ".cq-dialog-dropdown-showhide", function(e) {
        showHide($(this));
    });

   function showHide(el){

       var widget = el.data("select");
       if (widget) {
           var swatchTypeValue = widget.getValue();
           var basicObject  = el.closest('.cq-dialog-dropdown-showhide-basic');

           var material  = basicObject.find('.cq-dialog-dropdown-showhide-material');
           var matGroup  = basicObject.find('.cq-dialog-dropdown-showhide-mat-group');
           var hexValue  = basicObject.find('.cq-dialog-dropdown-showhide-hexvalue');
           var assetsTab  = basicObject.find('.cq-dialog-dropdown-showhide-assets');

           var tabPanel = el.closest('.coral-TabPanel');
           var tabPanelInactive = tabPanel.find('.coral-TabPanel-tab');

           //console.log(tabPanel);
           if(swatchTypeValue=="solid"){
               material.parent().slice(0).addClass('hide');
               matGroup.parent().slice(0).addClass('hide');
               hexValue.parent().slice(0).removeClass('hide');
               tabPanelInactive.slice(1).addClass('hide');

           }else if(swatchTypeValue=="material"){
               matGroup.parent().slice(0).removeClass('hide');
               material.parent().slice(0).removeClass('hide');
               hexValue.parent().slice(0).addClass('hide');
               tabPanelInactive.slice(1).removeClass('hide');
           }else{
               material.parent().slice(0).addClass('hide');
               matGroup.parent().slice(0).addClass('hide');
               hexValue.parent().slice(0).addClass('hide');
               tabPanelInactive.slice(1).removeClass('hide');
           }
       }
   }
})(document,Granite.$);