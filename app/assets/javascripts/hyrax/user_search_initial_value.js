// Fundamentally similar to app/assets/javascripts/hyrax/user_search.js from Hyrax
// Fixes some bugs relating to setting initial value
(function( $ ){

  $.fn.userSearchInitialValue = function() {
    return this.each(function() {
      $(this).select2( {
        minimumInputLength: 2,
        id: function(object) {
          return object.user_key;
        },
        initSelection: function(element, callback) {
          initialUser = element.data('initial-user');
          console.log(initialUser);
          var data = {
            id: initialUser.id,
            user_key: initialUser.user_key,
            text: initialUser.text
          };
          callback(data);
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
      });
    });

  };
})( jQuery );
