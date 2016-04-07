package com.vans.servlets;

import org.apache.felix.scr.annotations.Activate;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.sling.SlingServlet;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ResourceResolver;

import org.apache.sling.api.resource.ValueMap;
import org.apache.sling.api.servlets.SlingSafeMethodsServlet;
import org.apache.sling.commons.json.JSONArray;
import org.apache.sling.commons.json.JSONException;
import org.apache.sling.commons.json.io.JSONWriter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.sling.commons.osgi.PropertiesUtil;

import javax.servlet.ServletException;
import java.io.IOException;
import java.util.Arrays;
import java.util.Map;

@SlingServlet(paths = "/bin/vfcorp/products/listing",methods = "GET", metatype = true)

public class ProductListingJSONServlet extends SlingSafeMethodsServlet {

    private static final long serialVersionUID = 3070874741784248319L;
    private static Logger LOGGER = LoggerFactory.getLogger(ProductListingJSONServlet.class);

    private static final String DEFAULT_PATH = "/content/admin_tool/en_us";
    @Property(label = "Path",
            description = "Path of the content node",
            value = DEFAULT_PATH)
    public static final String PROP_PATH = "path";

    private String path = DEFAULT_PATH;

    @Activate
    protected final void activate(final Map<String, String> properties) throws Exception {
        // Read in OSGi Properties for use by the OSGi Service in the Activate method
        this.path = PropertiesUtil.toString(properties.get(PROP_PATH), DEFAULT_PATH);
    }

    @Override
    public void doGet(SlingHttpServletRequest request, SlingHttpServletResponse response) throws ServletException, IOException {

        String type = request.getParameter("type");
        final ResourceResolver resourceResolver = request.getResourceResolver();
        response.setContentType("application/json");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        JSONWriter jsonWriter = new JSONWriter(response.getWriter());
        try {

            if (type != null && type.equalsIgnoreCase("swatches")) {
                jsonWriter.array();

                writeSwatchJsonObject(resourceResolver, this.path, jsonWriter);
                jsonWriter.endArray();
            }
            if (type != null && type.equalsIgnoreCase("models")) {
                writeModelJsonObject(resourceResolver, this.path, jsonWriter);
            }
            if (type != null && type.equalsIgnoreCase("recipies")) {

                writeRecipiesJsonObject(resourceResolver, this.path, jsonWriter);
            }

        } catch (JSONException e) {
            LOGGER.error("Json Exception", e.getMessage());
        }
    }

    private void writeRecipiesJsonObject(ResourceResolver resourceResolver, String path, JSONWriter jsonWriter) throws JSONException {
         path = this.path + "/recipies";
        Resource recipiesFolder = resourceResolver.getResource("/content/admin_tool/en_us/recipies");
        if (recipiesFolder != null) {
            Iterable<Resource> recipies = recipiesFolder.getChildren();
            for (Resource recipie : recipies) {
                jsonWriter.object();
                ValueMap map = recipie.adaptTo(ValueMap.class);
                populateObjectChildrenJson(map,jsonWriter);
                Resource productImage = recipie.getChild("product_images");
                if(productImage!=null){
                    jsonWriter.key("product_images");
                    jsonWriter.object();
                    populateObjectChildrenJson(productImage.adaptTo(ValueMap.class),jsonWriter);
                    jsonWriter.endObject();
                }

                Resource components = recipie.getChild("components");
                if(productImage!=null){
                    jsonWriter.key("components");
                    jsonWriter.object();
                    populateObjectChildrenJson(components.adaptTo(ValueMap.class),jsonWriter);
                    jsonWriter.endObject();
                }

                jsonWriter.endObject();
            }

        }
    }

    private void writeModelJsonObject(ResourceResolver resourceResolver, String path, JSONWriter jsonWriter)
            throws JSONException {
        path = this.path + "3D Models/3D Model Data";
        Resource modelFolder = resourceResolver.getResource("/content/admin_tool/en_us/3D Models/3D Model Data");
        if (modelFolder != null) {
            Iterable<Resource> models = modelFolder.getChildren();
            for (Resource model : models) {
                jsonWriter.object();
                Iterable<Resource> modelChildren = model.getChildren();
                for (Resource child : modelChildren) {
                    log("modelChildren path-------------->>>" + child.getPath());
                    if (child.getName().equalsIgnoreCase("object")) {
                        writeModelObject(child, jsonWriter);
                    }
                    if (child.getName().equalsIgnoreCase("geometries")) {
                        writeModelGeometries(child, jsonWriter);
                    }
                    if (child.getName().equalsIgnoreCase("materials")) {
                        writeMaterialsGeometries(child, jsonWriter);
                    }
                    if (child.getName().equalsIgnoreCase("metadata")) {
                        writeMetadatasGeometries(child, jsonWriter);
                    }
                    if (child.getName().equalsIgnoreCase("animations")) {
                        writeAnimationsGeometries(child, jsonWriter);
                    }
                    if (child.getName().equalsIgnoreCase("images")) {
                        writeImagesJson(child, jsonWriter);
                    }
                    if (child.getName().equalsIgnoreCase("textures")) {
                        writeTexturesJson(child, jsonWriter);
                    }
                }
                jsonWriter.endObject();
            }
        } else LOGGER.error("no model folder found");
    }

    private void writeTexturesJson(Resource child, JSONWriter jsonWriter) throws JSONException {
        jsonWriter.key(child.getName());
        jsonWriter.array();
        jsonWriter.endArray();
    }

    private void writeImagesJson(Resource child, JSONWriter jsonWriter) throws JSONException {
        jsonWriter.key(child.getName());
        jsonWriter.array();
        jsonWriter.endArray();
    }

    private void writeAnimationsGeometries(Resource child, JSONWriter jsonWriter) throws JSONException {
        jsonWriter.key(child.getName());
        ValueMap map = child.adaptTo(ValueMap.class);
        jsonWriter.array();
        jsonWriter.object();
        populateObjectChildrenJson(map,jsonWriter);
        jsonWriter.key("tracks");
        jsonWriter.array();
        jsonWriter.endArray();
        jsonWriter.endObject();
        jsonWriter.endArray();
    }

    private void writeMetadatasGeometries(Resource child, JSONWriter jsonWriter) throws JSONException {
        jsonWriter.key(child.getName());
        ValueMap map = child.adaptTo(ValueMap.class);
        jsonWriter.object();
        populateObjectChildrenJson(map,jsonWriter);
        jsonWriter.endObject();
    }

    private void writeMaterialsGeometries(Resource child, JSONWriter jsonWriter)  throws JSONException{
        jsonWriter.key(child.getName());
        jsonWriter.array();
        Iterable<Resource> materialChildren = child.getChildren();
        for(Resource materialChild : materialChildren){
            ValueMap map = materialChild.adaptTo(ValueMap.class);
            jsonWriter.object();
            populateObjectChildrenJson(map,jsonWriter);
            jsonWriter.endObject();
        }
        jsonWriter.endArray();

    }

    private void writeModelGeometries(Resource child, JSONWriter jsonWriter) throws JSONException {
        jsonWriter.key(child.getName());
        jsonWriter.array();

        //insert code here
        Iterable<Resource> geometriesChildren = child.getChildren();
        for(Resource geometriesChild : geometriesChildren){
            ValueMap map = geometriesChild.adaptTo(ValueMap.class);
            jsonWriter.object();
            populateObjectChildrenJson(map,jsonWriter);
            Resource data = geometriesChild.getChild("data");
            //LOGGER.debug("data node path------------->>"+data.getPath());
            if(data!=null){
                ValueMap dataMap = data.adaptTo(ValueMap.class);
                jsonWriter.key("data");
                jsonWriter.object();
                populateObjectChildrenJson(dataMap,jsonWriter);
                String face = dataMap.get("faces",String.class);
                if (dataMap.get("faces") != null) {
                    String[] ary = dataMap.get("faces", String.class).split(",");
                    JSONArray jsonArray = new JSONArray(Arrays.toString(ary));
                    jsonWriter.key("faces").value(jsonArray);
                }
                if (dataMap.get("uvs") != null) {
                    String[] ary = dataMap.get("uvs", String.class).split(",");
                    JSONArray jsonArray = new JSONArray(Arrays.toString(ary));
                    jsonWriter.key("uvs").value(jsonArray);
                }
                if (dataMap.get("normals") != null) {
                    String[] ary = dataMap.get("normals", String.class).split(",");
                    JSONArray jsonArray = new JSONArray(Arrays.toString(ary));
                    jsonWriter.key("normals").value(jsonArray);
                }
                if (dataMap.get("vertices") != null) {
                    String[] ary = dataMap.get("vertices", String.class).split(",");
                    JSONArray jsonArray = new JSONArray(Arrays.toString(ary));
                    jsonWriter.key("vertices").value(jsonArray);
                }
                Iterable<Resource> dataChildren = data.getChildren();
                for(Resource dataChild : dataChildren){
                    if(dataChild.getName().equalsIgnoreCase("metadata")){
                        jsonWriter.key("metadata");
                        jsonWriter.object();
                        ValueMap dataChildMap =dataChild.adaptTo(ValueMap.class);
                        populateObjectChildrenJson(dataChildMap, jsonWriter);
                        if (dataChildMap.get("normals") != null) {
                            jsonWriter.key("normals").value(dataChildMap.get("normals", Integer.class));
                        }
                        if (dataChildMap.get("faces") != null) {
                            jsonWriter.key("faces").value(dataChildMap.get("faces", Integer.class));
                        }
                        if (dataChildMap.get("vertices") != null) {
                            jsonWriter.key("vertices").value(dataChildMap.get("vertices", Integer.class));
                        }
                        if (dataChildMap.get("uvs") != null) {
                            jsonWriter.key("uvs").value(dataChildMap.get("uvs", Integer.class));
                        }
                        jsonWriter.endObject();
                    }
                    if(dataChild.getName().equalsIgnoreCase("uvs")){
                        //Resource uvs = dataChild.getChild("uvs");
                        Iterable<Resource> uvsChildren = dataChild.getChildren();
                        jsonWriter.key("uvs");
                        jsonWriter.array();
                        for(Resource uvsChild : uvsChildren){
                            ValueMap uvsChildMap = uvsChild.adaptTo(ValueMap.class);
                            if (uvsChildMap.get("value") != null) {
                                String[] ary = uvsChildMap.get("value", String.class).split(",");
                                JSONArray jsonArray = new JSONArray(Arrays.toString(ary));
                                jsonWriter.value(jsonArray);
                            }
                        }
                        jsonWriter.endArray();
                    }
                }
                jsonWriter.endObject();
            }
            jsonWriter.endObject();
        }
        //end code here
        jsonWriter.endArray();

    }

    private void writeModelObject(Resource child, JSONWriter jsonWriter) throws JSONException {
        jsonWriter.key(child.getName());
        ValueMap map = child.adaptTo(ValueMap.class);
        jsonWriter.object();

        populateObjectChildrenJson(map,jsonWriter);
        Iterable<Resource> objectChildren = child.getChildren();
        if (objectChildren != null) {
            jsonWriter.key("children");
            jsonWriter.array();
            for (Resource objectChild : objectChildren) {
                LOGGER.error("objectChild path termination---->>" + objectChild.getPath());
                ValueMap objectChildMap = objectChild.adaptTo(ValueMap.class);
                jsonWriter.object();

                populateObjectChildrenJson(objectChildMap, jsonWriter);
                Iterable<Resource> objectSubChildren = objectChild.getChildren();
                jsonWriter.key("children");
                jsonWriter.array();
                for (Resource objectSubChild : objectSubChildren) {
                    jsonWriter.object();
                    ValueMap objectSubChildMap = objectSubChild.adaptTo(ValueMap.class);
                    populateObjectChildrenJson(objectSubChildMap, jsonWriter);
                    jsonWriter.endObject();

                }
                jsonWriter.endArray();
                jsonWriter.endObject();

            }
            jsonWriter.endArray();
        }
        jsonWriter.endObject();
    }

    private void populateObjectChildrenJson(ValueMap map, JSONWriter jsonWriter) throws JSONException {

        if (map.get("recipe_id") != null) {
            jsonWriter.key("recipe_id").value(map.get("recipe_id", Integer.class));
        }
        if (map.get("sku") != null) {
            jsonWriter.key("sku").value(map.get("sku", Integer.class));
        }
        if (map.get("category") != null) {
            jsonWriter.key("category").value(map.get("category", String.class));
        }
        if (map.get("model_type") != null) {
            jsonWriter.key("model_type").value(map.get("model_type", String.class));
        }
        if (map.get("product_name") != null) {
            jsonWriter.key("product_name").value(map.get("product_name", String.class));
        }
        if (map.get("small") != null) {
            jsonWriter.key("small").value(map.get("small", String.class));
        }
        if (map.get("medium") != null) {
            jsonWriter.key("medium").value(map.get("medium", String.class));
        }
        if (map.get("large") != null) {
            jsonWriter.key("large").value(map.get("large", String.class));
        }
        if (map.get("vamp") != null) {
            jsonWriter.key("vamp").value(map.get("vamp", Integer.class));
        }
        if (map.get("quarter") != null) {
            jsonWriter.key("quarter").value(map.get("quarter", Integer.class));
        }
        if (map.get("binding") != null) {
            jsonWriter.key("binding").value(map.get("binding", Integer.class));
        }
        if (map.get("foxing") != null) {
            jsonWriter.key("foxing").value(map.get("foxing", Integer.class));
        }
        if (map.get("foxingtip") != null) {
            jsonWriter.key("foxingtip").value(map.get("foxingtip", Integer.class));
        }
        if (map.get("foxingstripe") != null) {
            jsonWriter.key("foxingstripe").value(map.get("foxingstripe", Integer.class));
        }
        if (map.get("eyelets") != null) {
            jsonWriter.key("eyelets").value(map.get("eyelets", Integer.class));
        }
        if (map.get("lace") != null) {
            jsonWriter.key("lace").value(map.get("lace", Integer.class));
        }
        if (map.get("tongue") != null) {
            jsonWriter.key("tongue").value(map.get("tongue", Integer.class));
        }
        if (map.get("fps") != null) {
            jsonWriter.key("fps").value(map.get("fps", Integer.class));
        }
        if (map.get("generator") != null) {
            jsonWriter.key("generator").value(map.get("generator", String.class));
        }
        if (map.get("version") != null) {
            jsonWriter.key("version").value(map.get("version", Float.class));
        }

        if (map.get("name") != null) {
            jsonWriter.key("name").value(map.get("name", String.class));
        }
        if (map.get("uuid") != null) {
            jsonWriter.key("uuid").value(map.get("uuid", String.class));
        }
        if (map.get("matrix") != null) {
            String [] value = map.get("matrix", String[].class);
            JSONArray jsonArray = new JSONArray(Arrays.toString(value));

            jsonWriter.key("matrix").value(jsonArray);
        }
        if (map.get("visible") != null) {
            jsonWriter.key("visible").value(map.get("visible", Boolean.class));
        }
        if (map.get("type") != null) {
            jsonWriter.key("type").value(map.get("type", String.class));
        }
        if (map.get("material") != null) {
            jsonWriter.key("material").value(map.get("material", String.class));
        }
        if (map.get("castShadow") != null) {
            jsonWriter.key("castShadow").value(map.get("castShadow", Boolean.class));
        }
        if (map.get("receiveShadow") != null) {
            jsonWriter.key("receiveShadow").value(map.get("receiveShadow", Boolean.class));
        }
        if (map.get("geometry") != null) {
            jsonWriter.key("geometry").value(map.get("geometry", String.class));
        }
        if (map.get("specular") != null) {
            jsonWriter.key("specular").value(map.get("specular", Integer.class));
        }
        if (map.get("vertexColors") != null) {
            jsonWriter.key("vertexColors").value(map.get("vertexColors", Integer.class));
        }
        if (map.get("blending") != null) {
            jsonWriter.key("blending").value(map.get("blending", String.class));
        }
        if (map.get("emissive") != null) {
            jsonWriter.key("emissive").value(map.get("emissive", Integer.class));
        }
        if (map.get("shininess") != null) {
            jsonWriter.key("shininess").value(map.get("shininess", Integer.class));
        }
        if (map.get("color") != null) {
            jsonWriter.key("color").value(map.get("color", Integer.class));
        }
        if (map.get("depthWrite") != null) {
            jsonWriter.key("depthWrite").value(map.get("depthWrite", Boolean.class));
        }
        if (map.get("depthTest") != null) {
            jsonWriter.key("depthTest").value(map.get("depthTest", Boolean.class));
        }

    }

    private void writeSwatchJsonObject(ResourceResolver resourceResolver, String path, JSONWriter jsonWriter)
            throws JSONException {
        path = this.path + "/swatches";
        Resource swatchFolder = resourceResolver.getResource(path);
        if (swatchFolder != null) {
            Iterable<Resource> swatches = swatchFolder.getChildren();
            for (Resource swatch : swatches) {
                ValueMap map = swatch.adaptTo(ValueMap.class);
                jsonWriter.object();

                if (map.get("id") != null) {
                    jsonWriter.key("id").value(map.get("id", Integer.class));
                }
                if (map.get("name") != null) {
                    jsonWriter.key("name").value(map.get("name", String.class));
                }
                if (map.get("type") != null) {
                    jsonWriter.key("type").value(map.get("type", String.class));
                }
                if (map.get("hex") != null) {
                    jsonWriter.key("hex").value(map.get("hex", String.class));
                }
                if (map.get("mat_group") != null) {
                    jsonWriter.key("mat_group").value(map.get("mat_group", String.class));
                }
                if (map.get("ui") != null) {
                    jsonWriter.key("ui").value(map.get("ui", String.class));
                }
                if (map.get("map") != null) {
                    jsonWriter.key("map").value(map.get("map", String.class));
                }
                if (map.get("alphaMap") != null) {
                    jsonWriter.key("alphaMap").value(map.get("alphaMap", String.class));
                }
                if (map.get("diffuseMap") != null) {
                    jsonWriter.key("diffuseMap").value(map.get("diffuseMap", String.class));
                }
                if (map.get("normalMap") != null) {
                    jsonWriter.key("normalMap").value(map.get("normalMap", String.class));
                }
                if (map.get("specularMap") != null) {
                    jsonWriter.key("specularMap").value(map.get("specularMap", String.class));
                }
                LOGGER.error("Json object " + jsonWriter.toString());
                jsonWriter.endObject();
            }
        } else LOGGER.error("No Swatch folder found");
    }
}
