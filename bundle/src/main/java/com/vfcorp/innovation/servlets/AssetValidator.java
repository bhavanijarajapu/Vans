package com.vfcorp.innovation.servlets;

import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.sling.SlingServlet;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ValueMap;
import org.apache.sling.api.servlets.SlingSafeMethodsServlet;
import org.apache.sling.commons.json.JSONException;
import org.apache.sling.commons.json.JSONObject;

import javax.servlet.ServletException;
import java.io.IOException;

@SlingServlet(generateComponent = false, paths = "/bin/get/asset.json")
@Component(immediate = true, enabled = true)
public class AssetValidator extends SlingSafeMethodsServlet {

    @Override
    protected void doGet(SlingHttpServletRequest request, SlingHttpServletResponse response) throws ServletException, IOException {

        response.setContentType("application/json");
        String path = request.getParameter("path");
        JSONObject jsonObject = new JSONObject();
        if (path != null && !path.equals("")) {
            Resource resource = request.getResourceResolver().getResource(path);
            if (resource != null) {
                ValueMap properties = resource.adaptTo(ValueMap.class);
                String swatchType = properties.get("swatchType", "");
                String hexValue = "";
                try {
                    jsonObject.put("swatchName", properties.get("swatchName", ""));
                    jsonObject.put("swatchId", properties.get("jcr:title", ""));
                    if (swatchType.equalsIgnoreCase("solid")) {
                        hexValue = properties.get("hexValue", "");
                        jsonObject.put("hexValue", hexValue);
                        jsonObject.put("isImage", false);
                    } else {
                        String imagePath = properties.get("image/fileReference", "");
                        jsonObject.put("imagePath", imagePath);
                        jsonObject.put("isImage", true);
                    }
                } catch (JSONException je) {
                    je.printStackTrace();
                }
            }
        }
        response.getWriter().print(jsonObject);
    }

}
