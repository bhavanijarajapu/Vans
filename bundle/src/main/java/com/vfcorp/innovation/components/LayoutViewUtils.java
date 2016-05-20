package com.vfcorp.innovation.components;

import com.day.cq.commons.date.RelativeTimeFormat;
import com.day.cq.commons.jcr.JcrConstants;
import com.day.cq.wcm.core.utils.ScaffoldingUtils;
import org.apache.felix.scr.annotations.Component;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.resource.ResourceUtil;
import org.apache.sling.api.resource.ValueMap;

import javax.jcr.Node;
import javax.jcr.RepositoryException;
import javax.jcr.Session;
import javax.jcr.security.AccessControlManager;
import javax.jcr.security.Privilege;
import java.text.SimpleDateFormat;
import java.util.*;

import com.adobe.granite.ui.components.AttrBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(enabled = true, immediate = true)
public class LayoutViewUtils {

    public static final Logger logger = LoggerFactory.getLogger(LayoutViewUtils.class);

    public static String formatDate(Calendar cal, String defaultValue, RelativeTimeFormat rtf) {

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

    public static String getModifiedDate(ValueMap itemProperties, RelativeTimeFormat rtf) {

        Calendar modifiedDateRaw = itemProperties.get(JcrConstants.JCR_LASTMODIFIED, Calendar.class);
        String modifiedDate = formatDate(modifiedDateRaw, "never", rtf);
        return modifiedDate;
    }

    public static String getPublishedDate(ValueMap itemProperties, RelativeTimeFormat rtf) {

        Calendar publishedDateRaw = itemProperties.get(JcrConstants.JCR_LASTMODIFIED, Calendar.class);
        String publishedDate = formatDate(publishedDateRaw, null, rtf);
        return publishedDate;
    }

    public static boolean isThumbnailImageExist(ResourceResolver resourceResolver, String itemPath) {

        Resource imageObj = resourceResolver.getResource(itemPath + "/image");
        String imagePath = "";
        if (imageObj != null) {
            imagePath = imageObj.adaptTo(ValueMap.class).get("fileReference", "");
        }
        return (!imagePath.equals(""));

    }

    public static AccessControlManager getAccessControlManager(ResourceResolver resourceResolver){

        AccessControlManager acm = null;
        try {
            acm = resourceResolver.adaptTo(Session.class).getAccessControlManager();
        } catch (RepositoryException e) {
            logger.info("Unable to get access manager " + e);
        }
        return acm;
    }

    public static List<String> setApplicationRelationship(AccessControlManager acm, Resource resource, boolean isProduct) throws RepositoryException {

        List<String> applicableRelationships = new ArrayList<String>();
        try {
            if (isProduct) {
                applicableRelationships.add("cq-commerce-products-createvariation-at-activator");
            } else {
                applicableRelationships.add("cq-commerce-products-createproduct-at-activator");
                applicableRelationships.add("cq-commerce-products-createfolder-at-activator");
                applicableRelationships.add("cq-commerce-products-import-at-activator");
            }

            if (hasPermission(acm, resource, Privilege.JCR_READ)) {
                if (isProduct) {
                    if (hasTouchScaffold(resource)) {
                        applicableRelationships.add("foundation-admin-properties-activator");
                    } else {
                        applicableRelationships.add("cq-commerce-products-edit-activator");
                    }
                } else {
                    applicableRelationships.add("cq-commerce-products-folderproperties-activator");
                }
            }
            if (hasPermission(acm, resource, Privilege.JCR_REMOVE_NODE)) {
                applicableRelationships.add("cq-commerce-products-move-activator");
                applicableRelationships.add("cq-commerce-products-delete-activator");
            }

            if (hasPermission(acm, resource, "crx:replicate")) {
                applicableRelationships.add("cq-commerce-products-publish-activator");
                applicableRelationships.add("cq-commerce-products-unpublish-activator");
            }
        }catch (RepositoryException re){
            logger.info("Repository Exception " + re.getMessage());
        }
        return applicableRelationships;
    }

    public static boolean hasTouchScaffold(Resource resource) throws RepositoryException {

        ResourceResolver resourceResolver = resource.getResourceResolver();
        ValueMap properties = resource.adaptTo(ValueMap.class);
        String scaffoldPath = properties.get("cq:scaffolding", "");
        if (scaffoldPath.length() == 0) {
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

        return hasTouchScaffold;
    }


    public static boolean hasPermission(AccessControlManager acm, Resource resource, String privilege) {

        if (acm != null) {
            try {
                Privilege p = acm.privilegeFromName(privilege);
                return acm.hasPrivileges(resource.getPath(), new Privilege[]{p});
            } catch (RepositoryException re) {
                logger.info("Repository Exception "+re);
            }
        }
        return false;
    }

    public static boolean hasChildren(Resource resource, boolean isProduct) {

        for (Iterator<Resource> it = resource.listChildren(); it.hasNext(); ) {
            Resource r = it.next();
            if (isProduct) {
                if (ResourceUtil.getValueMap(r).get("cq:commerceType", "").equals("variant")) {
                    return true;
                }
            } else {
                ValueMap properties = r.adaptTo(ValueMap.class);
                String commerceType = properties.get("cq:commerceType", "");
                if (commerceType.equalsIgnoreCase("product")) {
                    return true;
                }
                if (r.isResourceType("sling:Folder") || r.isResourceType("sling:OrderedFolder")) {
                    return true;
                }
            }
        }
        return false;
    }

    public static void setAttribute(AttrBuilder attrs, Resource resource, String title, boolean isProduct, String contextPath,String assetType){

        String resourcePath = resource.getPath();
        attrs.add("itemscope", "itemscope");
        attrs.add("data-path", resourcePath);
        attrs.add("data-timeline", true);
        attrs.add("data-item-title", title);
        attrs.addClass("coral-ColumnView-item");
        attrs.add("data-href", "#" + UUID.randomUUID());
        setDataSrc(attrs, resourcePath, resource, isProduct, contextPath, assetType);
    }

    private static void setDataSrc(AttrBuilder attrs, String resourcePath, Resource resource,boolean isProduct,String contextPath,String assetType){

        if (hasChildren(resource, isProduct)) {
            attrs.add("data-src", contextPath + "/etc/vf-innovation/vans/"+assetType+"/column{.offset,limit}.html" + resourcePath);
            attrs.addClass("coral-ColumnView-item--hasChildren");
        } else {
            attrs.add("data-src", contextPath + "/etc/vf-innovation/vans/"+assetType+"/previewcolumn.html" + resourcePath);
        }
        if(!(resourcePath.endsWith("/en_us/"+assetType)
                || resourcePath.endsWith("/en_us")
                || resourcePath.contains("/en_us/"+assetType+"/"))){
            attrs.addClass("hide");
        }
    }
}