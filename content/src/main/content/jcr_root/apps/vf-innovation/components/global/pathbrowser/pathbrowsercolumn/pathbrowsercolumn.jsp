<%@ page import="com.adobe.granite.ui.components.AttrBuilder,
                 com.day.cq.commons.LabeledResource,
                 com.day.cq.commons.predicate.PredicateProvider,
                 com.day.cq.wcm.api.Page,
                 com.adobe.granite.ui.components.Config,
                 org.apache.commons.collections.Predicate,
                 org.apache.jackrabbit.JcrConstants,
                 org.apache.jackrabbit.util.Text,
                 org.apache.sling.api.request.RequestPathInfo,
                 org.apache.sling.api.resource.Resource,
                 com.adobe.cq.commerce.api.Product,
                 com.adobe.cq.commerce.common.CommerceHelper,
                 org.apache.sling.api.resource.ValueMap,
                 javax.jcr.Node" %>
<%@ page import="java.util.*" %>
<%@ page import="com.vfcorp.innovation.services.SearchService" %>
<%@page session="false" %>
<%@include file="/libs/granite/ui/global.jsp" %>

<%

    String[] defaultIconMapStr = new String[]{"nt:file=coral-Icon--file", "cq:Page=coral-Icon--page", "nt:folder=coral-Icon--folder", "dam:Asset=coral-Icon--file", "nt:unstructured=coral-Icon--folder"};
    Config cfg = cmp.getConfig();
    String[] iconMapStr = cfg.get("icon-map", defaultIconMapStr);
    Map<String, String> iconMap = new HashMap<String, String>();

    for (String iconMapEntry : iconMapStr) {
        iconMap.put(iconMapEntry.split("=")[0], iconMapEntry.split("=")[1]);
    }


    AttrBuilder itemAttrs = new AttrBuilder(request, xssAPI);
    itemAttrs.addClass("coral-ColumnView-column");

    RequestPathInfo pathInfo = slingRequest.getRequestPathInfo();
    String path = pathInfo.getSuffix();

    if (path == null) {
        path = "/content";
    }

    // 'Predicate' request parameter
    String predicateId = slingRequest.getParameter("predicate");
    String categories = slingRequest.getParameter("categories");
    String componentName = slingRequest.getParameter("cn");
    String queryFor = slingRequest.getParameter("q");
    if(categories==null){
        categories="";
    }

    if(queryFor==null){
        queryFor="";
    }
    if(componentName==null){
        componentName="";
    }
    Predicate predicate = null;
    if (predicateId != null) {
        PredicateProvider pp = sling.getService(PredicateProvider.class);
        predicate = pp.getPredicate(predicateId);
    }
    Resource pathResource = resourceResolver.getResource(path);
%>
<nav <%= itemAttrs.build() %>>

    <div class="coral-ColumnView-column-content"><%

        if (pathResource != null) {
            if(categories.equals("Y")){
                ArrayList<String> categoryValues = new ArrayList<String>();
                categoryValues.add("Solid");
                categoryValues.add("Pattern");
                categoryValues.add("Material");
                String iconCssClass = "coral-Icon--folder";
                for(String category : categoryValues){

                    AttrBuilder childAttrs = new AttrBuilder(request, xssAPI);
                    childAttrs.addClass("coral-ColumnView-item");
                    childAttrs.add("title", category);
                    childAttrs.add("data-value", category);
                    childAttrs.add("data-id", category);
                    String dataPath = resource.getPath() + ".html"+path + "?cn="+componentName+"&q="+category;
                    childAttrs.add("data-href", dataPath);
                    childAttrs.addClass("coral-ColumnView-item--hasChildren");  %>
                    <a <%= childAttrs.build() %>>
                        <div class="coral-ColumnView-icon">
                            <i class="coral-Icon <%= iconCssClass %> coral-Icon--sizeS"></i>
                        </div>
                        <div class="coral-ColumnView-label"><%= xssAPI.filterHTML(category) %>
                        </div>
                    </a>
        <%
                }
            }else if(!queryFor.equals("")){
                    SearchService searchService = sling.getService(SearchService.class);
                    ArrayList<Resource> swatchList = searchService.getSearchResult(pathResource, queryFor.toLowerCase(), componentName);
                    for(Resource swatch : swatchList){
                        ValueMap swatchProp = swatch.adaptTo(ValueMap.class);
                        String swatchName = swatchProp.get("swatchName", "");
                        String swatchId = swatchProp.get("jcr:title", "");

                        AttrBuilder childAttrs = new AttrBuilder(request, xssAPI);
                        childAttrs.addClass("coral-ColumnView-item");
                        childAttrs.add("title",swatchName);
                        childAttrs.add("data-value", swatch.getPath());
                        childAttrs.add("data-id",swatchId );
                        String dataPath = request.getContextPath() + "/etc/vf-innovation/vans/swatches/previewcolumn.html" + Text.escapePath(swatch.getPath());
                        childAttrs.add("data-href", dataPath);
                        Product product = swatch.adaptTo(Product.class);

                        if (product != null) {
                            String thumbnailUrl = CommerceHelper.getProductCardThumbnail(request.getContextPath(), product);
                            Resource imageObj = resourceResolver.getResource(swatch.getPath()+"/image");
                            String imagePath = "";
                            if(imageObj!=null){
                                imagePath = imageObj.adaptTo(ValueMap.class).get("fileReference","");
                            }
                        %>
                        <a <%= childAttrs.build() %>>
                            <div class="coral-ColumnView-icon" style="margin-right: .9375rem;">

                                <% if(!imagePath.equals("")){ %>
                                    <img class="coral-ColumnView-thumbnail" style="width:2.5rem; height:2.5rem;max-width: none;max-height: none;" src="<%= xssAPI.getValidHref(thumbnailUrl) %>" alt="" itemprop="thumbnail">
                                <% } else {
                                    String solidColor = swatchProp.get("hexValue", "");
                                %>
                                <div class="coral-ColumnView-thumbnail" style="width:3rem; height:3rem;max-width: none;max-height: none;background-color: <%= solidColor %>" itemprop="thumbnail">&nbsp;</div>
                                <% } %>
                            </div>
                            <div class="coral-ColumnView-label foundation-collection-item-title" itemprop="title" ><%= xssAPI.filterHTML(swatchName) %>
                            </div>
                        </a>
            <%          }
            }
                } else{
                    String iconCssClass = "coral-Icon--folder";
                    String href = "/apps/vf-innovation/components/global/pathbrowser/page/pathbrowserpage/column.html" + path + "?cn="+componentName+"&categories=Y";
                    AttrBuilder childAttrs = new AttrBuilder(request, xssAPI);
                    childAttrs.addClass("coral-ColumnView-item");
                    childAttrs.add("title", pathResource.getName());
                    childAttrs.add("data-value", "t");
                    childAttrs.add("data-id","t");
                    childAttrs.add("data-href", href);
                    childAttrs.addClass("coral-ColumnView-item--hasChildren");
                    %><a <%= childAttrs.build() %>>
                        <div class="coral-ColumnView-icon">
                            <i class="coral-Icon <%= iconCssClass %> coral-Icon--sizeS"></i></div>
                        <div class="coral-ColumnView-label"><%= pathResource.adaptTo(ValueMap.class).get("modelName", "Dummy") %>
                        </div>
                    </a>
        <%
            }
        }

    %></div>
</nav>


<%!

    private String getThumbnailUrl(Page page, int width, int height) {
        String ck = "";

        ValueMap metadata = page.getProperties("image/file/jcr:content");
        if (metadata != null) {
            Calendar cal = metadata.get("jcr:lastModified", Calendar.class);
            if (cal != null) {
                ck = "" + (cal.getTimeInMillis() / 1000);
            }
        }

        return Text.escapePath(page.getPath()) + ".thumb." + width + "." + height + ".png?ck=" + ck;
    }

    private String getTitle(Resource resource) {
        String title = Text.getName(resource.getPath());
        LabeledResource lr = resource.adaptTo(LabeledResource.class);
        if (lr != null) {
            ValueMap prop = resource.adaptTo(ValueMap.class);
            String lrTitle = lr.getTitle();
            String swatchName = prop.get("swatchName","");
            if(!swatchName.equals("")){
                title = swatchName;
                lrTitle="";
            }
            title = (lrTitle == null || lrTitle.isEmpty()) ? title : lrTitle;
        }
        return title;
    }
%>
