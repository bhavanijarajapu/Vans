package com.vfcorp.innovation.components;

import org.apache.felix.scr.annotations.Component;

@Component(immediate = true,enabled = true)
public class PreviewObject {


    public static void getErrors(){

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
    }
}
