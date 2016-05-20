<%@include file="/libs/foundation/global.jsp" %><%
%><%@page session="false" contentType="text/html; charset=utf-8"%>
<%@page import="java.util.ArrayList,
                  java.util.Calendar,
                  java.util.List,
                  java.text.SimpleDateFormat,
                  javax.jcr.RepositoryException,
                  javax.jcr.Session,
                  javax.jcr.Node,
                  javax.jcr.security.AccessControlManager,
                  javax.jcr.security.Privilege,
                  org.apache.commons.lang.StringUtils,
                  org.apache.jackrabbit.util.Text,
                  org.apache.sling.api.resource.Resource,
                  org.apache.sling.api.resource.ValueMap,
                  com.adobe.granite.security.user.util.AuthorizableUtil,
                  com.adobe.granite.ui.components.ComponentHelper,
                  com.adobe.granite.ui.components.Tag,
                  com.adobe.granite.ui.components.AttrBuilder,
                  com.day.cq.commons.date.RelativeTimeFormat,
                  com.day.cq.commons.jcr.JcrConstants,
                  com.day.cq.i18n.I18n,
                  com.day.cq.wcm.core.utils.ScaffoldingUtils,
                  com.adobe.cq.commerce.api.Product,
                  com.adobe.cq.commerce.common.CommerceHelper,
                  java.util.Iterator,
                  org.apache.sling.api.resource.ResourceUtil"%>

<%

    ComponentHelper cmp = new ComponentHelper(pageContext);
    I18n i18n = cmp.getI18n();
    RelativeTimeFormat rtf = new RelativeTimeFormat("r", slingRequest.getResourceBundle(request.getLocale()));

    AccessControlManager acm = null;
    try {
        acm = resourceResolver.adaptTo(Session.class).getAccessControlManager();
    } catch (RepositoryException e) {
        log.error("Unable to get access manager", e);
    }

    Product product = resource.adaptTo(Product.class);

    String scaffoldPath = properties.get("cq:scaffolding", "");
    if (scaffoldPath.length() == 0) {
        // search all scaffolds for a path match
        Resource scRoot = resourceResolver.getResource("/etc/scaffolding");
        Node root = scRoot == null ? null : scRoot.adaptTo(Node.class);
        if (root != null) {
            scaffoldPath = ScaffoldingUtils.findScaffoldByPath(root, resource.getPath());
        }
    }
    boolean hasTouchScaffold = false;
    if (scaffoldPath != null && scaffoldPath.length() > 0) {
        Resource scaffold = resourceResolver.getResource(scaffoldPath);
        hasTouchScaffold = scaffold != null && scaffold.getChild("jcr:content/cq:dialog") != null;
    }

    Calendar modifiedDateRaw = properties.get(JcrConstants.JCR_LASTMODIFIED, Calendar.class);
    String modifiedDate = formatDate(modifiedDateRaw, i18n.get("never"), rtf);
    String modifiedBy = AuthorizableUtil.getFormattedName(resourceResolver, properties.get(JcrConstants.JCR_LAST_MODIFIED_BY, String.class));
    if (modifiedBy == null) {
        modifiedBy = "";
    }

    Calendar publishedDateRaw = properties.get("cq:lastReplicated", Calendar.class);
    String publishedDate = formatDate(publishedDateRaw, null, rtf);
    String publishedBy = AuthorizableUtil.getFormattedName(resourceResolver, properties.get("cq:lastReplicatedBy", String.class));
    if (publishedBy == null) {
        publishedBy = "";
    }

    Calendar createdDateRaw = properties.get(JcrConstants.JCR_CREATED, Calendar.class);
    Calendar twentyFourHoursAgo = Calendar.getInstance();
    twentyFourHoursAgo.add(Calendar.DATE, -1);
    if ((createdDateRaw == null) || (modifiedDateRaw != null && modifiedDateRaw.before(createdDateRaw))) {
        createdDateRaw = modifiedDateRaw;
    }
    boolean isNew = createdDateRaw != null && twentyFourHoursAgo.before(createdDateRaw);

    String lastReplicationAction = properties.get("cq:lastReplicationAction", String.class);
    boolean deactivated = "Deactivate".equals(lastReplicationAction);

    String imageUrl = (product != null) ? CommerceHelper.getProductCardThumbnail(request.getContextPath(), product) : "";

    //String title = CommerceHelper.getCardTitle(resource, pageManager);
    String title = properties.get("swatchName","");
    String swatchId = properties.get("jcr:title","");

    List<String> applicableRelationships = new ArrayList<String>();
    if (product != null) {
        applicableRelationships.add("cq-commerce-products-createvariation-activator");
        applicableRelationships.add("cq-damadmin-admin-actions-add-to-collection-activator");
    } else {
        applicableRelationships.add("cq-commerce-products-createproduct-activator");
        applicableRelationships.add("cq-commerce-products-createfolder-activator");
    }

    if (hasPermission(acm, resource, Privilege.JCR_READ)) {
        if (product != null) {
            if (hasTouchScaffold) {
                applicableRelationships.add("foundation-admin-properties-activator");
            } else {
                applicableRelationships.add("cq-commerce-products-edit-activator");
            }
        }
        else {
            applicableRelationships.add("cq-commerce-products-folderproperties-activator");
        }
    }

    if (hasPermission(acm, resource, Privilege.JCR_REMOVE_NODE)) {
        applicableRelationships.add("cq-commerce-products-move-activator");
        applicableRelationships.add("cq-commerce-products-delete-activator");
        applicableRelationships.add("cq-damadmin-admin-actions-removefromcollection");
    }

    if (hasPermission(acm, resource, "crx:replicate")) {
        applicableRelationships.add("cq-commerce-products-publish-activator");
        applicableRelationships.add("cq-commerce-products-unpublish-activator");
    }

    Tag tag = cmp.consumeTag();
    AttrBuilder attrs = tag.getAttrs();

    if (product != null) {
        attrs.addClass("card-asset");
        if (hasVariantChildren(resource)) {
            attrs.addClass("stack");
        }
    } else {
        attrs.addClass("card-directory");
    }
    attrs.add("itemprop", "item");
    attrs.add("itemscope", "itemscope");
    attrs.add("data-item-title", title);
    attrs.add("data-timeline", true);
    attrs.add("data-gridlayout-sortkey", isNew ? 10 : 0);
    attrs.add("data-path", resource.getPath()); // for compatibility

    if (request.getAttribute("cq.6.0.legacy.semantics.foundation-collection") != null
            || !attrs.build().contains("foundation-collection-item")) {
        attrs.addClass("foundation-collection-item");
        attrs.add("data-foundation-collection-item-id", resource.getPath());
    }

    boolean showQuickActions = true;
    Object quickActionsAttr = request.getAttribute("com.adobe.cq.item.quickActions");
    if (quickActionsAttr != null) {
        if (quickActionsAttr.getClass().getName().equals("java.lang.String")) {
            showQuickActions =  ((String)quickActionsAttr).equals("true");
        } else {
            showQuickActions = ((Boolean)quickActionsAttr).booleanValue();
        }
    }

%>
<article <%= attrs.build() %>>
    <i class="select"></i>

    <a href="<%= xssAPI.getValidHref(request.getContextPath() + getAdminUrl(resource, currentPage)) %>" itemprop="admin" x-cq-linkchecker="skip"><%
        if (isNew) {
    %><span class="flag info"><%= i18n.get("New") %></span><%
        }
        if (product != null) { %>


        <%
            Resource imageObj = resourceResolver.getResource(resource.getPath()+"/image");
            String imagePath = "";
            if(imageObj!=null){
                imagePath = imageObj.adaptTo(ValueMap.class).get("fileReference","");
            }
            if(!imagePath.equals("")){ %>
                <span class="image">
                    <img itemprop="thumbnail" width="192" src="<%= imageUrl != null ? xssAPI.getValidHref(imageUrl) : "" %>" alt="">
                </span>
        <% } else {
                String solidColor = properties.get("hexValue","");
        %>
                <span class="image">
                    <div style="min-height: 8rem;background-color:<%= solidColor %>"></div>
                </span>
        <% } %>

      <div class="label">
            <p class="descriptor" title="<%= i18n.get("Swatch ID")%>"><%= xssAPI.encodeForHTML(swatchId) %></p>
            <h4 class="main foundation-collection-item-title" itemprop="title"><%= xssAPI.filterHTML(title) %></h4>
            <p class="sku" title="<%= i18n.get("Swatch ID")%>">
                <span itemprop="sku"><%= xssAPI.encodeForHTML(swatchId) %></span>
            </p>
            <div class="info">
                <p class="modified" title="<%= i18n.get("Modified") %>">
                    <i class="coral-Icon coral-Icon--edit coral-Icon--sizeXS"></i>
                    <span class="date" itemprop="lastmodified" data-timestamp="<%= modifiedDateRaw != null ? modifiedDateRaw.getTimeInMillis() : 0 %>"><%= xssAPI.encodeForHTML(modifiedDate) %></span>
                    <span class="user" itemprop="lastmodifiedby"><%= xssAPI.encodeForHTML(modifiedBy) %></span>
                </p> <%
                if (publishedDate != null) { %>
                <p class="published" title="<%= deactivated ? i18n.get("Not Published") : i18n.get("Published") %>">
                    <i class="coral-Icon coral-Icon--sizeXS <%= deactivated ? "coral-Icon--globeRemove" : "coral-Icon--globe" %>"></i>
                    <span class="date" itemprop="published" data-timestamp="<%= publishedDateRaw.getTimeInMillis() %>"><%= xssAPI.encodeForHTML(publishedDate) %></span>
                    <span class="user" itemprop="publishedby"><%= xssAPI.encodeForHTML(publishedBy) %></span>
                </p> <%
                } %>
            </div>
        </div> <%
        } else { %>
            <span class="image">
                <img class="show-grid" itemprop="thumbnail" src="<%=request.getContextPath() + xssAPI.getValidHref(resource.getPath())%>.folderthumbnail.jpg?width=240&height=140" alt="">
                <i class="show-list coral-Icon coral-Icon--folder"></i>
            </span>
        <div class="label">
            <h4 class="main foundation-collection-item-title" itemprop="title"><%= xssAPI.filterHTML(title) %></h4>
            <p class="description"><%= xssAPI.filterHTML(properties.get("jcr:description", "")) %></p>
        </div> <%
            }
        %>
    </a>
    <%if (showQuickActions) {%>
    <div class="foundation-collection-quickactions" data-foundation-collection-quickactions-rel="<%= StringUtils.join(applicableRelationships, " ") %>"> <%
        if (hasPermission(acm, resource, Privilege.JCR_READ)) {
            if (product != null) {
                if (hasTouchScaffold) {
                    // show touch-optimized scaffold in properties view:
    %><a class="coral-Icon coral-Icon--infoCircle coral-Icon--sizeXS" title="<%= i18n.get("View Product Data") %>"
         href="<%= xssAPI.getValidHref(request.getContextPath() + "/etc/vf-innovation/vans/swatches/properties.html" + Text.escapePath(resource.getPath())) %>"></a><%
    } else {
        // open classic ExtJS-based scaffold in separate window:
    %><a class="coral-Icon coral-Icon--edit coral-Icon--sizeXS" title="<%= i18n.get("Open") %>" target="_blank"
         href="<%= xssAPI.getValidHref(request.getContextPath() + "/bin/wcmcommand?cmd=open&path=" + Text.escape(resource.getPath()) + ".scaffolding&_charset_=utf-8") %>"></a><%
        }
    } else {
    %><a class="coral-Icon coral-Icon--infoCircle coral-Icon--sizeXS" title="<%= i18n.get("View Properties") %>"
         href="<%= xssAPI.getValidHref(request.getContextPath() + "/libs/commerce/gui/content/products/folderproperties.html" + Text.escapePath(resource.getPath())) %>"></a><%
            }
        }

        if (hasPermission(acm, resource, "crx:replicate")) { %>
        <button class="foundation-collection-action" data-foundation-collection-action='{"action": "cq.wcm.publish", "data": {"referenceSrc": "<%= request.getContextPath() %>/libs/wcm/core/content/reference.json?_charset_=utf-8{&path*}", "wizardSrc": "<%= request.getContextPath() %>/libs/wcm/core/content/sites/publishpagewizard.html?_charset_=utf-8{&item*}"}}'
                type="button" autocomplete="off" title="<%= i18n.get("Publish") %>">
            <i class="coral-Icon coral-Icon--globe coral-Icon--sizeXS"></i>
        </button> <%
            } %>
    </div>
    <%} %>
</article>

<%!

    private boolean hasPermission(AccessControlManager acm, Resource child, String privilege) {
        try {
            if (acm != null) {
                Privilege p = acm.privilegeFromName(privilege);
                return acm.hasPrivileges(child.getPath(), new Privilege[]{p});
            }
        } catch (RepositoryException e) {
            // ignore
        }
        return false;
    }

    private boolean hasVariantChildren(Resource resource) {
        for (Iterator<Resource> it = resource.listChildren(); it.hasNext();) {
            Resource r = it.next();
            if (ResourceUtil.getValueMap(r).get("cq:commerceType", "").equals("variant")) {
                return true;
            }
        }
        return false;
    }

    private String getAdminUrl(Resource pageResource, Page requestPage) {
        String base = requestPage != null ? requestPage.getVanityUrl() : "/aem/products";

        if (base == null) {
            base = requestPage.getProperties().get("sling:vanityPath", base);
        }

        if (base == null) {
            base = Text.escapePath(requestPage.getPath());
        }

        // when viewing the collection details, clicking a product card opens the product properties page
        if (requestPage != null) {
            String productPropertiesAdminUrl = requestPage.getProperties().get("productPropertiesAdminUrl", String.class);
            if (StringUtils.isNotEmpty(productPropertiesAdminUrl)) {
                base = productPropertiesAdminUrl;
            }
        }

        return base + ".html" + Text.escapePath(pageResource.getPath());
    }

    private String formatDate(Calendar cal, String defaultValue, RelativeTimeFormat rtf) {
        if (cal == null) {
            return defaultValue;
        }
        try {
            return rtf.format(cal.getTimeInMillis(), true);
        } catch (IllegalArgumentException e) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            return sdf.format(cal.getTime());
        }
    }

%>