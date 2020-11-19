$(document).ready(function() {
  $(".team-organization").select2({
    ajax: {
      url: "/unlinked_organizations.json",
      dataType: 'json',
      data: function(term, page) {
        return { uq: term };
      },
      results: function(data, page) {
        return { results: data.orgs };
      }
    },
  });
});
