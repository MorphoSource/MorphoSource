// Multi-select reviewer search hitting /data-managers (contributor users and org collections).
// Pass { usersOnly: true } to restrict results to users (org collection forms,
// where orgs may only select themselves via the managers checkbox).
(function( $ ){

  $.fn.reviewerSearchMultiple = function(initialData, options) {
    options = options || {};
    return this.each(function() {
      $(this).select2({
        placeholder: options.usersOnly ? "Search for a contributor" : "Search for a contributor or organization",
        minimumInputLength: 2,
        id: function(object) {
          return object.user_key;
        },
        multiple: true,
        initSelection: function(element, callback) {
          callback(initialData);
        },
        ajax: {
          url: "/data-managers",
          dataType: "json",
          data: function(term, page) {
            var params = { uq: term, reviewer_field: true };
            if (options.usersOnly) { params.users_only = true; }
            return params;
          },
          results: function(data, page) {
            return { results: data.users };
          }
        },
      }).select2('data', initialData);
    });
  };
})( jQuery );
