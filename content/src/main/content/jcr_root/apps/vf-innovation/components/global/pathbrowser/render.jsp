<%@include file="/apps/vf-innovation/global.jsp" %>
<%@page session="false"
          import="org.apache.jackrabbit.util.Text,
                  com.adobe.granite.ui.components.AttrBuilder,
                  com.adobe.granite.ui.components.Config,
                  com.adobe.granite.ui.components.Field,
                  com.adobe.granite.ui.components.Tag" %>
<%@ page import="java.util.UUID" %>
<%

    Config cfg = cmp.getConfig();
    ValueMap vm = (ValueMap) request.getAttribute(Field.class.getName());

    Field field = new Field(cfg);
    boolean mixed = field.isMixed(cmp.getValue());


    boolean disabled = cfg.get("disabled", false);
    String predicate = cfg.get("predicate", "hierarchyNotFile"); // 'folder', 'hierarchy', 'hierarchyNotFile' or 'nosystem'
    String defaultOptionLoader = "granite.ui.pathBrowser.pages." + predicate;
    Tag tag = cmp.consumeTag();
    String rootPath = cmp.getExpressionHelper().getString(cfg.get("rootPath", "/"));
    
    AttrBuilder attrs = tag.getAttrs();

    attrs.add("id", cfg.get("id", String.class));
    attrs.addClass(cfg.get("class", String.class));
    attrs.addRel(cfg.get("rel", String.class));
    attrs.add("title", i18n.getVar(cfg.get("title", String.class)));
    
    attrs.addClass("coral-PathBrowser");
    attrs.add("data-init", "pathbrowser");
    attrs.add("data-root-path", rootPath);
    attrs.add("data-option-loader", cfg.get("optionLoader", defaultOptionLoader));
    attrs.add("data-option-loader-root", cfg.get("optionLoaderRoot", String.class));
    attrs.add("data-option-value-reader", cfg.get("optionValueReader", String.class));
    attrs.add("data-option-title-reader", cfg.get("optionTitleReader", String.class));
    attrs.add("data-option-renderer", cfg.get("optionRenderer", String.class));
	attrs.add("data-autocomplete-callback", cfg.get("autocompleteCallback", String.class));

    if (disabled) {
        attrs.add("data-disabled", disabled);
    }


    String defaultPickerSrc = "/apps/vf-innovation/components/global/pathbrowser/page/pathbrowserpage/column.html";
    String modelPath = request.getParameter("modelPath");
    if(modelPath!=null && !modelPath.equals("")){
        defaultPickerSrc += Text.escapePath(modelPath) + "?predicate=" + Text.escape(predicate);
    }else{
        defaultPickerSrc += Text.escapePath(rootPath) + "?predicate=" + Text.escape(predicate);
    }




    Resource rootResource = resourceResolver.getResource(rootPath);
    String crumbRoot = i18n.getVar("3D Model Data");
    ValueMap props = resource.adaptTo(ValueMap.class);
    String componentName = props.get("componentName", "");
    if(!componentName.equals("")){
        defaultPickerSrc += "&cn="+componentName;
    }


    String pickerSrc = cfg.get("pickerSrc", defaultPickerSrc);
    String icon = cfg.get("icon", "icon-folderSearch");

    attrs.add("data-picker-src", pickerSrc);
    attrs.add("data-picker-title", i18n.getVar(cfg.get("pickerTitle", String.class)));
    attrs.add("data-picker-value-key", cfg.get("pickerValueKey", String.class));
    attrs.add("data-picker-id-key", cfg.get("pickerIdKey", String.class));
    attrs.add("data-crumb-root", cfg.get("crumbRoot", crumbRoot));
    attrs.add("data-picker-multiselect", cfg.get("pickerMultiselect", false));

    if (mixed) {
        attrs.addClass("foundation-field-mixed");
    }

    attrs.addOthers(cfg.getProperties(), "id", "class", "rel", "title", "name", "value", "emptyText", "disabled", "rootPath", "optionLoader", "optionLoaderRoot", "optionValueReader", "optionTitleReader", "optionRenderer", "renderReadOnly", "fieldLabel", "fieldDescription", "required", "icon");

    AttrBuilder inputAttrs = new AttrBuilder(request, xssAPI);
    inputAttrs.addClass("coral-InputGroup-input coral-Textfield");
    inputAttrs.addClass("js-coral-pathbrowser-input");
    inputAttrs.add("type", "text");
    inputAttrs.add("name", cfg.get("name", String.class));
    inputAttrs.add("autocomplete", "off");
    inputAttrs.addDisabled(disabled);

    if (mixed) {
        inputAttrs.add("placeholder", i18n.get("<Mixed Entries>"));
    } else {
        inputAttrs.add("value", vm.get("value", String.class));
        inputAttrs.add("placeholder", i18n.getVar(cfg.get("emptyText", String.class)));
    }

    if (cfg.get("required", false)) {
        inputAttrs.add("aria-required", true);
    }
%>

<c:set var="uuid" value="<%= UUID.randomUUID().toString()%>"/>
<span <%= attrs.build() %>  id="${uuid}_field">
    <span class="coral-InputGroup coral-InputGroup--block" id="test">
        <input <%= inputAttrs.build() %> id="${uuid}">
        <span class="coral-InputGroup-button">
            <button class="coral-Button coral-Button--square js-coral-pathbrowser-button" type="button" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Browse")) %>">
                <i class="coral-Icon coral-Icon--sizeS <%= cmp.getIconClass(icon) %>"></i>
            </button>
        </span>
    </span>
    <div class="previewSwatch">
        <img src="" />
        <span class="swatchName"> </span>
        <span class="swatchId"> </span>
    </div>
</span>
<script type="text/javascript">
    $(document).ready(function () {
        $('#${uuid}').pathField('#${uuid}');
    });
</script>