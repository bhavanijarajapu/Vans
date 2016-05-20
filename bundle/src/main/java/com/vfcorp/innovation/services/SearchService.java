package com.vfcorp.innovation.services;

import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Service;

import java.util.ArrayList;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.resource.ValueMap;

@Service(SearchService.class)
@Component(immediate = true, enabled = true)
public class SearchService {

    public ArrayList<Resource> getSearchResult(Resource resource, String type, String componentName) {

        ArrayList<Resource> resourceList = new ArrayList<Resource>();
        ResourceResolver resourceResolver = resource.getResourceResolver();
        if (!componentName.equals("")) {
            Resource compRes = resourceResolver.getResource(resource.getPath() + "/merchandise/" + componentName);
            if (compRes != null) {
                ValueMap compProps = compRes.adaptTo(ValueMap.class);
                String[] swatchList = compProps.get("swatchList", new String[0]);
                for (String swatchPath : swatchList) {
                    Resource swatchRes = resourceResolver.getResource(swatchPath);
                    if (swatchRes != null) {
                        ValueMap swatchProps = swatchRes.adaptTo(ValueMap.class);
                        if (swatchProps.get("swatchType", "").equalsIgnoreCase(type))
                            resourceList.add(swatchRes);
                    }
                }
            }
        }
        return resourceList;
    }
}