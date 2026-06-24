// Multi-select reviewer search hitting /data-managers (contributor users and org collections)
(function( $ ){

  $.fn.reviewerSearchMultiple = function(initialData) {
    return this.each(function() {
      $(this).select2({
        placeholder: "Search for a contributor or organization",
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
            return { uq: term };
          },
          results: function(data, page) {
            return { results: data.users };
          }
        },
      }).select2('data', initialData);
    });
  };
})( jQuery );
