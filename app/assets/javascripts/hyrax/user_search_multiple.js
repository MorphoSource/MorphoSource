(function( $ ){

  $.fn.userSearchMultiple = function(initialData) {
    return this.each(function() {
      $(this).select2( {
        minimumInputLength: 2,
        id: function(object) {
          return object.user_key;
        },
        multiple: true,
        initSelection: function(element, callback) {
          callback(initialData);
        },
        ajax: { // Use the jQuery.ajax wrapper provided by Select2
          url: "/users.json",
          dataType: "json",
          data: function (term, page) {
            return {
              uq: term // Search term
            };
          },
          results: function(data, page) {
            return { results: data.users };
          }
        },
      }).select2(
        'data', 
        initialData
      );
    });

  };
})( jQuery );
