<%@ page import="java.util.UUID" %>
<%@include file="/libs/foundation/global.jsp" %>
<%@ page session="false" %>

<%
    String suffix = slingRequest.getRequestPathInfo().getSuffix();
    String imagePropertyName = properties.get("name", "");
    String imagePath = "";
    boolean result = false;

    String validation = properties.get("validation","");
    String validationCheck = (validation.equals(""))?"":"data-validation="+validation;

    if (!imagePropertyName.equals("") && (imagePropertyName.length()>=2)) {
        imagePropertyName = imagePropertyName.substring(2);
        Resource res = null;
        res = resourceResolver.getResource(suffix);
        ValueMap props = null;
        if (res != null) {
            props = res.adaptTo(ValueMap.class);
            imagePath = props.get(imagePropertyName,"");
            result = (imagePath.equals("")) ? false : true;
        }
    }
%>
<c:set var="uuid" value="<%= UUID.randomUUID().toString()%>"/>
<div style="padding-left:20px;">
    <h3>${properties.title}</h3>
    <article>
        <table class="coral-Table--bordered" style="width:220px;">
            <thead>
            <tr class="coral-Table-row">
                <th class="coral-Table-headerCell">
                    <h4></h4>
                </th>
            </tr>
            </thead>
            <tbody>
            <tr class="coral-Table-row" id="${uuid}">
                <td class="coral-Table-cell" style="text-align:center;padding:0px;">
                    <div id="divImageUpload" style="height:140px;padding-top:40px;" >
                            <span class="coral-FileUpload" data-init="fileupload">
                                <span class="coral-FileUpload-trigger coral-Button coral-Button--secondary coral-Button--quiet"
                                      style="height:auto;">
                                    <i class="coral-Icon coral-Icon--sizeL coral-Icon--image">
                                        <input id="imgUploadImage" class="coral-FileUpload-input imgUploadImage" name="fileName"
                                               accept="image/*"
                                               type="file" data-upload-url="dummy" data-file-name-parameter="dummy">
                                        <input type="hidden" id="swatchPathValue" value="<%= imagePath %>">
                                        <input type="hidden" id="isPreviewMode" value="<%= result %>">
                                        <input type="hidden" name="${properties.name}" value="<%= imagePath %>" id="propertyName"  <%= validationCheck %>>
                                        <input type="hidden" id="refImagePath" value="${properties.refrencePath}">
                                        <input type="hidden" id="${uuid}_formId" value="${properties.uniqueFormId}">
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
                        <img id="imgUploadPreview" style="width: 220px; height: auto;" src="<%= imagePath %>"/>
                    </div>
                    <div id="divChangeBranding" class="divChangeBranding">
                        <i class="coral-Icon coral-Icon--sizeS coral-Icon--add"></i>
                        <span style="margin-left:4px;display:block-inline;">Change branding</span>
                    </div>
                </td>
            </tr>
            </tbody>
        </table>
    </article>
</div>
<script type="text/javascript">
    $(document).ready(function () {
        var uniqueFormId = $('#${uuid}_formId').val();
        var uniqueId = $('#'+uniqueFormId).val();
        $('#${uuid}').imageUpload('#${uuid}',uniqueId);
    });
</script>
