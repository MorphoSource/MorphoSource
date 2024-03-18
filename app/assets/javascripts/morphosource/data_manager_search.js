// Based on Hyrax userSearch https://github.com/samvera/hyrax/blob/v2.9.0/app/assets/javascripts/hyrax/user_search.js
// Returns both users and organization collections
(function( $ ){

  $.fn.dataManagerSearch = function() {
    return this.each(function() {
      $(this).select2( {
        placeholder: $(this).attr("value") || "Search for a user or organization",
        minimumInputLength: 2,
        id: function(object) {
          return object.user_key;
        },
        initSelection: function(element, callback) {
          var data = {
            id: element.val(),
            text: element.val()
          };
          callback(data);
        },
        ajax: { // Use the jQuery.ajax wrapper provided by Select2
          url: "/data-managers",
          dataType: "json",
          data: function (term, page) {
            return {
              uq: term // Search term
            };
          },
          results: function(data, page) {
            console.log(data.users);
            return { results: data.users };
          }
        },
      }).select2('data', null);
    });

  };
})( jQuery );