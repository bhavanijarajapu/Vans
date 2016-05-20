;
(function ($) {
    $.fn.imageUpload = function (uuid,formUniqueId) {
    	var uuid = $(uuid);
        return this.each(function () {

            var item = $(this);
           
            uuid.find('.imgUploadImage').change(function () {
                previewImage();
            });

            uuid.find('.divChangeBranding').click(function () {
            	uuid.find('.imgUploadImage').click();
            });

            function previewImage() {

                var _fr = new FileReader();
                var _image = new Image();
                var imgUpload = uuid.find('.imgUploadImage');
                _fr.readAsDataURL(imgUpload.get(0).files[0]);
                _fr.onload = function (e) {

                    var _targRes = e.target.result;
                    uuid.find('#imgUploadPreview').attr("src", _targRes);
                    _image.src = _targRes;
                    _image.onload = function (evt) {

                        var pImgUploadPreviewFdim = uuid.find('#pImgUploadPreviewFdim');
                        var divImageUpload = uuid.find('#divImageUpload');
                        var divImagePreview = uuid.find('#divImagePreview');
                        var divChangeBranding = uuid.find('.divChangeBranding');
                        var divInfoOverlay = uuid.find('#divInfoOverlay');
                        var pImgUploadPreviewFname = uuid.find('#pImgUploadPreviewFname');
                        pImgUploadPreviewFdim.text(this.width + " x " + this.height);
                        divImageUpload.hide();
                        divImagePreview.show();
                        divChangeBranding.show();
                        divInfoOverlay.show();
                        var _filename = imgUpload.val().replace(/^.*\\/, "");
                        pImgUploadPreviewFname.text(_filename);
                        var _div = divImagePreview.height();
                        var _overlayH = divInfoOverlay.height();
                        var _offset = (_div / 2) - (_overlayH / 2);
                        if (_offset > 0) {
                            divInfoOverlay.css("margin-top", _offset + "px");
                        }

                        var imageRefPath = uuid.find('#refImagePath').val();
                        var imageHiddenProperty = uuid.find('#propertyName');
                        var fileReference = imageRefPath+"/"+formUniqueId+"/"+_filename;
                        imageHiddenProperty.val(fileReference);

                        divImageUpload.closest('table').removeClass('invalid-asset');

                    };
                };
            }

            var previewMode = uuid.find('#isPreviewMode');
            var imagePreviewSrc = uuid.find('#isPreviewMode');
            if (previewMode.val()) {
                var imagePath=imagePreviewSrc.attr("src");
                if(imagePath!='') {
                    onImageLoad();
                }
            }

            function onImageLoad() {

                var imagePath = uuid.find('#swatchPathValue').val();
                uuid.find('#imgUploadPreview').attr("src", imagePath);
                var _image = new Image();
                _image.src = imagePath;
                _image.onload = function (evt) {
                    var pImgUploadPreviewFdim = uuid.find('#pImgUploadPreviewFdim');
                    var divImageUpload = uuid.find('#divImageUpload');
                    var divImagePreview = uuid.find('#divImagePreview');
                    var divChangeBranding = uuid.find('.divChangeBranding');
                    var divInfoOverlay = uuid.find('#divInfoOverlay');
                    var pImgUploadPreviewFname = uuid.find('#pImgUploadPreviewFname');
                    pImgUploadPreviewFdim.text(this.width + " x " + this.height);
                    divImageUpload.hide();
                    divImagePreview.show();
                    divChangeBranding.hide();
                    divInfoOverlay.show();

                    var _filename = "File Name";
                    var index = imagePath.lastIndexOf("/");
                    if (index >= -1) {
                        _filename = imagePath.substring(index + 1, imagePath.length);
                    }

                    pImgUploadPreviewFname.text(_filename);
                    var _div = divImagePreview.height();
                    var _overlayH = divInfoOverlay.height();
                    var _offset = (_div / 2) - (_overlayH / 2);
                    if (_offset > 0) {
                        divInfoOverlay.css("margin-top", _offset + "px");
                    }
                    divImageUpload.closest('table').removeClass('invalid-asset');
                };
            }
        });
    }
})(jQuery);