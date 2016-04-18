package com.vans.servlets;


import org.apache.felix.scr.annotations.Properties;
import org.apache.felix.scr.annotations.Property;
import org.apache.felix.scr.annotations.sling.SlingServlet;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.servlets.SlingAllMethodsServlet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.PrintWriter;

@SlingServlet(
        methods = {"POST"},
        paths={"/bin/saveswatch"},
        extensions = {"json"}
)
@Properties({
        @Property(name="service.description",value="Display Rating Servlet", propertyPrivate=false),
        @Property(name="service.vendor",value="Havells", propertyPrivate=false)
})
public class RatingComponent extends SlingAllMethodsServlet {
    protected final Logger log = LoggerFactory.getLogger(RatingComponent.class);


    @Override
    protected void doPost(SlingHttpServletRequest request, SlingHttpServletResponse response) throws IOException {

        PrintWriter out = response.getWriter();
        out.println(request.getRequestParameterList());
    }
}
