package com.vfcorp.innovation.services;

import com.day.cq.dam.api.AssetManager;
import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.Service;
import org.apache.sling.api.request.RequestParameter;
import org.apache.sling.api.resource.LoginException;
import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.resource.ResourceResolverFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.InputStream;
import java.util.*;

@Service(UploadAssetService.class)
@Component(immediate = true, enabled = true)
public class UploadAssetService {

    @Reference
    private ResourceResolverFactory resolverFactory;

    public static final Logger logger = LoggerFactory.getLogger(UploadAssetService.class);

    public String writeToDam(InputStream is, String uid, String fileName, String destinationPath) {

        try {
            ResourceResolver resourceResolver = resolverFactory.getAdministrativeResourceResolver(null);
            AssetManager assetMgr = resourceResolver.adaptTo(AssetManager.class);
            String newFile = destinationPath + "/" + uid + "/" + fileName;
            assetMgr.createAsset(newFile, is, "image/jpeg", true);
            return newFile;
        } catch (LoginException e) {
            logger.info("Error while writing Asset >> " + e.getMessage());
        }
        return null;
    }

    public Set<String> generateAssetList(Map<String, RequestParameter[]> params, String ASSET_START_STRING) {

        Set<String> parameters = params.keySet();
        Set<String> finalList = new HashSet<String>();
        Map<String, Object> imageBinaries = new HashMap<String, Object>();
        for (String key : parameters) {
            if (key.startsWith(ASSET_START_STRING)) {
                finalList.add(params.get(key)[0].toString());
            } else {
                imageBinaries.put(key, params.get(key));
            }
        }
        return finalList;
    }

    public String getPath(String imageBinaryFileName, Set<String> imageInfo) {

        Iterator<String> itr = imageInfo.iterator();
        String path = "";
        while (itr.hasNext()) {
            String tempStr = itr.next();
            if (tempStr.startsWith(imageBinaryFileName)) {
                path = tempStr.split(":")[1];
                itr.remove();
            }
        }
        return path;
    }
}
