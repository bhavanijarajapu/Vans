<%@page session="false" %>
<%@page import="java.text.SimpleDateFormat,
                java.util.Calendar,
                com.adobe.granite.security.user.util.AuthorizableUtil,
                com.adobe.granite.ui.components.ComponentHelper,
                com.adobe.granite.ui.components.AttrBuilder,
                com.adobe.granite.ui.components.Config,
                com.adobe.granite.ui.components.Tag,
                com.day.cq.commons.date.RelativeTimeFormat,
                com.day.cq.commons.jcr.JcrConstants,
                com.adobe.cq.commerce.common.CommerceHelper,
                org.apache.sling.api.request.RequestPathInfo,
                com.adobe.cq.commerce.api.Product,
                com.vfcorp.innovation.components.LayoutViewUtils" %>
<%
    ComponentHelper cmp = new ComponentHelper(pageContext);
    Config cfg = cmp.getConfig();
    String path = cmp.getExpressionHelper().getString(cfg.get("path", String.class));
    if (path == null) return;
    Resource item = resourceResolver.getResource(path);
    if (item == null) return;

    ValueMap itemProperties = item.adaptTo(ValueMap.class);
    Product product = item.adaptTo(Product.class);
    Tag tag = cmp.consumeTag();
    AttrBuilder attrs = tag.getAttrs();
    attrs.addClass("coral-ColumnView-column");
    RelativeTimeFormat rtf = new RelativeTimeFormat("r", slingRequest.getResourceBundle(request.getLocale()));
%>

<c:set var="itemProperties" value="<%= itemProperties %>"></c:set>
<c:set var="product" value="<%= product %>"></c:set>
<c:set var="attrbuteBuild"  value="<%= attrs.build() %>"></c:set>
<c:if test="${not empty product}">
    <c:set var="thumbnailUrl" value="<%= CommerceHelper.getProductCardThumbnail(request.getContextPath(), product) %>"></c:set>
    <c:set var="modifiedDate" value="<%= LayoutViewUtils.getModifiedDate(itemProperties,rtf) %>"></c:set>
    <c:set var="publishedDate" value="<%= LayoutViewUtils.getPublishedDate(itemProperties,rtf) %>"></c:set>
    <c:set var="isImageExist" value="<%= LayoutViewUtils.isThumbnailImageExist(resourceResolver,item.getPath()) %>"></c:set>
    <c:set var="publishedBy" value="<%= AuthorizableUtil.getFormattedName(resourceResolver, itemProperties.get("cq:lastReplicatedBy", "")) %>"></c:set>

    <c:choose>
        <c:when test="${not empty itemProperties.swatchName}">
            <c:set var="title"  value="${itemProperties.swatchName}" />
            <c:set var="idHeading"  value="Swatch ID" />
        </c:when>
        <c:otherwise>
            <c:set var="title"  value="${itemProperties.recipeName}" />
            <c:set var="idHeading"  value="Recipe ID" />
        </c:otherwise>
    </c:choose>
</c:if>