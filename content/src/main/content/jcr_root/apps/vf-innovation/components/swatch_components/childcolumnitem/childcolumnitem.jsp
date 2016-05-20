<%@include file="/libs/foundation/global.jsp" %>
<%@page session="false" %>
<%@page import="java.util.ArrayList,
                java.util.Iterator,
                java.util.List,
                java.util.UUID,
                javax.jcr.RepositoryException,
                javax.jcr.Session,
                javax.jcr.security.AccessControlManager,
                javax.jcr.security.Privilege,
                org.apache.commons.lang.StringUtils,
                org.apache.jackrabbit.util.Text,
                org.apache.sling.api.resource.ResourceUtil,
                com.adobe.granite.ui.components.ComponentHelper,
                com.adobe.granite.ui.components.AttrBuilder,
                com.adobe.granite.ui.components.Tag,
                com.day.cq.wcm.core.utils.ScaffoldingUtils,
                com.adobe.cq.commerce.api.Product,
                com.adobe.cq.commerce.common.CommerceHelper,
                com.day.cq.i18n.I18n,
                org.apache.sling.api.request.RequestPathInfo" %>
<%@ page import="com.vfcorp.innovation.components.LayoutViewUtils" %>
<%
    ComponentHelper cmp = new ComponentHelper(pageContext);
    AccessControlManager acm = LayoutViewUtils.getAccessControlManager(resourceResolver);
    Product product = resource.adaptTo(Product.class);
    boolean isProduct = false;
    if (product != null) {
        isProduct = true;
    }
    String title = properties.get("swatchName", "");
    if (title.equals("")) {
        title = CommerceHelper.getCardTitle(resource, pageManager);
    }
    List<String> applicableRelationships = null;
    applicableRelationships = LayoutViewUtils.setApplicationRelationship(acm, resource, isProduct);
    Tag tag = cmp.consumeTag();
    AttrBuilder attrs = tag.getAttrs();
    LayoutViewUtils.setAttribute(attrs, resource, title, isProduct, request.getContextPath(), "swatches");
%>
<%@include file="/apps/vf-innovation/components/global/childcolumnpreview/columnItemLayout.jsp" %>