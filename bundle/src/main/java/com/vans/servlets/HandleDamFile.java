package com.vans.servlets;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.rmi.ServerException;
import java.util.Dictionary;
import java.util.Calendar;
import java.io.*;

import org.apache.felix.scr.annotations.Properties;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.Reference;
import org.apache.felix.scr.annotations.sling.SlingServlet;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.servlets.SlingSafeMethodsServlet;
import org.apache.sling.commons.osgi.OsgiUtil;
import org.apache.sling.jcr.api.SlingRepository;
import org.apache.felix.scr.annotations.Reference;
import org.osgi.service.component.ComponentContext;
import javax.jcr.Session;



import javax.jcr.Session;
import javax.jcr.Node;

//Sling Imports
import org.apache.sling.api.resource.ResourceResolverFactory ;
import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.resource.Resource;

//AssetManager
import com.day.cq.dam.api.AssetManager;

//This is a component so it can provide or consume services
@SlingServlet(paths="/bin/updamfile", methods = "POST", metatype=true)
public class HandleDamFile extends org.apache.sling.api.servlets.SlingAllMethodsServlet {
    private static final long serialVersionUID = 2598426539166789515L;

    private Session session;

    //Inject a Sling ResourceResolverFactory
    @Reference
    private ResourceResolverFactory resolverFactory;

    @Override
    protected void doPost(SlingHttpServletRequest request, SlingHttpServletResponse response) throws ServerException, IOException {

        try
        {
            final boolean isMultipart = org.apache.commons.fileupload.servlet.ServletFileUpload.isMultipartContent(request);
            PrintWriter out = null;

            out = response.getWriter();
            if (isMultipart) {
                final java.util.Map<String, org.apache.sling.api.request.RequestParameter[]> params = request.getRequestParameterMap();
                for (final java.util.Map.Entry<String, org.apache.sling.api.request.RequestParameter[]> pairs : params.entrySet()) {
                    final String k = pairs.getKey();
                    final org.apache.sling.api.request.RequestParameter[] pArr = pairs.getValue();
                    final org.apache.sling.api.request.RequestParameter param = pArr[0];
                    final InputStream stream = param.getInputStream();

                    //Save the uploaded file into the Adobe CQ DAM
                    out.println("The Sling Servlet placed the uploaded file here: " + writeToDam(stream,param.getFileName()));

                }
            }
        }

        catch (Exception e) {
            e.printStackTrace();
        }

    }


    //Save the uploaded file into the AEM DAM using AssetManager APIs
    private String writeToDam(InputStream is, String fileName)
    {
        try
        {
            //Inject a ResourceResolver
            ResourceResolver resourceResolver = resolverFactory.getAdministrativeResourceResolver(null);

            //Use AssetManager to place the file into the AEM DAM
            com.day.cq.dam.api.AssetManager assetMgr = resourceResolver.adaptTo(com.day.cq.dam.api.AssetManager.class);
            String newFile = "/etc/commerce/products/vans/images/"+fileName ;
            assetMgr.createAsset(newFile, is,"image/jpeg", true);

            // Return the path to the file was stored
            return newFile;
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
        return null;
    }

}