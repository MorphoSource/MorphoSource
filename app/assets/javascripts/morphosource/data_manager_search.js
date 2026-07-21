// Based on Hyrax userSearch https://github.com/samvera/hyrax/blob/v2.9.0/app/assets/javascripts/hyrax/user_search.js
// Returns both users and organization collections
(function( $ ){

  $.fn.dataManagerSearch = function() {
    return this.each(function() {
      $(this).select2( {
        placeholder: "Search for a user or organization",
        minimumInputLength: 2,
        id: function(object) {
          return object.id;
        },
        initSelection: function(element, callback) {
          var data = {
            id: element.val(),
            text: element.val()
          };
          callback(data);
        },
        // Badge organization results so they're visually distinct from individual users,
        // since transferring to an organization behaves differently (requires org
        // acceptance, cannot be canceled by the sender). escapeMarkup is overridden
        // (Select2's default escapes HTML) so the badge markup below actually renders.
        escapeMarkup: function(m) { return m; },
        formatResult: function(object) {
          var text = $('<div>').text(object.text).html(); // escape the dynamic text itself
          return object.type === 'organization' ? text + ' <span class="label label-info">Organization</span>' : text;
        },
        formatSelection: function(object) {
          var text = $('<div>').text(object.text).html();
          return object.type === 'organization' ? text + ' <span class="label label-info">Organization</span>' : text;
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