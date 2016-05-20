$(document).on("foundation-contentloaded", function (e) {

    function Generator() {
    }

    Generator.prototype.rand = Math.floor(Math.random() * 26) + Date.now();
    Generator.prototype.getId = function () {
        return this.rand++;
    };
    var idGen = new Generator();
    var oldSwatchIdField = $(".cq-dialog-swatch-uniqueId");
    var oldRecipeIdField = $(".cq-dialog-recipe-uniqueId");
    if (oldSwatchIdField.length != 0) {
        var oldSwatchIdFieldVal = oldSwatchIdField.val();
        if (oldSwatchIdFieldVal === undefined || oldSwatchIdFieldVal == "") {
            oldSwatchIdField.val("sw_" + idGen.rand);
        }
    } else if (oldRecipeIdField.length != 0) {
        var oldRecipedFieldVal = oldRecipeIdField.val();
        if (oldRecipedFieldVal === undefined || oldRecipedFieldVal == "") {
            oldRecipeIdField.val("re_" + idGen.rand);
        }
    }
});