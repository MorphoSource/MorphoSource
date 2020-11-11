// submit search when user changes selected work type
// only on catalog pages - not on home page
$( document ).ready(function() {
  if ($('form[id="search-form-header"]').hasClass("ms-catalog-search")) {

    var searchBox = document.querySelector('#search-form-header');

    var observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        if (mutation.type == "attributes") {
          $('form').submit();
        }
      });
    });

    observer.observe(searchBox, {
      attributes: true
    });
  }
});
