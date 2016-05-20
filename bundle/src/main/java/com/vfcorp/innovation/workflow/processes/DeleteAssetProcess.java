package com.vfcorp.innovation.workflow.processes;

import com.adobe.granite.workflow.WorkflowException;
import com.adobe.granite.workflow.WorkflowSession;
import com.adobe.granite.workflow.exec.WorkItem;
import com.adobe.granite.workflow.exec.WorkflowData;
import com.adobe.granite.workflow.exec.WorkflowProcess;
import com.adobe.granite.workflow.metadata.MetaDataMap;
import org.apache.felix.scr.annotations.*;
import org.apache.sling.api.resource.*;
import org.osgi.framework.Constants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.jcr.Session;
import java.util.HashMap;
import java.util.Map;


@Component(label = "Delete Asset Process Step", immediate = true)
@Properties({@Property(name = Constants.SERVICE_DESCRIPTION, value = "Custom Process to delete Assets"),
        @Property(name = Constants.SERVICE_VENDOR, value = "VF Corporation"),
        @Property(name = "process.label", value = "Delete Assets Process Step")
})
@Service(value = WorkflowProcess.class)
public class DeleteAssetProcess implements WorkflowProcess {

    @Reference
    private ResourceResolverFactory factory;

    private static Logger logger = LoggerFactory.getLogger(DeleteAssetProcess.class);

    private static final String SWATCH_ASSET_PATH = "/etc/vf-innovation/vans/images/swatch/en_us/";

    public void execute(WorkItem item, WorkflowSession wfsession, MetaDataMap args) throws WorkflowException {

        final Map<String, Object> map = new HashMap<String, Object>();
        Session session = wfsession.adaptTo(Session.class);
        map.put("user.jcr.session", session);

        try {
            ResourceResolver rr = factory.getResourceResolver(map);
            WorkflowData data = item.getWorkflowData();

            String path = data.getPayload().toString();
            String array[] = path.split("/");

            String swatchId = array[array.length - 1];
            String swatchAssetPath = SWATCH_ASSET_PATH + swatchId;
            Resource swatchAsset = rr.getResource(swatchAssetPath);
            rr.delete(swatchAsset);

        } catch (LoginException e) {
            logger.info("Login Exception " + e.getMessage());
        } catch (PersistenceException e) {
            logger.info("Persistence Exception" + e.getMessage());
        }

    }
}
