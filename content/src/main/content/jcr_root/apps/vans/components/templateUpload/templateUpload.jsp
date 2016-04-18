<%@include file="/libs/foundation/global.jsp" %>
<%@ page session="false" %>
<script>
    function previewImage() {
        var _fr = new FileReader();
        var _image = new Image();

        _fr.readAsDataURL($("#imgUploadImage").get(0).files[0]);

        _fr.onload = function (e) {
            var _targRes = e.target.result;
            $("#imgUploadPreview").attr("src", _targRes);
            _image.src = _targRes;
            _image.onload = function (evt) {
                $("#pImgUploadPreviewFdim").text(this.width + " x " + this.height);

                $('#divImageUpload').hide();
                $('#divImagePreview').show();
                $('#divChangeBranding').show();
                $('#divInfoOverlay').show();

                var _filename = $('#imgUploadImage').val().replace(/^.*\\/, "");
                $('#pImgUploadPreviewFname').text(_filename);

                var _div = $("#divImagePreview").height();
                var _overlayH = $('#divInfoOverlay').height();
                var _offset = (_div / 2) - (_overlayH / 2);

                if (_offset > 0) {
                    $('#divInfoOverlay').css("margin-top", _offset + "px");
                }
            };
        };
    }
    function openFileDialog() {
        $('#imgUploadImage').click();
    }

    var onImageLoad = function () {

        var imagePath = $('#swatchPathValue').val();
        $("#imgUploadPreview").attr("src", imagePath);
        var _image = new Image();
        _image.src = imagePath;
        _image.onload = function (evt) {
            $("#pImgUploadPreviewFdim").text(this.width + " x " + this.height);

            $('#divImageUpload').hide();
            $('#divImagePreview').show();
            $('#divChangeBranding').show();
            $('#divInfoOverlay').show();

            var _filename = "File Name";
            var index= imagePath.lastIndexOf("/");
            if(index>=-1){
                _filename = imagePath.substring(index+1,imagePath.length);
            }
            $('#pImgUploadPreviewFname').text(_filename);

            var _div = $("#divImagePreview").height();
            var _overlayH = $('#divInfoOverlay').height();
            var _offset = (_div / 2) - (_overlayH / 2);

            if (_offset > 0) {
                $('#divInfoOverlay').css("margin-top", _offset + "px");
            }
        };
    };
</script>

<style>
    #divInfoOverlay {
        display: none;
        z-index: 9001;
        opacity: 0.8;
        position: absolute;
        margin-top: 30px;
        background-color: #ffffff;
        height: 70px;
        width: 234px;
        margin-left: -8px;
        border: 1px solid #e2e2e2;
    }

    #divImagePreview {
        display: none;
        z-index: 9000;
    }

    #divChangeBranding {
        display: none;
        margin-bottom: 10px;
        margin-top: 8px;
    }

    #pImgUploadPreviewFname {
        font-weight: bold;
    }

    .truncFname {
        width: 220px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    #divChangeBranding:hover {
        cursor: pointer;
    }
</style>

<%
    String suffix = slingRequest.getRequestPathInfo().getSuffix();
    Resource res = resourceResolver.getResource(suffix + "/image");
    String imagePath="";
    boolean result = false;
    if(res!=null){
        imagePath= res.adaptTo(ValueMap.class).get("fileReference","");
    if(suffix.endsWith("/swatches/")|| suffix.endsWith("/swatches")){
        result = false;
    }else{
        result = true;
    }
%>
<input type="hidden" id="swatchPathValue" value="<%= imagePath %>">
<input type="hidden" id="isPreviewMode" value="<%= result %>">
<%}%>
<div style="padding-left:20px;">
    <h3>Upload Asset</h3>
    <article>
        <table class="coral-Table--bordered" style="width:220px;">
            <thead>
            <tr class="coral-Table-row">
                <th class="coral-Table-headerCell">
                    <h4>Site Header Image</h4>
                </th>
            </tr>
            </thead>
            <tbody>
            <tr class="coral-Table-row">
                <td class="coral-Table-cell" style="text-align:center;padding:0px;">
                    <div id="divImageUpload" style="height:140px;padding-top:40px;">
                            <span class="coral-FileUpload" data-init="fileupload">
                                <span class="coral-FileUpload-trigger coral-Button coral-Button--secondary coral-Button--quiet"
                                      style="height:auto;">
                                    <i class="coral-Icon coral-Icon--sizeL coral-Icon--image">
                                        <input id="imgUploadImage" class="coral-FileUpload-input" name="file"
                                               data-upload-url="/content/geometrixx" data-file-name-parameter="fileName"
                                               type="file" onchange="previewImage();">
                                    </i>
                                </span>
                            </span>

                        <p class="type">Add an image</p>
                    </div>
                    <div id="divInfoOverlay">
                        <p id="pImgUploadPreviewFname" class="truncFname"></p>

                        <p id="pImgUploadPreviewFdim"></p>
                    </div>
                    <div id="divImagePreview">
                        <img id="imgUploadPreview" style="width: 220px; height: auto;" src="/etc/commerce/products/vans/images/3.png"/>
                    </div>
                    <div id="divChangeBranding" onclick="openFileDialog();">
                        <i class="coral-Icon coral-Icon--sizeS coral-Icon--add"></i>
                        <span style="margin-left:4px;display:block-inline;">Change branding</span>
                    </div>
                </td>
            </tr>
            </tbody>
        </table>
    </article>
</div>
<%--<input type="button" value="Upload" id="upload-button-id"/>--%>

<script type="text/javascript">

    jQuery(function ($) {

        var uploadBtn = document.getElementById('cq-social-edit-sitetemplate-submit');
        uploadBtn.onclick = function (evt) {
            var formData = new FormData();
            var fileInput = document.getElementById('imgUploadImage');
            var file = fileInput.files[0];
            formData.append('our-file', file);
            sendXHRequest(formData);
        };
        function sendXHRequest(formData) {

            $.ajax({
                type: 'POST',
                url: '/bin/updamfile',
                processData: false,
                contentType: false,
                data: formData,
                success: function (msg) {
                    alert(msg); //display the data returned by the servlet
                }
            });
        }
        var swatchId = $('#isPreviewMode');
        if(swatchId) {
            onImageLoad();
        }
    });

</script>