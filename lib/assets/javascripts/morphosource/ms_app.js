Hyrax.workEditor = function () {
  /*
  var element = $("[data-behavior='work-form']")
  if (element.length > 0) {
    var Editor = require('morphosource/ms_editor');
    new Editor(element).init();
  }
  */
  // init multiple forms for showcase edit pages (e.g. media)
  var Editor = require('morphosource/ms_editor');
  $("[data-behavior='work-form']").each(function() {
    new Editor($(this)).init();
  })
},

Hyrax.collectionsV2 = function() {
  var CollectionsV2 = require('morphosource/ms_collections_v2');
  new CollectionsV2();
}
