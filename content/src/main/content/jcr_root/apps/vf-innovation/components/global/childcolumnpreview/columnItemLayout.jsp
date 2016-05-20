<a <%= attrs.build() %>>
    <div class="coral-ColumnView-icon" style="margin-right: .9375rem;">
        <c:set var="product" value="<%= product %>"/>
        <c:choose>
            <c:when test="${not empty product}">
                <c:set var="thumbnailUrl" value="<%= CommerceHelper.getProductCardThumbnail(request.getContextPath(), product) %>"/>
                <c:set var="isImageExist" value="<%= LayoutViewUtils.isThumbnailImageExist(resourceResolver,resource.getPath()) %>"/>
                <c:choose>
                    <c:when test="${isImageExist}">
                        <img class="coral-ColumnView-thumbnail" src="${thumbnailUrl}" alt="" itemprop="thumbnail">
                    </c:when>
                    <c:otherwise>
                        <div class="coral-ColumnView-thumbnail" style="width:3rem; height:3rem;max-width: none;max-height: none;background-color: ${properties.hexValue}" itemprop="thumbnail">&nbsp;</div>
                    </c:otherwise>
                </c:choose>
            </c:when>
            <c:otherwise>
                <i class="coral-Icon coral-Icon--folder coral-Icon--sizeM"></i>
            </c:otherwise>
        </c:choose>
    </div>
    <div class="coral-ColumnView-label foundation-collection-item-title" itemprop="title" title="<%= xssAPI.encodeForHTMLAttr(title) %>"><%= xssAPI.encodeForHTML(title) %></div>
    <div class="foundation-collection-quickactions" hidden data-foundation-collection-quickactions-rel="<%= StringUtils.join(applicableRelationships, " ") %>"></div>
</a>