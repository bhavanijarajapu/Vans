;
(function ($) {
    $.fn.pathField = function (uuid) {
        return this.each(function () {

            var item = $(this);

            var value= item.val();
            if(value=='') {
                $(uuid + "_field").find('.previewSwatch').hide();
            }else{
                var resultObj = $(uuid+"_field").find('.previewSwatch');
                setDivValue($(uuid).val(),resultObj);
                resultObj.show();
            }

            $(uuid).change(function () {
                var resultObj = $(uuid+"_field").find('.previewSwatch');
                setDivValue($(uuid).val(),resultObj);
                resultObj.show();

            });

            function setDivValue(value,resultObj){

                $.ajax({
                    url: "/bin/get/asset.json",
                    data: "path="+value,
                    dataType: "json",
                    success: function(data){handleResponse(data,resultObj);}
                });
            }

            function handleResponse(data,resultObj){

                var isImage = data.isImage;
                var imageObj = resultObj.find('img');

                if(isImage){
                    var imagePath = data.imagePath;
                    imageObj.attr("src",imagePath);
                }else{
                    var hexValue = data.hexValue;
                    imageObj.attr("src","");
                    resultObj.css("background-color",hexValue);
                }
                resultObj.find('.swatchName').text("Swatch Name : "+data.swatchName);
                resultObj.find('.swatchId').text("Swatch Id : "+data.swatchId);
            }
        });
    }
})(jQuery);