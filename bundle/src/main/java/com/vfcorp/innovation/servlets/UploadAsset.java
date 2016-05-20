package com.vfcorp.innovation.servlets;

import com.vfcorp.innovation.services.UploadAssetService;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.sling.SlingServlet;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.request.RequestParameter;
import org.apache.sling.api.resource.ResourceResolverFactory;
import org.apache.sling.api.servlets.SlingAllMethodsServlet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.rmi.ServerException;
import java.util.*;
import java.util.Map.Entry;

@SlingServlet(paths = "/bin/upload/asset", methods = "POST")
public class UploadAsset extends SlingAllMethodsServlet {

    public static final Logger logger = LoggerFactory.getLogger(UploadAsset.class);

    private static final String ASSET_START_STRING = "asset_";

    @Reference
    private ResourceResolverFactory resolverFactory;

    @Reference
    private UploadAssetService uploadAssetService;

    @Override
    protected void doPost(SlingHttpServletRequest request, SlingHttpServletResponse response) throws ServerException, IOException {

        try {
            final boolean isMultipart = ServletFileUpload.isMultipartContent(request);
            if (isMultipart) {
                Map<String, RequestParameter[]> params = request.getRequestParameterMap();
                String uid = request.getParameter("id");
                Set<String> imageInfo = uploadAssetService.generateAssetList(params,ASSET_START_STRING);
                for (Entry<String, RequestParameter[]> pairs : params.entrySet()) {
                    String k = pairs.getKey();
                    if (!k.equalsIgnoreCase("id") && (!k.startsWith(ASSET_START_STRING))) {
                        RequestParameter param = pairs.getValue()[0];
                        String imageBinaryFileName = param.getFileName();
                        String destinationPath = uploadAssetService.getPath(imageBinaryFileName, imageInfo);
                        InputStream stream = param.getInputStream();
                        uploadAssetService.writeToDam(stream, uid, param.getFileName(), destinationPath);
                    }
                }
            }
        } catch (Exception e) {
            logger.info(e.getMessage());
        }
    }
}