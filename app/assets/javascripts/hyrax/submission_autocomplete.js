(function( $ ){

  $.fn.submissionAutocomplete = function(suppliedData) {
    if (suppliedData.hasOwnProperty('complete')) {
      var completeFunction = suppliedData.complete;
      delete suppliedData.complete;
    } else {
      var completeFunction = function(xhr, status) {
        return $.parseJSON(xhr.responseText);
      };
    }
    if (suppliedData.hasOwnProperty('url')) {
      var url = suppliedData.url;
      delete suppliedData.url;
    } else {
      return false;
    }
    var initialData = {
      source: function (request, response) {
        $.ajax({
          url: url + request.term,
          timeout: 10000,
          type: 'GET',
          dataType: 'json',
          complete: function (xhr, status) {
            if (status == 'success') {
              response(completeFunction(xhr, status));
            } else {
              response([{ value: -1, label: 'Unknown error occurred, try query again' }]);
            }
          }
        });
      },
      response: function (event, ui) {
        if (!ui.content.length) {
          var noResult = { value: '', label: 'No Results Found' };
          ui.content.push(noResult);
        }
      },
      focus: function( event, ui ) {
        event.preventDefault();
      },
      autoFocus: false
    }
    return this.each(function() {
      $(this).autocomplete( $.extend(initialData, suppliedData) );
    });

  };
})( jQuery );

