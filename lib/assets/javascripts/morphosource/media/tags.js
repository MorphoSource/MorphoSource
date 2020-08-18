$(document).ready(function() {
  $(".media-tags").select2({
    tags: [],
    tokenSeparators: [','],
    maximumInputLength: 50,
    createSearchChoice: function (term) {
      // special characters: +, -, &&, ||, !, (, ), ", ~, *, ?, and : not allowed in solr searches
      // regex below allows letters, accented letters, numbers, and spaces
      if (/^[A-Za-zÀ-ÖØ-öø-ÿ0-9 ]*$/.test(term) == false) {
        return null;
      }
      return {
          id: $.trim(term),
          text: $.trim(term) + ' (new tag)'
      };
    },
    formatNoMatches: function() {
      return "tag contains an illegal character";
    },
    initSelection: function(element, callback) {
      var data = [];
      $(element.val().split(",")).each(function () {
          data.push({id: this, text: this});
      });
      callback(data);
      element.text('')
    },
    ajax: {
        url: "/tags.json",
        dataType: 'json',
        data: function(term, page) {
            return { uq: term };
        },
        results: function(data, page) {
          return { results: data.tags };
        }
    },
  });
});
