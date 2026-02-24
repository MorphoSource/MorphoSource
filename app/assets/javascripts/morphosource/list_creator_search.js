// Based on dataManagerSearch
// Returns registered users as well as contributors and organization collections
(function( $ ){

  $.fn.listCreatorSearch = function() {
    return this.each(function() {
      $(this).select2( {
        placeholder: "Search for a user or organization",
        minimumInputLength: 2,
        id: function(object) {
          return object.user_key;
        },
        initSelection: function(element, callback) {
          var data = {
            user_key: element.val(),
            text: element.val()
          };
          callback(data);
        },
        ajax: { // Use the jQuery.ajax wrapper provided by Select2
          url: "/list-creators",
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