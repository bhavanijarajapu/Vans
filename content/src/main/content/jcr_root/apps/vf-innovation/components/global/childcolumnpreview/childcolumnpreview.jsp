<%@include file="/libs/foundation/global.jsp"%>
<%@include file="previewObjects.jsp"%>
<div ${attrbuteBuild}>
    <c:if test="${not empty product}">
        <div class="coral-ColumnView-column-content">
            <div class="coral-ColumnView-preview">

                <div class="coral-ColumnView-preview-icon">
                    <c:choose>
                        <c:when test="${isImageExist}">
                            <img class="coral-ColumnView-preview-thumbnail" src="${thumbnailUrl}" alt="">
                        </c:when>
                        <c:otherwise>
                            <div class="coral-ColumnView-preview-thumbnail" style="background-color: ${itemProperties.hexValue};"></div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="coral-ColumnView-preview-label">Title</div>
                <div class="coral-ColumnView-preview-value">${title}</div>

                <div class="coral-ColumnView-preview-label">${idHeading}</div>
                <div class="coral-ColumnView-preview-value">${itemProperties['jcr:title']}</div>

                <c:if test="${not empty itemProperties['jcr:lastModified']}">
                    <div class="coral-ColumnView-preview-label">Modified</div>
                    <div class="coral-ColumnView-preview-value">${modifiedDate}</div>
                </c:if>

                <c:if test="${not empty itemProperties['cq:lastReplicated']}">
                    <div class="coral-ColumnView-preview-label">Published</div>
                    <div class="coral-ColumnView-preview-value">${publishedDate}</div>
                    <div class="coral-ColumnView-preview-label">Published by</div>
                    <div class="coral-ColumnView-preview-value">${publishedBy} </div>
                </c:if>
            </div>
        </div>
    </c:if>
</div>