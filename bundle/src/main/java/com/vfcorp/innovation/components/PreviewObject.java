package com.vfcorp.innovation.components;
import com.adobe.cq.commerce.api.Product;
import com.adobe.granite.ui.components.AttrBuilder;
import com.adobe.granite.ui.components.ComponentHelper;
import com.adobe.granite.ui.components.Config;
import com.day.cq.commons.date.RelativeTimeFormat;
import org.apache.felix.scr.annotations.Component;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.resource.ValueMap;
import com.adobe.granite.ui.components.Tag;

@Component(immediate = true,enabled = true)
public class PreviewObject {


    public static void getErrors(ComponentHelper cmp , ResourceResolver resourceResolver, SlingHttpServletRequest slingRequest){

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
        RelativeTimeFormat rtf = new RelativeTimeFormat("r", slingRequest.getResourceBundle(slingRequest.getLocale()));
    }
}